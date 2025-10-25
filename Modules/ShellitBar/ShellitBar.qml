import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Modules
import qs.Modules.ShellitBar.Widgets
import qs.Modules.ShellitBar.Popouts
import qs.Services
import qs.Widgets

Item {
    id: root

    signal colorPickerRequested

    property alias barVariants: barVariants
    property var hyprlandOverviewLoader: null

    function triggerControlCenterOnFocusedScreen() {
        let focusedScreenName = ""
        if (CompositorService.isHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.monitor) {
            focusedScreenName = Hyprland.focusedWorkspace.monitor.name
        } else if (CompositorService.isNiri && NiriService.currentOutput) {
            focusedScreenName = NiriService.currentOutput
        }

        if (!focusedScreenName && barVariants.instances.length > 0) {
            const firstBar = barVariants.instances[0]
            firstBar.triggerControlCenter()
            return true
        }

        for (var i = 0; i < barVariants.instances.length; i++) {
            const barInstance = barVariants.instances[i]
            if (barInstance.modelData && barInstance.modelData.name === focusedScreenName) {
                barInstance.triggerControlCenter()
                return true
            }
        }
        return false
    }

    function triggerWallpaperBrowserOnFocusedScreen() {
        let focusedScreenName = ""
        if (CompositorService.isHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.monitor) {
            focusedScreenName = Hyprland.focusedWorkspace.monitor.name
        } else if (CompositorService.isNiri && NiriService.currentOutput) {
            focusedScreenName = NiriService.currentOutput
        }

        if (!focusedScreenName && barVariants.instances.length > 0) {
            const firstBar = barVariants.instances[0]
            firstBar.triggerWallpaperBrowser()
            return true
        }

        for (var i = 0; i < barVariants.instances.length; i++) {
            const barInstance = barVariants.instances[i]
            if (barInstance.modelData && barInstance.modelData.name === focusedScreenName) {
                barInstance.triggerWallpaperBrowser()
                return true
            }
        }
        return false
    }

    Variants {
        id: barVariants
        model: SettingsData.getFilteredScreens("ShellitBar")

        delegate: PanelWindow {
            id: barWindow

            property var controlCenterButtonRef: null
            property var clockButtonRef: null

            function triggerControlCenter() {
                controlCenterLoader.active = true
                if (!controlCenterLoader.item) {
                    return
                }

                if (controlCenterButtonRef && controlCenterLoader.item.setTriggerPosition) {
                    const globalPos = controlCenterButtonRef.mapToGlobal(0, 0)
                    const pos = SettingsData.getPopupTriggerPosition(globalPos, barWindow.screen, barWindow.effectiveBarThickness, controlCenterButtonRef.width)
                    const section = controlCenterButtonRef.section || "right"
                    controlCenterLoader.item.setTriggerPosition(pos.x, pos.y, pos.width, section, barWindow.screen)
                } else {
                    controlCenterLoader.item.triggerScreen = barWindow.screen
                }

                controlCenterLoader.item.toggle()
                if (controlCenterLoader.item.shouldBeVisible && NetworkService.wifiEnabled) {
                    NetworkService.scanWifi()
                }
            }

            function triggerWallpaperBrowser() {
                ShellitDashPopoutLoader.active = true
                if (!ShellitDashPopoutLoader.item) {
                    return
                }

                if (clockButtonRef && ShellitDashPopoutLoader.item.setTriggerPosition) {
                    const globalPos = clockButtonRef.mapToGlobal(0, 0)
                    const pos = SettingsData.getPopupTriggerPosition(globalPos, barWindow.screen, barWindow.effectiveBarThickness, clockButtonRef.width)
                    const section = clockButtonRef.section || "center"
                    ShellitDashPopoutLoader.item.setTriggerPosition(pos.x, pos.y, pos.width, section, barWindow.screen)
                } else {
                    ShellitDashPopoutLoader.item.triggerScreen = barWindow.screen
                }

                if (!ShellitDashPopoutLoader.item.dashVisible) {
                    ShellitDashPopoutLoader.item.currentTabIndex = 2
                }
                ShellitDashPopoutLoader.item.dashVisible = !ShellitDashPopoutLoader.item.dashVisible
            }

            readonly property var dBarLayer: {
                switch (Quickshell.env("DMS_ShellitBAR_LAYER")) {
                case "bottom":
                    return WlrLayer.Bottom
                case "overlay":
                    return WlrLayer.Overlay
                case "background":
                    return WlrLayer.background
                default:
                    return WlrLayer.Top
                }
            }

            WlrLayershell.layer: dBarLayer
            WlrLayershell.namespace: "quickshell:bar"

            property var modelData: item

            signal colorPickerRequested

            onColorPickerRequested: root.colorPickerRequested()

            AxisContext {
                id: axis
                edge: {
                    switch (SettingsData.ShellitBarPosition) {
                    case SettingsData.Position.Top:
                        return "top"
                    case SettingsData.Position.Bottom:
                        return "bottom"
                    case SettingsData.Position.Left:
                        return "left"
                    case SettingsData.Position.Right:
                        return "right"
                    default:
                        return "top"
                    }
                }
            }

            readonly property bool isVertical: axis.isVertical

            property bool gothCornersEnabled: SettingsData.ShellitBarGothCornersEnabled
            property real wingtipsRadius: Theme.cornerRadius
            readonly property real _wingR: Math.max(0, wingtipsRadius)
            readonly property color _surfaceContainer: Theme.surfaceContainer
            readonly property real _backgroundAlpha: topBarCore?.backgroundTransparency ?? SettingsData.ShellitBarTransparency
            readonly property color _bgColor: Theme.withAlpha(_surfaceContainer, _backgroundAlpha)
            readonly property real _dpr: {
                if (CompositorService.isNiri && barWindow.screen) {
                    const niriScale = NiriService.displayScales[barWindow.screen.name]
                    if (niriScale !== undefined)
                        return niriScale
                }
                if (CompositorService.isHyprland && barWindow.screen) {
                    const hyprlandMonitor = Hyprland.monitors.values.find(m => m.name === barWindow.screen.name)
                    if (hyprlandMonitor?.scale !== undefined)
                        return hyprlandMonitor.scale
                }
                return (barWindow.screen?.devicePixelRatio) || 1
            }

            property string screenName: modelData.name
            readonly property int notificationCount: NotificationService.notifications.length
            readonly property real effectiveBarThickness: Math.max(barWindow.widgetThickness + SettingsData.ShellitBarInnerPadding + 4, Theme.barHeight - 4 - (8 - SettingsData.ShellitBarInnerPadding))
            readonly property real widgetThickness: Math.max(20, 26 + SettingsData.ShellitBarInnerPadding * 0.6)

            screen: modelData
            implicitHeight: !isVertical ? Theme.px(effectiveBarThickness + SettingsData.ShellitBarSpacing + (SettingsData.ShellitBarGothCornersEnabled ? _wingR : 0), _dpr) : 0
            implicitWidth: isVertical ? Theme.px(effectiveBarThickness + SettingsData.ShellitBarSpacing + (SettingsData.ShellitBarGothCornersEnabled ? _wingR : 0), _dpr) : 0
            color: "transparent"

            property var nativeInhibitor: null

            Component.onCompleted: {
                const fonts = Qt.fontFamilies()
                if (fonts.indexOf("Material Symbols Rounded") === -1) {
                    ToastService.showError("Please install Material Symbols Rounded and Restart your Shell. See README.md for instructions")
                }

                if (SettingsData.forceStatusBarLayoutRefresh) {
                    SettingsData.forceStatusBarLayoutRefresh.connect(() => {
                                                                         Qt.callLater(() => {
                                                                                          stackContainer.visible = false
                                                                                          Qt.callLater(() => {
                                                                                                           stackContainer.visible = true
                                                                                                       })
                                                                                      })
                                                                     })
                }

                updateGpuTempConfig()

                inhibitorInitTimer.start()
            }

            Timer {
                id: inhibitorInitTimer
                interval: 300
                repeat: false
                onTriggered: {
                    if (SessionService.nativeInhibitorAvailable) {
                        createNativeInhibitor()
                    }
                }
            }

            Connections {
                target: PluginService
                function onPluginLoaded(pluginId) {
                    console.info("ShellitBar: Plugin loaded:", pluginId)
                    SettingsData.widgetDataChanged()
                }
                function onPluginUnloaded(pluginId) {
                    console.info("ShellitBar: Plugin unloaded:", pluginId)
                    SettingsData.widgetDataChanged()
                }
            }

            function updateGpuTempConfig() {
                const allWidgets = [...(SettingsData.ShellitBarLeftWidgets || []), ...(SettingsData.ShellitBarCenterWidgets || []), ...(SettingsData.ShellitBarRightWidgets || [])]

                const hasGpuTempWidget = allWidgets.some(widget => {
                                                             const widgetId = typeof widget === "string" ? widget : widget.id
                                                             const widgetEnabled = typeof widget === "string" ? true : (widget.enabled !== false)
                                                             return widgetId === "gpuTemp" && widgetEnabled
                                                         })

                DgopService.gpuTempEnabled = hasGpuTempWidget || SessionData.nvidiaGpuTempEnabled || SessionData.nonNvidiaGpuTempEnabled
                DgopService.nvidiaGpuTempEnabled = hasGpuTempWidget || SessionData.nvidiaGpuTempEnabled
                DgopService.nonNvidiaGpuTempEnabled = hasGpuTempWidget || SessionData.nonNvidiaGpuTempEnabled
            }

            function createNativeInhibitor() {
                if (!SessionService.nativeInhibitorAvailable) {
                    return
                }

                try {
                    const qmlString = `
                    import QtQuick
                    import Quickshell.Wayland

                    IdleInhibitor {
                    enabled: false
                    }
                    `

                    nativeInhibitor = Qt.createQmlObject(qmlString, barWindow, "ShellitBar.NativeInhibitor")
                    nativeInhibitor.window = barWindow
                    nativeInhibitor.enabled = Qt.binding(() => SessionService.idleInhibited)
                    nativeInhibitor.enabledChanged.connect(function () {
                        console.log("ShellitBar: Native inhibitor enabled changed to:", nativeInhibitor.enabled)
                        if (SessionService.idleInhibited !== nativeInhibitor.enabled) {
                            SessionService.idleInhibited = nativeInhibitor.enabled
                            SessionService.inhibitorChanged()
                        }
                    })
                    console.log("ShellitBar: Created native Wayland IdleInhibitor for", barWindow.screenName)
                } catch (e) {
                    console.warn("ShellitBar: Failed to create native IdleInhibitor:", e)
                    nativeInhibitor = null
                }
            }

            Connections {
                function onShellitBarLeftWidgetsChanged() {
                    barWindow.updateGpuTempConfig()
                }

                function onShellitBarCenterWidgetsChanged() {
                    barWindow.updateGpuTempConfig()
                }

                function onShellitBarRightWidgetsChanged() {
                    barWindow.updateGpuTempConfig()
                }

                target: SettingsData
            }

            Connections {
                function onNvidiaGpuTempEnabledChanged() {
                    barWindow.updateGpuTempConfig()
                }

                function onNonNvidiaGpuTempEnabledChanged() {
                    barWindow.updateGpuTempConfig()
                }

                target: SessionData
            }

            Connections {
                target: barWindow.screen
                function onGeometryChanged() {
                    Qt.callLater(forceWidgetRefresh)
                }
            }

            Timer {
                id: refreshTimer
                interval: 0
                running: false
                repeat: false
                onTriggered: {
                    forceWidgetRefresh()
                }
            }

            Connections {
                target: axis
                function onChanged() {
                    Qt.application.active
                    refreshTimer.restart()
                }
            }

            anchors.top: !isVertical ? (SettingsData.ShellitBarPosition === SettingsData.Position.Top) : true
            anchors.bottom: !isVertical ? (SettingsData.ShellitBarPosition === SettingsData.Position.Bottom) : true
            anchors.left: !isVertical ? true : (SettingsData.ShellitBarPosition === SettingsData.Position.Left)
            anchors.right: !isVertical ? true : (SettingsData.ShellitBarPosition === SettingsData.Position.Right)

            exclusiveZone: (!SettingsData.ShellitBarVisible || topBarCore.autoHide) ? -1 : (barWindow.effectiveBarThickness + SettingsData.ShellitBarSpacing + SettingsData.ShellitBarBottomGap)

            Item {
                id: inputMask

                readonly property int barThickness: Theme.px(barWindow.effectiveBarThickness + SettingsData.ShellitBarSpacing, barWindow._dpr)

                readonly property bool inOverviewWithShow: CompositorService.isNiri && NiriService.inOverview && SettingsData.ShellitBarOpenOnOverview
                readonly property bool effectiveVisible: SettingsData.ShellitBarVisible || inOverviewWithShow
                readonly property bool showing: effectiveVisible && (topBarCore.reveal || inOverviewWithShow || !topBarCore.autoHide)

                readonly property int maskThickness: showing ? barThickness : 1

                x: {
                    if (!axis.isVertical) {
                        return 0
                    } else {
                        switch (SettingsData.ShellitBarPosition) {
                        case SettingsData.Position.Left:
                            return 0
                        case SettingsData.Position.Right:
                            return parent.width - maskThickness
                        default:
                            return 0
                        }
                    }
                }
                y: {
                    if (axis.isVertical) {
                        return 0
                    } else {
                        switch (SettingsData.ShellitBarPosition) {
                        case SettingsData.Position.Top:
                            return 0
                        case SettingsData.Position.Bottom:
                            return parent.height - maskThickness
                        default:
                            return 0
                        }
                    }
                }
                width: axis.isVertical ? maskThickness : parent.width
                height: axis.isVertical ? parent.height : maskThickness
            }

            mask: Region {
                item: inputMask
            }

            Item {
                id: topBarCore
                anchors.fill: parent
                layer.enabled: true

                property real backgroundTransparency: SettingsData.ShellitBarTransparency
                property bool autoHide: SettingsData.ShellitBarAutoHide
                property bool revealSticky: false

                Timer {
                    id: revealHold
                    interval: 250
                    repeat: false
                    onTriggered: topBarCore.revealSticky = false
                }

                property bool reveal: {
                    if (CompositorService.isNiri && NiriService.inOverview) {
                        return SettingsData.ShellitBarOpenOnOverview || topBarMouseArea.containsMouse || hasActivePopout || revealSticky
                    }
                    return SettingsData.ShellitBarVisible && (!autoHide || topBarMouseArea.containsMouse || hasActivePopout || revealSticky)
                }

                readonly property bool hasActivePopout: {
                    const loaders = [{
                                         "loader": appDrawerLoader,
                                         "prop": "shouldBeVisible"
                                     }, {
                                         "loader": ShellitDashPopoutLoader,
                                         "prop": "shouldBeVisible"
                                     }, {
                                         "loader": processListPopoutLoader,
                                         "prop": "shouldBeVisible"
                                     }, {
                                         "loader": notificationCenterLoader,
                                         "prop": "shouldBeVisible"
                                     }, {
                                         "loader": batteryPopoutLoader,
                                         "prop": "shouldBeVisible"
                                     }, {
                                         "loader": vpnPopoutLoader,
                                         "prop": "shouldBeVisible"
                                     }, {
                                         "loader": controlCenterLoader,
                                         "prop": "shouldBeVisible"
                                     }, {
                                         "loader": clipboardHistoryModalPopup,
                                         "prop": "visible"
                                     }, {
                                         "loader": systemUpdateLoader,
                                         "prop": "shouldBeVisible"
                                     }]
                    return loaders.some(item => {
                                            if (item.loader && item.loader.item) {
                                                return item.loader.item[item.prop]
                                            }
                                            return false
                                        })
                }

                Connections {
                    function onShellitBarTransparencyChanged() {
                        topBarCore.backgroundTransparency = SettingsData.ShellitBarTransparency
                    }

                    target: SettingsData
                }

                Connections {
                    target: topBarMouseArea
                    function onContainsMouseChanged() {
                        if (topBarMouseArea.containsMouse) {
                            topBarCore.revealSticky = true
                            revealHold.stop()
                        } else {
                            if (topBarCore.autoHide && !topBarCore.hasActivePopout) {
                                revealHold.restart()
                            }
                        }
                    }
                }

                onHasActivePopoutChanged: {
                    if (!hasActivePopout && autoHide && !topBarMouseArea.containsMouse) {
                        revealSticky = true
                        revealHold.restart()
                    }
                }

                MouseArea {
                    id: topBarMouseArea
                    y: !barWindow.isVertical ? (SettingsData.ShellitBarPosition === SettingsData.Position.Bottom ? parent.height - height : 0) : 0
                    x: barWindow.isVertical ? (SettingsData.ShellitBarPosition === SettingsData.Position.Right ? parent.width - width : 0) : 0
                    height: !barWindow.isVertical ? Theme.px(barWindow.effectiveBarThickness + SettingsData.ShellitBarSpacing, barWindow._dpr) : undefined
                    width: barWindow.isVertical ? Theme.px(barWindow.effectiveBarThickness + SettingsData.ShellitBarSpacing, barWindow._dpr) : undefined
                    anchors {
                        left: !barWindow.isVertical ? parent.left : (SettingsData.ShellitBarPosition === SettingsData.Position.Left ? parent.left : undefined)
                        right: !barWindow.isVertical ? parent.right : (SettingsData.ShellitBarPosition === SettingsData.Position.Right ? parent.right : undefined)
                        top: barWindow.isVertical ? parent.top : undefined
                        bottom: barWindow.isVertical ? parent.bottom : undefined
                    }
                    readonly property bool inOverview: CompositorService.isNiri && NiriService.inOverview && SettingsData.ShellitBarOpenOnOverview
                    hoverEnabled: SettingsData.ShellitBarAutoHide && !topBarCore.reveal && !inOverview
                    acceptedButtons: Qt.NoButton
                    enabled: SettingsData.ShellitBarAutoHide && !topBarCore.reveal && !inOverview

                    Item {
                        id: topBarContainer
                        anchors.fill: parent

                        transform: Translate {
                            id: topBarSlide
                            x: barWindow.isVertical ? Theme.snap(topBarCore.reveal ? 0 : (SettingsData.ShellitBarPosition === SettingsData.Position.Right ? barWindow.implicitWidth : -barWindow.implicitWidth), barWindow._dpr) : 0
                            y: !barWindow.isVertical ? Theme.snap(topBarCore.reveal ? 0 : (SettingsData.ShellitBarPosition === SettingsData.Position.Bottom ? barWindow.implicitHeight : -barWindow.implicitHeight), barWindow._dpr) : 0

                            Behavior on x {
                                NumberAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on y {
                                NumberAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Item {
                            id: barUnitInset
                            anchors.fill: parent
                            anchors.leftMargin: !barWindow.isVertical ? Theme.px(SettingsData.ShellitBarSpacing, barWindow._dpr) : (axis.edge === "left" ? Theme.px(SettingsData.ShellitBarSpacing, barWindow._dpr) : 0)
                            anchors.rightMargin: !barWindow.isVertical ? Theme.px(SettingsData.ShellitBarSpacing, barWindow._dpr) : (axis.edge === "right" ? Theme.px(SettingsData.ShellitBarSpacing, barWindow._dpr) : 0)
                            anchors.topMargin: barWindow.isVertical ? Theme.px(SettingsData.ShellitBarSpacing, barWindow._dpr) : (axis.outerVisualEdge() === "bottom" ? 0 : Theme.px(SettingsData.ShellitBarSpacing, barWindow._dpr))
                            anchors.bottomMargin: barWindow.isVertical ? Theme.px(SettingsData.ShellitBarSpacing, barWindow._dpr) : (axis.outerVisualEdge() === "bottom" ? Theme.px(SettingsData.ShellitBarSpacing, barWindow._dpr) : 0)

                            BarCanvas {
                                id: barBackground
                                barWindow: barWindow
                                axis: axis
                            }

                            Item {
                                id: topBarContent
                                anchors.fill: parent
                                anchors.leftMargin: !barWindow.isVertical ? Math.max(Theme.spacingXS, SettingsData.ShellitBarInnerPadding * 0.8) : SettingsData.ShellitBarInnerPadding / 2
                                anchors.rightMargin: !barWindow.isVertical ? Math.max(Theme.spacingXS, SettingsData.ShellitBarInnerPadding * 0.8) : SettingsData.ShellitBarInnerPadding / 2
                                anchors.topMargin: !barWindow.isVertical ? 0 : Math.max(Theme.spacingXS, SettingsData.ShellitBarInnerPadding * 0.8)
                                anchors.bottomMargin: !barWindow.isVertical ? 0 : Math.max(Theme.spacingXS, SettingsData.ShellitBarInnerPadding * 0.8)
                                clip: false

                                property int componentMapRevision: 0

                                function updateComponentMap() {
                                    componentMapRevision++
                                }

                                readonly property int availableWidth: width
                                readonly property int launcherButtonWidth: 40
                                readonly property int workspaceSwitcherWidth: 120
                                readonly property int focusedAppMaxWidth: 456
                                readonly property int estimatedLeftSectionWidth: launcherButtonWidth + workspaceSwitcherWidth + focusedAppMaxWidth + (Theme.spacingXS * 2)
                                readonly property int rightSectionWidth: 200
                                readonly property int clockWidth: 120
                                readonly property int mediaMaxWidth: 280
                                readonly property int weatherWidth: 80
                                readonly property bool validLayout: availableWidth > 100 && estimatedLeftSectionWidth > 0 && rightSectionWidth > 0
                                readonly property int clockLeftEdge: (availableWidth - clockWidth) / 2
                                readonly property int clockRightEdge: clockLeftEdge + clockWidth
                                readonly property int leftSectionRightEdge: estimatedLeftSectionWidth
                                readonly property int mediaLeftEdge: clockLeftEdge - mediaMaxWidth - Theme.spacingS
                                readonly property int rightSectionLeftEdge: availableWidth - rightSectionWidth
                                readonly property int leftToClockGap: Math.max(0, clockLeftEdge - leftSectionRightEdge)
                                readonly property int leftToMediaGap: mediaMaxWidth > 0 ? Math.max(0, mediaLeftEdge - leftSectionRightEdge) : leftToClockGap
                                readonly property int mediaToClockGap: mediaMaxWidth > 0 ? Theme.spacingS : 0
                                readonly property int clockToRightGap: validLayout ? Math.max(0, rightSectionLeftEdge - clockRightEdge) : 1000
                                readonly property bool spacingTight: !barWindow.isVertical && validLayout && (leftToMediaGap < 150 || clockToRightGap < 100)
                                readonly property bool overlapping: !barWindow.isVertical && validLayout && (leftToMediaGap < 100 || clockToRightGap < 50)

                                function getWidgetEnabled(enabled) {
                                    return enabled !== false
                                }

                                function getWidgetSection(parentItem) {
                                    let current = parentItem
                                    while (current) {
                                        if (current.objectName === "leftSection") {
                                            return "left"
                                        }
                                        if (current.objectName === "centerSection") {
                                            return "center"
                                        }
                                        if (current.objectName === "rightSection") {
                                            return "right"
                                        }
                                        current = current.parent
                                    }
                                    return "left"
                                }

                                readonly property var widgetVisibility: ({
                                                                             "cpuUsage": DgopService.dgopAvailable,
                                                                             "memUsage": DgopService.dgopAvailable,
                                                                             "cpuTemp": DgopService.dgopAvailable,
                                                                             "gpuTemp": DgopService.dgopAvailable,
                                                                             "network_speed_monitor": DgopService.dgopAvailable
                                                                         })

                                function getWidgetVisible(widgetId) {
                                    return widgetVisibility[widgetId] ?? true
                                }

                                readonly property var componentMap: {
                                    // This property depends on componentMapRevision to ensure it updates when plugins change
                                    componentMapRevision

                                    let baseMap = {
                                        "launcherButton": launcherButtonComponent,
                                        "workspaceSwitcher": workspaceSwitcherComponent,
                                        "focusedWindow": focusedWindowComponent,
                                        "runningApps": runningAppsComponent,
                                        "clock": clockComponent,
                                        "music": mediaComponent,
                                        "weather": weatherComponent,
                                        "systemTray": systemTrayComponent,
                                        "privacyIndicator": privacyIndicatorComponent,
                                        "clipboard": clipboardComponent,
                                        "cpuUsage": cpuUsageComponent,
                                        "memUsage": memUsageComponent,
                                        "diskUsage": diskUsageComponent,
                                        "cpuTemp": cpuTempComponent,
                                        "gpuTemp": gpuTempComponent,
                                        "notificationButton": notificationButtonComponent,
                                        "battery": batteryComponent,
                                        "controlCenterButton": controlCenterButtonComponent,
                                        "idleInhibitor": idleInhibitorComponent,
                                        "spacer": spacerComponent,
                                        "separator": separatorComponent,
                                        "network_speed_monitor": networkComponent,
                                        "keyboard_layout_name": keyboardLayoutNameComponent,
                                        "vpn": vpnComponent,
                                        "notepadButton": notepadButtonComponent,
                                        "colorPicker": colorPickerComponent,
                                        "systemUpdate": systemUpdateComponent
                                    }

                                    // Merge with plugin widgets
                                    let pluginMap = PluginService.getWidgetComponents()
                                    return Object.assign(baseMap, pluginMap)
                                }

                                function getWidgetComponent(widgetId) {
                                    return componentMap[widgetId] || null
                                }

                                readonly property var allComponents: ({
                                                                          "launcherButtonComponent": launcherButtonComponent,
                                                                          "workspaceSwitcherComponent": workspaceSwitcherComponent,
                                                                          "focusedWindowComponent": focusedWindowComponent,
                                                                          "runningAppsComponent": runningAppsComponent,
                                                                          "clockComponent": clockComponent,
                                                                          "mediaComponent": mediaComponent,
                                                                          "weatherComponent": weatherComponent,
                                                                          "systemTrayComponent": systemTrayComponent,
                                                                          "privacyIndicatorComponent": privacyIndicatorComponent,
                                                                          "clipboardComponent": clipboardComponent,
                                                                          "cpuUsageComponent": cpuUsageComponent,
                                                                          "memUsageComponent": memUsageComponent,
                                                                          "diskUsageComponent": diskUsageComponent,
                                                                          "cpuTempComponent": cpuTempComponent,
                                                                          "gpuTempComponent": gpuTempComponent,
                                                                          "notificationButtonComponent": notificationButtonComponent,
                                                                          "batteryComponent": batteryComponent,
                                                                          "controlCenterButtonComponent": controlCenterButtonComponent,
                                                                          "idleInhibitorComponent": idleInhibitorComponent,
                                                                          "spacerComponent": spacerComponent,
                                                                          "separatorComponent": separatorComponent,
                                                                          "networkComponent": networkComponent,
                                                                          "keyboardLayoutNameComponent": keyboardLayoutNameComponent,
                                                                          "vpnComponent": vpnComponent,
                                                                          "notepadButtonComponent": notepadButtonComponent,
                                                                          "colorPickerComponent": colorPickerComponent,
                                                                          "systemUpdateComponent": systemUpdateComponent
                                                                      })

                                Item {
                                    id: stackContainer
                                    anchors.fill: parent

                                    Item {
                                        id: horizontalStack
                                        anchors.fill: parent
                                        visible: !axis.isVertical

                                        LeftSection {
                                            id: hLeftSection
                                            objectName: "leftSection"
                                            overrideAxisLayout: true
                                            forceVerticalLayout: false
                                            anchors {
                                                left: parent.left
                                                verticalCenter: parent.verticalCenter
                                            }
                                            axis: axis
                                            widgetsModel: SettingsData.ShellitBarLeftWidgetsModel
                                            components: topBarContent.allComponents
                                            noBackground: SettingsData.ShellitBarNoBackground
                                            parentScreen: barWindow.screen
                                            widgetThickness: barWindow.widgetThickness
                                            barThickness: barWindow.effectiveBarThickness
                                        }

                                        RightSection {
                                            id: hRightSection
                                            objectName: "rightSection"
                                            overrideAxisLayout: true
                                            forceVerticalLayout: false
                                            anchors {
                                                right: parent.right
                                                verticalCenter: parent.verticalCenter
                                            }
                                            axis: axis
                                            widgetsModel: SettingsData.ShellitBarRightWidgetsModel
                                            components: topBarContent.allComponents
                                            noBackground: SettingsData.ShellitBarNoBackground
                                            parentScreen: barWindow.screen
                                            widgetThickness: barWindow.widgetThickness
                                            barThickness: barWindow.effectiveBarThickness
                                        }

                                        CenterSection {
                                            id: hCenterSection
                                            objectName: "centerSection"
                                            overrideAxisLayout: true
                                            forceVerticalLayout: false
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                                horizontalCenter: parent.horizontalCenter
                                            }
                                            axis: axis
                                            widgetsModel: SettingsData.ShellitBarCenterWidgetsModel
                                            components: topBarContent.allComponents
                                            noBackground: SettingsData.ShellitBarNoBackground
                                            parentScreen: barWindow.screen
                                            widgetThickness: barWindow.widgetThickness
                                            barThickness: barWindow.effectiveBarThickness
                                        }
                                    }

                                    Item {
                                        id: verticalStack
                                        anchors.fill: parent
                                        visible: axis.isVertical

                                        LeftSection {
                                            id: vLeftSection
                                            objectName: "leftSection"
                                            overrideAxisLayout: true
                                            forceVerticalLayout: true
                                            width: parent.width
                                            anchors {
                                                top: parent.top
                                                horizontalCenter: parent.horizontalCenter
                                            }
                                            axis: axis
                                            widgetsModel: SettingsData.ShellitBarLeftWidgetsModel
                                            components: topBarContent.allComponents
                                            noBackground: SettingsData.ShellitBarNoBackground
                                            parentScreen: barWindow.screen
                                            widgetThickness: barWindow.widgetThickness
                                            barThickness: barWindow.effectiveBarThickness
                                        }

                                        CenterSection {
                                            id: vCenterSection
                                            objectName: "centerSection"
                                            overrideAxisLayout: true
                                            forceVerticalLayout: true
                                            width: parent.width
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                                horizontalCenter: parent.horizontalCenter
                                            }
                                            axis: axis
                                            widgetsModel: SettingsData.ShellitBarCenterWidgetsModel
                                            components: topBarContent.allComponents
                                            noBackground: SettingsData.ShellitBarNoBackground
                                            parentScreen: barWindow.screen
                                            widgetThickness: barWindow.widgetThickness
                                            barThickness: barWindow.effectiveBarThickness
                                        }

                                        RightSection {
                                            id: vRightSection
                                            objectName: "rightSection"
                                            overrideAxisLayout: true
                                            forceVerticalLayout: true
                                            width: parent.width
                                            height: implicitHeight
                                            anchors {
                                                bottom: parent.bottom
                                                horizontalCenter: parent.horizontalCenter
                                            }
                                            axis: axis
                                            widgetsModel: SettingsData.ShellitBarRightWidgetsModel
                                            components: topBarContent.allComponents
                                            noBackground: SettingsData.ShellitBarNoBackground
                                            parentScreen: barWindow.screen
                                            widgetThickness: barWindow.widgetThickness
                                            barThickness: barWindow.effectiveBarThickness
                                        }
                                    }
                                }

                                Component {
                                    id: clipboardComponent

                                    ClipboardButton {
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent)
                                        parentScreen: barWindow.screen
                                        onClicked: {
                                            clipboardHistoryModalPopup.toggle()
                                        }
                                    }
                                }

                                Component {
                                    id: launcherButtonComponent

                                    LauncherButton {
                                        id: launcherButton
                                        isActive: false
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        section: topBarContent.getWidgetSection(parent)
                                        popoutTarget: appDrawerLoader.item
                                        parentScreen: barWindow.screen
                                        hyprlandOverviewLoader: root.hyprlandOverviewLoader
                                        onClicked: {
                                            appDrawerLoader.active = true
                                            if (appDrawerLoader.item && appDrawerLoader.item.setTriggerPosition) {
                                                const globalPos = launcherButton.visualContent.mapToGlobal(0, 0)
                                                const currentScreen = barWindow.screen
                                                const pos = SettingsData.getPopupTriggerPosition(globalPos, currentScreen, barWindow.effectiveBarThickness, launcherButton.visualWidth)
                                                appDrawerLoader.item.setTriggerPosition(pos.x, pos.y, pos.width, launcherButton.section, currentScreen)
                                            }
                                            appDrawerLoader.item?.toggle()
                                        }
                                    }
                                }

                                Component {
                                    id: workspaceSwitcherComponent

                                    WorkspaceSwitcher {
                                        axis: barWindow.axis
                                        screenName: barWindow.screenName
                                        widgetHeight: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        parentScreen: barWindow.screen
                                        hyprlandOverviewLoader: root.hyprlandOverviewLoader
                                    }
                                }

                                Component {
                                    id: focusedWindowComponent

                                    FocusedApp {
                                        axis: barWindow.axis
                                        availableWidth: topBarContent.leftToMediaGap
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        parentScreen: barWindow.screen
                                    }
                                }

                                Component {
                                    id: runningAppsComponent

                                    RunningApps {
                                        widgetThickness: barWindow.widgetThickness
                                        section: topBarContent.getWidgetSection(parent)
                                        parentScreen: barWindow.screen
                                        topBar: topBarContent
                                    }
                                }

                                Component {
                                    id: clockComponent

                                    Clock {
                                        axis: barWindow.axis
                                        compactMode: topBarContent.overlapping
                                        barThickness: barWindow.effectiveBarThickness
                                        widgetThickness: barWindow.widgetThickness
                                        section: topBarContent.getWidgetSection(parent) || "center"
                                        popoutTarget: {
                                            ShellitDashPopoutLoader.active = true
                                            return ShellitDashPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen

                                        Component.onCompleted: {
                                            barWindow.clockButtonRef = this
                                        }

                                        Component.onDestruction: {
                                            if (barWindow.clockButtonRef === this) {
                                                barWindow.clockButtonRef = null
                                            }
                                        }

                                        onClockClicked: {
                                            ShellitDashPopoutLoader.active = true
                                            if (ShellitDashPopoutLoader.item) {
                                                ShellitDashPopoutLoader.item.dashVisible = !ShellitDashPopoutLoader.item.dashVisible
                                                ShellitDashPopoutLoader.item.currentTabIndex = 0
                                            }
                                        }
                                    }
                                }

                                Component {
                                    id: mediaComponent

                                    Media {
                                        axis: barWindow.axis
                                        compactMode: topBarContent.spacingTight || topBarContent.overlapping
                                        barThickness: barWindow.effectiveBarThickness
                                        widgetThickness: barWindow.widgetThickness
                                        section: topBarContent.getWidgetSection(parent) || "center"
                                        popoutTarget: {
                                            ShellitDashPopoutLoader.active = true
                                            return ShellitDashPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        onClicked: {
                                            ShellitDashPopoutLoader.active = true
                                            if (ShellitDashPopoutLoader.item) {
                                                ShellitDashPopoutLoader.item.dashVisible = !ShellitDashPopoutLoader.item.dashVisible
                                                ShellitDashPopoutLoader.item.currentTabIndex = 1
                                            }
                                        }
                                    }
                                }

                                Component {
                                    id: weatherComponent

                                    Weather {
                                        axis: barWindow.axis
                                        barThickness: barWindow.effectiveBarThickness
                                        widgetThickness: barWindow.widgetThickness
                                        section: topBarContent.getWidgetSection(parent) || "center"
                                        popoutTarget: {
                                            ShellitDashPopoutLoader.active = true
                                            return ShellitDashPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        onClicked: {
                                            ShellitDashPopoutLoader.active = true
                                            if (ShellitDashPopoutLoader.item) {
                                                ShellitDashPopoutLoader.item.dashVisible = !ShellitDashPopoutLoader.item.dashVisible
                                                ShellitDashPopoutLoader.item.currentTabIndex = 3
                                            }
                                        }
                                    }
                                }

                                Component {
                                    id: systemTrayComponent

                                    SystemTrayBar {
                                        parentWindow: root
                                        parentScreen: barWindow.screen
                                        widgetThickness: barWindow.widgetThickness
                                        isAtBottom: SettingsData.ShellitBarPosition === SettingsData.Position.Bottom
                                        visible: SettingsData.getFilteredScreens("systemTray").includes(barWindow.screen) && SystemTray.items.values.length > 0
                                    }
                                }

                                Component {
                                    id: privacyIndicatorComponent

                                    PrivacyIndicator {
                                        widgetThickness: barWindow.widgetThickness
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        parentScreen: barWindow.screen
                                    }
                                }

                                Component {
                                    id: cpuUsageComponent

                                    CpuMonitor {
                                        barThickness: barWindow.effectiveBarThickness
                                        widgetThickness: barWindow.widgetThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            processListPopoutLoader.active = true
                                            return processListPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        widgetData: parent.widgetData
                                        toggleProcessList: () => {
                                                               processListPopoutLoader.active = true
                                                               return processListPopoutLoader.item?.toggle()
                                                           }
                                    }
                                }

                                Component {
                                    id: memUsageComponent

                                    RamMonitor {
                                        barThickness: barWindow.effectiveBarThickness
                                        widgetThickness: barWindow.widgetThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            processListPopoutLoader.active = true
                                            return processListPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        widgetData: parent.widgetData
                                        toggleProcessList: () => {
                                                               processListPopoutLoader.active = true
                                                               return processListPopoutLoader.item?.toggle()
                                                           }
                                    }
                                }

                                Component {
                                    id: diskUsageComponent

                                    DiskUsage {
                                        widgetThickness: barWindow.widgetThickness
                                        widgetData: parent.widgetData
                                        parentScreen: barWindow.screen
                                    }
                                }

                                Component {
                                    id: cpuTempComponent

                                    CpuTemperature {
                                        barThickness: barWindow.effectiveBarThickness
                                        widgetThickness: barWindow.widgetThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            processListPopoutLoader.active = true
                                            return processListPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        widgetData: parent.widgetData
                                        toggleProcessList: () => {
                                                               processListPopoutLoader.active = true
                                                               return processListPopoutLoader.item?.toggle()
                                                           }
                                    }
                                }

                                Component {
                                    id: gpuTempComponent

                                    GpuTemperature {
                                        barThickness: barWindow.effectiveBarThickness
                                        widgetThickness: barWindow.widgetThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            processListPopoutLoader.active = true
                                            return processListPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        widgetData: parent.widgetData
                                        toggleProcessList: () => {
                                                               processListPopoutLoader.active = true
                                                               return processListPopoutLoader.item?.toggle()
                                                           }
                                    }
                                }

                                Component {
                                    id: networkComponent

                                    NetworkMonitor {}
                                }

                                Component {
                                    id: notificationButtonComponent

                                    NotificationCenterButton {
                                        hasUnread: barWindow.notificationCount > 0
                                        isActive: notificationCenterLoader.item ? notificationCenterLoader.item.shouldBeVisible : false
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            notificationCenterLoader.active = true
                                            return notificationCenterLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        onClicked: {
                                            notificationCenterLoader.active = true
                                            notificationCenterLoader.item?.toggle()
                                        }
                                    }
                                }

                                Component {
                                    id: batteryComponent

                                    Battery {
                                        batteryPopupVisible: batteryPopoutLoader.item ? batteryPopoutLoader.item.shouldBeVisible : false
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            batteryPopoutLoader.active = true
                                            return batteryPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        onToggleBatteryPopup: {
                                            batteryPopoutLoader.active = true
                                            batteryPopoutLoader.item?.toggle()
                                        }
                                    }
                                }

                                Component {
                                    id: vpnComponent

                                    Vpn {
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            vpnPopoutLoader.active = true
                                            return vpnPopoutLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        onToggleVpnPopup: {
                                            vpnPopoutLoader.active = true
                                            vpnPopoutLoader.item?.toggle()
                                        }
                                    }
                                }

                                Component {
                                    id: controlCenterButtonComponent

                                    ControlCenterButton {
                                        isActive: controlCenterLoader.item ? controlCenterLoader.item.shouldBeVisible : false
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            controlCenterLoader.active = true
                                            return controlCenterLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        widgetData: parent.widgetData

                                        Component.onCompleted: {
                                            barWindow.controlCenterButtonRef = this
                                        }

                                        Component.onDestruction: {
                                            if (barWindow.controlCenterButtonRef === this) {
                                                barWindow.controlCenterButtonRef = null
                                            }
                                        }

                                        onClicked: {
                                            controlCenterLoader.active = true
                                            if (!controlCenterLoader.item) {
                                                return
                                            }
                                            controlCenterLoader.item.triggerScreen = barWindow.screen
                                            controlCenterLoader.item.toggle()
                                            if (controlCenterLoader.item.shouldBeVisible && NetworkService.wifiEnabled) {
                                                NetworkService.scanWifi()
                                            }
                                        }
                                    }
                                }

                                Component {
                                    id: idleInhibitorComponent

                                    IdleInhibitor {
                                        widgetThickness: barWindow.widgetThickness
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        parentScreen: barWindow.screen
                                    }
                                }

                                Component {
                                    id: spacerComponent

                                    Item {
                                        width: barWindow.isVertical ? barWindow.widgetThickness : (parent.spacerSize || 20)
                                        height: barWindow.isVertical ? (parent.spacerSize || 20) : barWindow.widgetThickness
                                        implicitWidth: width
                                        implicitHeight: height

                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                            border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
                                            border.width: 1
                                            radius: 2
                                            visible: false

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                acceptedButtons: Qt.NoButton // do not consume clicks
                                                propagateComposedEvents: true // let events pass through
                                                cursorShape: Qt.ArrowCursor // don't override widget cursors
                                                onEntered: parent.visible = true
                                                onExited: parent.visible = false
                                            }
                                        }
                                    }
                                }

                                Component {
                                    id: separatorComponent

                                    Item {
                                        width: barWindow.isVertical ? parent.barThickness : 1
                                        height: barWindow.isVertical ? 1 : parent.barThickness
                                        implicitWidth: width
                                        implicitHeight: height

                                        Rectangle {
                                            width: barWindow.isVertical ? parent.width * 0.6 : 1
                                            height: barWindow.isVertical ? 1 : parent.height * 0.6
                                            anchors.centerIn: parent
                                            color: Theme.outline
                                            opacity: 0.3
                                        }
                                    }
                                }

                                Component {
                                    id: keyboardLayoutNameComponent

                                    KeyboardLayoutName {}
                                }

                                Component {
                                    id: notepadButtonComponent

                                    NotepadButton {
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        parentScreen: barWindow.screen
                                    }
                                }

                                Component {
                                    id: colorPickerComponent

                                    ColorPicker {
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        parentScreen: barWindow.screen
                                        onColorPickerRequested: {
                                            barWindow.colorPickerRequested()
                                        }
                                    }
                                }

                                Component {
                                    id: systemUpdateComponent

                                    SystemUpdate {
                                        isActive: systemUpdateLoader.item ? systemUpdateLoader.item.shouldBeVisible : false
                                        widgetThickness: barWindow.widgetThickness
                                        barThickness: barWindow.effectiveBarThickness
                                        axis: barWindow.axis
                                        section: topBarContent.getWidgetSection(parent) || "right"
                                        popoutTarget: {
                                            systemUpdateLoader.active = true
                                            return systemUpdateLoader.item
                                        }
                                        parentScreen: barWindow.screen
                                        onClicked: {
                                            systemUpdateLoader.active = true
                                            systemUpdateLoader.item?.toggle()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
