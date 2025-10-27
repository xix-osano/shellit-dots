pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

Singleton {
    id: root

    property bool accountsServiceAvailable: false
    property string systemProfileImage: ""
    property string profileImage: ""
    property bool settingsPortalAvailable: false
    property int systemColorScheme: 0

    property bool freedeskAvailable: false
    property string colorSchemeCommand: ""
    property string pendingProfileImage: ""

    readonly property string socketPath: Quickshell.env("SHELLIT_SOCKET")

    function init() {}

    function getSystemProfileImage() {
        if (!freedeskAvailable)
            return

        const username = Quickshell.env("USER")
        if (!username)
            return

        SHELLITService.sendRequest("freedesktop.accounts.getUserIconFile", {
                                   "username": username
                               }, response => {
                                   if (response.result && response.result.success) {
                                       const iconFile = response.result.value || ""
                                       if (iconFile && iconFile !== "" && iconFile !== "/var/lib/AccountsService/icons/") {
                                           systemProfileImage = iconFile
                                           if (!profileImage || profileImage === "") {
                                               profileImage = iconFile
                                           }
                                       }
                                   }
                               })
    }

    function getUserProfileImage(username) {
        if (!username) {
            profileImage = ""
            return
        }

        if (!freedeskAvailable) {
            profileImage = ""
            return
        }

        SHELLITService.sendRequest("freedesktop.accounts.getUserIconFile", {
                                   "username": username
                               }, response => {
                                   if (response.result && response.result.success) {
                                       const icon = response.result.value || ""
                                       if (icon && icon !== "" && icon !== "/var/lib/AccountsService/icons/") {
                                           profileImage = icon
                                       } else {
                                           profileImage = ""
                                       }
                                   } else {
                                       profileImage = ""
                                   }
                               })
    }

    function setProfileImage(imagePath) {
        if (accountsServiceAvailable) {
            pendingProfileImage = imagePath
            setSystemProfileImage(imagePath || "")
        } else {
            profileImage = imagePath
        }
    }

    function getSystemColorScheme() {
        if (typeof SettingsData !== "undefined" && SettingsData.syncModeWithPortal === false) {
            return
        }
        if (!freedeskAvailable)
            return

        SHELLITService.sendRequest("freedesktop.settings.getColorScheme", null, response => {
                                   if (response.result) {
                                       systemColorScheme = response.result.value || 0
                                   }
                               })
    }

    function setLightMode(isLightMode) {
        if (typeof SettingsData !== "undefined" && SettingsData.syncModeWithPortal === false) {
            return
        }
        setSystemColorScheme(isLightMode)
    }

    function setSystemColorScheme(isLightMode) {
        if (typeof SettingsData !== "undefined" && SettingsData.syncModeWithPortal === false) {
            return
        }

        const targetScheme = isLightMode ? "default" : "prefer-dark"

        if (colorSchemeCommand === "gsettings") {
            Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", targetScheme])
        }
        if (colorSchemeCommand === "dconf") {
            Quickshell.execDetached(["dconf", "write", "/org/gnome/desktop/interface/color-scheme", `'${targetScheme}'`])
        }
    }

    function setSystemIconTheme(themeName) {
        if (!settingsPortalAvailable || !freedeskAvailable)
            return

        SHELLITService.sendRequest("freedesktop.settings.setIconTheme", {
                                   "iconTheme": themeName
                               }, response => {
                                   if (response.error) {
                                       console.warn("PortalService: Failed to set icon theme:", response.error)
                                   }
                               })
    }

    function setSystemProfileImage(imagePath) {
        if (!accountsServiceAvailable || !freedeskAvailable)
            return

        SHELLITService.sendRequest("freedesktop.accounts.setIconFile", {
                                   "path": imagePath || ""
                               }, response => {
                                   if (response.error) {
                                       console.warn("PortalService: Failed to set icon file:", response.error)

                                       const errorMsg = response.error.toString()
                                       let userMessage = "Failed to set profile image"

                                       if (errorMsg.includes("too large")) {
                                           userMessage = "Profile image is too large. Please use a smaller image."
                                       } else if (errorMsg.includes("permission")) {
                                           userMessage = "Permission denied to set profile image."
                                       } else if (errorMsg.includes("not found") || errorMsg.includes("does not exist")) {
                                           userMessage = "Selected image file not found."
                                       } else {
                                           userMessage = "Failed to set profile image: " + errorMsg.split(":").pop().trim()
                                       }

                                       Quickshell.execDetached(["notify-send", "-u", "normal", "-a", "SHELLIT", "-i", "error", "Profile Image Error", userMessage])

                                       pendingProfileImage = ""
                                   } else {
                                       profileImage = pendingProfileImage
                                       pendingProfileImage = ""
                                       Qt.callLater(() => getSystemProfileImage())
                                   }
                               })
    }

    Component.onCompleted: {
        if (socketPath && socketPath.length > 0) {
            checkSHELLITCapabilities()
        } else {
            console.info("PortalService: SHELLIT_SOCKET not set")
        }
        colorSchemeDetector.running = true
    }

    Connections {
        target: SHELLITService

        function onConnectionStateChanged() {
            if (SHELLITService.isConnected) {
                checkSHELLITCapabilities()
            }
        }
    }

    Connections {
        target: SHELLITService
        enabled: SHELLITService.isConnected

        function onCapabilitiesChanged() {
            checkSHELLITCapabilities()
        }
    }

    function checkSHELLITCapabilities() {
        if (!SHELLITService.isConnected) {
            return
        }

        if (SHELLITService.capabilities.length === 0) {
            return
        }

        freedeskAvailable = SHELLITService.capabilities.includes("freedesktop")
        if (freedeskAvailable) {
            checkAccountsService()
            checkSettingsPortal()
        } else {
            console.info("PortalService: freedesktop capability not available in SHELLIT")
        }
    }

    function checkAccountsService() {
        if (!freedeskAvailable)
            return

        SHELLITService.sendRequest("freedesktop.getState", null, response => {
                                   if (response.result && response.result.accounts) {
                                       accountsServiceAvailable = response.result.accounts.available || false
                                       if (accountsServiceAvailable) {
                                           getSystemProfileImage()
                                       }
                                   }
                               })
    }

    function checkSettingsPortal() {
        if (!freedeskAvailable)
            return

        SHELLITService.sendRequest("freedesktop.getState", null, response => {
                                   if (response.result && response.result.settings) {
                                       settingsPortalAvailable = response.result.settings.available || false
                                       if (settingsPortalAvailable && SettingsData.syncModeWithPortal) {
                                           getSystemColorScheme()
                                       }
                                   }
                               })
    }

    Process {
        id: userProfileCheckProcess
        command: []
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const trimmed = text.trim()
                if (trimmed && trimmed !== "" && !trimmed.includes("Error") && trimmed !== "/var/lib/AccountsService/icons/") {
                    root.profileImage = trimmed
                } else {
                    root.profileImage = ""
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.profileImage = ""
            }
        }
    }

    Process {
        id: colorSchemeDetector
        command: ["bash", "-c", "command -v gsettings || command -v dconf"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const cmd = text.trim()
                if (cmd.includes("gsettings")) {
                    root.colorSchemeCommand = "gsettings"
                } else if (cmd.includes("dconf")) {
                    root.colorSchemeCommand = "dconf"
                }
            }
        }
    }

    IpcHandler {
        target: "profile"

        function getImage(): string {
            return root.profileImage
        }

        function setImage(path: string): string {
            if (!path) {
                return "ERROR: No path provided"
            }

            const absolutePath = path.startsWith("/") ? path : `${StandardPaths.writableLocation(StandardPaths.HomeLocation)}/${path}`

            try {
                root.setProfileImage(absolutePath)
                return "SUCCESS: Profile image set to " + absolutePath
            } catch (e) {
                return "ERROR: Failed to set profile image: " + e.toString()
            }
        }

        function clearImage(): string {
            root.setProfileImage("")
            return "SUCCESS: Profile image cleared"
        }
    }
}
