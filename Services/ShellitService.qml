pragma Singleton

pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property bool shellitAvailable: false
    property var capabilities: []
    property int apiVersion: 0
    readonly property int expectedApiVersion: 1
    property var availablePlugins: []
    property var installedPlugins: []
    property bool isConnected: false
    property bool isConnecting: false
    property bool subscribeConnected: false

    readonly property string socketPath: Quickshell.env("shellit_SOCKET")

    property var pendingRequests: ({})
    property int requestIdCounter: 0
    property bool shownOutdatedError: false
    property string updateCommand: "shellit update"
    property bool checkingUpdateCommand: false

    signal pluginsListReceived(var plugins)
    signal installedPluginsReceived(var plugins)
    signal searchResultsReceived(var plugins)
    signal operationSuccess(string message)
    signal operationError(string error)
    signal connectionStateChanged()

    signal networkStateUpdate(var data)
    signal loginctlStateUpdate(var data)
    signal loginctlEvent(var event)
    signal capabilitiesReceived()
    signal credentialsRequest(var data)
    signal bluetoothPairingRequest(var data)

    Component.onCompleted: {
        if (socketPath && socketPath.length > 0) {
            detectUpdateCommand()
        }
    }

    function detectUpdateCommand() {
        checkingUpdateCommand = true
        checkAurHelper.running = true
    }

    function startSocketConnection() {
        if (socketPath && socketPath.length > 0) {
            testProcess.running = true
        }
    }

    Process {
        id: checkAurHelper
        command: ["sh", "-c", "command -v paru || command -v yay"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const helper = text.trim()
                if (helper.includes("paru")) {
                    checkshellitPackage.helper = "paru"
                    checkshellitPackage.running = true
                } else if (helper.includes("yay")) {
                    checkshellitPackage.helper = "yay"
                    checkshellitPackage.running = true
                } else {
                    updateCommand = "shellit update"
                    checkingUpdateCommand = false
                    startSocketConnection()
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                updateCommand = "shellit update"
                checkingUpdateCommand = false
                startSocketConnection()
            }
        }
    }

    Process {
        id: checkshellitPackage
        property string helper: ""
        command: ["sh", "-c", "pacman -Qi shellit-shell-git 2>/dev/null || pacman -Qi shellit-shell-bin 2>/dev/null"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.includes("shellit-shell-git")) {
                    updateCommand = checkshellitPackage.helper + " -S shellit-shell-git"
                } else if (text.includes("shellit-shell-bin")) {
                    updateCommand = checkshellitPackage.helper + " -S shellit-shell-bin"
                } else {
                    updateCommand = "shellit update"
                }
                checkingUpdateCommand = false
                startSocketConnection()
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                updateCommand = "shellit update"
                checkingUpdateCommand = false
                startSocketConnection()
            }
        }
    }

    Process {
        id: testProcess
        command: ["test", "-S", root.socketPath]

        onExited: exitCode => {
            if (exitCode === 0) {
                root.shellitAvailable = true
                connectSocket()
            } else {
                root.shellitAvailable = false
            }
        }
    }

    function connectSocket() {
        if (!shellitAvailable || isConnected || isConnecting) {
            return
        }

        isConnecting = true
        requestSocket.connected = true
    }

    ShellitSocket {
        id: requestSocket
        path: root.socketPath
        connected: false

        onConnectionStateChanged: {
            if (connected) {
                root.isConnected = true
                root.isConnecting = false
                root.connectionStateChanged()
                subscribeSocket.connected = true
            } else {
                root.isConnected = false
                root.isConnecting = false
                root.apiVersion = 0
                root.capabilities = []
                root.connectionStateChanged()
            }
        }

        parser: SplitParser {
            onRead: line => {
                if (!line || line.length === 0) {
                    return
                }

                console.log("shellitService: Request socket <<", line)

                try {
                    const response = JSON.parse(line)
                    handleResponse(response)
                } catch (e) {
                    console.warn("shellitService: Failed to parse request response:", line, e)
                }
            }
        }
    }

    ShellitSocket {
        id: subscribeSocket
        path: root.socketPath
        connected: false

        onConnectionStateChanged: {
            root.subscribeConnected = connected
            if (connected) {
                sendSubscribeRequest()
            }
        }

        parser: SplitParser {
            onRead: line => {
                if (!line || line.length === 0) {
                    return
                }

                console.log("shellitService: Subscribe socket <<", line)

                try {
                    const response = JSON.parse(line)
                    handleSubscriptionEvent(response)
                } catch (e) {
                    console.warn("shellitService: Failed to parse subscription event:", line, e)
                }
            }
        }
    }

    function sendSubscribeRequest() {
        const request = {
            "method": "subscribe"
        }

        console.log("shellitService: Subscribing to all services")
        subscribeSocket.send(request)
    }

    function handleSubscriptionEvent(response) {
        if (response.error) {
            if (response.error.includes("unknown method") && response.error.includes("subscribe")) {
                if (!shownOutdatedError) {
                    console.error("shellitService: Server does not support subscribe method")
                    ToastService.showError(
                        I18n.tr("shellit out of date"),
                        I18n.tr("To update, run the following command:"),
                        updateCommand
                    )
                    shownOutdatedError = true
                }
            }
            return
        }

        if (!response.result) {
            return
        }

        const service = response.result.service
        const data = response.result.data

        if (service === "server") {
            apiVersion = data.apiVersion || 0
            capabilities = data.capabilities || []

            console.info("shellitService: Connected (API v" + apiVersion + ") -", JSON.stringify(capabilities))

            if (apiVersion < expectedApiVersion) {
                ToastService.showError("shellit server is outdated (API v" + apiVersion + ", expected v" + expectedApiVersion + ")")
            }

            capabilitiesReceived()
        } else if (service === "network") {
            networkStateUpdate(data)
        } else if (service === "network.credentials") {
            credentialsRequest(data)
        } else if (service === "loginctl") {
            if (data.event) {
                loginctlEvent(data)
            } else {
                loginctlStateUpdate(data)
            }
        } else if (service === "bluetooth.pairing") {
            bluetoothPairingRequest(data)
        }
    }

    function sendRequest(method, params, callback) {
        if (!isConnected) {
            console.warn("shellitService.sendRequest: Not connected, method:", method)
            if (callback) {
                callback({
                    "error": "not connected to shellit socket"
                })
            }
            return
        }

        requestIdCounter++
        const id = Date.now() + requestIdCounter
        const request = {
            "id": id,
            "method": method
        }

        if (params) {
            request.params = params
        }

        if (callback) {
            pendingRequests[id] = callback
        }

        console.log("shellitService.sendRequest: Sending request id=" + id + " method=" + method)
        requestSocket.send(request)
    }

    function handleResponse(response) {
        const callback = pendingRequests[response.id]

        if (callback) {
            delete pendingRequests[response.id]
            callback(response)
        }
    }

    function ping(callback) {
        sendRequest("ping", null, callback)
    }

    function listPlugins(callback) {
        sendRequest("plugins.list", null, response => {
                        if (response.result) {
                            availablePlugins = response.result
                            pluginsListReceived(response.result)
                        }
                        if (callback) {
                            callback(response)
                        }
                    })
    }

    function listInstalled(callback) {
        sendRequest("plugins.listInstalled", null, response => {
                        if (response.result) {
                            installedPlugins = response.result
                            installedPluginsReceived(response.result)
                        }
                        if (callback) {
                            callback(response)
                        }
                    })
    }

    function search(query, category, compositor, capability, callback) {
        const params = {
            "query": query
        }
        if (category) {
            params.category = category
        }
        if (compositor) {
            params.compositor = compositor
        }
        if (capability) {
            params.capability = capability
        }

        sendRequest("plugins.search", params, response => {
                        if (response.result) {
                            searchResultsReceived(response.result)
                        }
                        if (callback) {
                            callback(response)
                        }
                    })
    }

    function install(pluginName, callback) {
        sendRequest("plugins.install", {
                        "name": pluginName
                    }, response => {
                        if (callback) {
                            callback(response)
                        }
                        if (!response.error) {
                            listInstalled()
                        }
                    })
    }

    function uninstall(pluginName, callback) {
        sendRequest("plugins.uninstall", {
                        "name": pluginName
                    }, response => {
                        if (callback) {
                            callback(response)
                        }
                        if (!response.error) {
                            listInstalled()
                        }
                    })
    }

    function update(pluginName, callback) {
        sendRequest("plugins.update", {
                        "name": pluginName
                    }, response => {
                        if (callback) {
                            callback(response)
                        }
                        if (!response.error) {
                            listInstalled()
                        }
                    })
    }

    function lockSession(callback) {
        sendRequest("loginctl.lock", null, callback)
    }

    function unlockSession(callback) {
        sendRequest("loginctl.unlock", null, callback)
    }

    function bluetoothPair(devicePath, callback) {
        sendRequest("bluetooth.pair", {
                        "device": devicePath
                    }, callback)
    }

    function bluetoothConnect(devicePath, callback) {
        sendRequest("bluetooth.connect", {
                        "device": devicePath
                    }, callback)
    }

    function bluetoothDisconnect(devicePath, callback) {
        sendRequest("bluetooth.disconnect", {
                        "device": devicePath
                    }, callback)
    }

    function bluetoothRemove(devicePath, callback) {
        sendRequest("bluetooth.remove", {
                        "device": devicePath
                    }, callback)
    }

    function bluetoothTrust(devicePath, callback) {
        sendRequest("bluetooth.trust", {
                        "device": devicePath
                    }, callback)
    }

    function bluetoothSubmitPairing(token, secrets, accept, callback) {
        sendRequest("bluetooth.pairing.submit", {
                        "token": token,
                        "secrets": secrets,
                        "accept": accept
                    }, callback)
    }

    function bluetoothCancelPairing(token, callback) {
        sendRequest("bluetooth.pairing.cancel", {
                        "token": token
                    }, callback)
    }
}
