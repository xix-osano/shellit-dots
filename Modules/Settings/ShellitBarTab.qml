import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: shellitBarTab

    property var parentModal: null

    function getWidgetsForPopup() {
        return baseWidgetDefinitions.filter(widget => {
            if (widget.warning && widget.warning.includes("Plugin is disabled")) {
                return false
            }
            return true
        })
    }

    property var baseWidgetDefinitions: {
        var coreWidgets = [{
            "id": "launcherButton",
            "text": "App Launcher",
            "description": "Quick access to application launcher",
            "icon": "apps",
            "enabled": true
        }, {
            "id": "workspaceSwitcher",
            "text": "Workspace Switcher",
            "description": "Shows current workspace and allows switching",
            "icon": "view_module",
            "enabled": true
        }, {
            "id": "focusedWindow",
            "text": "Focused Window",
            "description": "Display currently focused application title",
            "icon": "window",
            "enabled": true
        }, {
            "id": "runningApps",
            "text": "Running Apps",
            "description": "Shows all running applications with focus indication",
            "icon": "apps",
            "enabled": true
        }, {
            "id": "clock",
            "text": "Clock",
            "description": "Current time and date display",
            "icon": "schedule",
            "enabled": true
        }, {
            "id": "weather",
            "text": "Weather Widget",
            "description": "Current weather conditions and temperature",
            "icon": "wb_sunny",
            "enabled": true
        }, {
            "id": "music",
            "text": "Media Controls",
            "description": "Control currently playing media",
            "icon": "music_note",
            "enabled": true
        }, {
            "id": "clipboard",
            "text": "Clipboard Manager",
            "description": "Access clipboard history",
            "icon": "content_paste",
            "enabled": true
        }, {
            "id": "cpuUsage",
            "text": "CPU Usage",
            "description": "CPU usage indicator",
            "icon": "memory",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined
        }, {
            "id": "memUsage",
            "text": "Memory Usage",
            "description": "Memory usage indicator",
            "icon": "developer_board",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined
        }, {
            "id": "diskUsage",
            "text": "Disk Usage",
            "description": "Percentage",
            "icon": "storage",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined
        }, {
            "id": "cpuTemp",
            "text": "CPU Temperature",
            "description": "CPU temperature display",
            "icon": "device_thermostat",
            "enabled": DgopService.dgopAvailable,
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined
        }, {
            "id": "gpuTemp",
            "text": "GPU Temperature",
            "description": "GPU temperature display",
            "icon": "auto_awesome_mosaic",
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : "This widget prevents GPU power off states, which can significantly impact battery life on laptops. It is not recommended to use this on laptops with hybrid graphics.",
            "enabled": DgopService.dgopAvailable
        }, {
            "id": "systemTray",
            "text": "System Tray",
            "description": "System notification area icons",
            "icon": "notifications",
            "enabled": true
        }, {
            "id": "privacyIndicator",
            "text": "Privacy Indicator",
            "description": "Shows when microphone, camera, or screen sharing is active",
            "icon": "privacy_tip",
            "enabled": true
        }, {
            "id": "controlCenterButton",
            "text": "Control Center",
            "description": "Access to system controls and settings",
            "icon": "settings",
            "enabled": true
        }, {
            "id": "notificationButton",
            "text": "Notification Center",
            "description": "Access to notifications and do not disturb",
            "icon": "notifications",
            "enabled": true
        }, {
            "id": "battery",
            "text": "Battery",
            "description": "Battery level and power management",
            "icon": "battery_std",
            "enabled": true
        }, {
            "id": "vpn",
            "text": "VPN",
            "description": "VPN status and quick connect",
            "icon": "vpn_lock",
            "enabled": true
        }, {
            "id": "idleInhibitor",
            "text": "Idle Inhibitor",
            "description": "Prevent screen timeout",
            "icon": "motion_sensor_active",
            "enabled": true
        }, {
            "id": "spacer",
            "text": "Spacer",
            "description": "Customizable empty space",
            "icon": "more_horiz",
            "enabled": true
        }, {
            "id": "separator",
            "text": "Separator",
            "description": "Visual divider between widgets",
            "icon": "remove",
            "enabled": true
        },
        {
            "id": "network_speed_monitor",
            "text": "Network Speed Monitor",
            "description": "Network download and upload speed display",
            "icon": "network_check",
            "warning": !DgopService.dgopAvailable ? "Requires 'dgop' tool" : undefined,
            "enabled": DgopService.dgopAvailable
        }, {
            "id": "keyboard_layout_name",
            "text": "Keyboard Layout Name",
            "description": "Displays the active keyboard layout and allows switching",
            "icon": "keyboard",
        }, {
            "id": "notepadButton",
            "text": "Notepad",
            "description": "Quick access to notepad",
            "icon": "assignment",
            "enabled": true
        }, {
            "id": "colorPicker",
            "text": "Color Picker",
            "description": "Quick access to color picker",
            "icon": "palette",
            "enabled": true
        }, {
            "id": "systemUpdate",
            "text": "System Update",
            "description": "Check for system updates",
            "icon": "update",
            "enabled": SystemUpdateService.distributionSupported
        }]

        var allPluginVariants = PluginService.getAllPluginVariants()
        for (var i = 0; i < allPluginVariants.length; i++) {
            var variant = allPluginVariants[i]
            coreWidgets.push({
                "id": variant.fullId,
                "text": variant.name,
                "description": variant.description,
                "icon": variant.icon,
                "enabled": variant.loaded,
                "warning": !variant.loaded ? "Plugin is disabled - enable in Plugins settings to use" : undefined
            })
        }

        return coreWidgets
    }
    property var defaultLeftWidgets: [{
            "id": "launcherButton",
            "enabled": true
        }, {
            "id": "workspaceSwitcher",
            "enabled": true
        }, {
            "id": "focusedWindow",
            "enabled": true
        }]
    property var defaultCenterWidgets: [{
            "id": "music",
            "enabled": true
        }, {
            "id": "clock",
            "enabled": true
        }, {
            "id": "weather",
            "enabled": true
        }]
    property var defaultRightWidgets: [{
            "id": "systemTray",
            "enabled": true
        }, {
            "id": "clipboard",
            "enabled": true
        }, {
            "id": "notificationButton",
            "enabled": true
        }, {
            "id": "battery",
            "enabled": true
        }, {
            "id": "controlCenterButton",
            "enabled": true
        }]

    function addWidgetToSection(widgetId, targetSection) {
        var widgetObj = {
            "id": widgetId,
            "enabled": true
        }
        if (widgetId === "spacer")
            widgetObj.size = 20
        if (widgetId === "gpuTemp") {
            widgetObj.selectedGpuIndex = 0
            widgetObj.pciId = ""
        }
        if (widgetId === "controlCenterButton") {
            widgetObj.showNetworkIcon = true
            widgetObj.showBluetoothIcon = true
            widgetObj.showAudioIcon = true
        }
        if (widgetId === "diskUsage") {
            widgetObj.mountPath = "/"
        }
        if (widgetId === "cpuUsage" || widgetId === "memUsage" || widgetId === "cpuTemp" || widgetId === "gpuTemp") {
            widgetObj.minimumWidth = true
        }

        var widgets = []
    Shellit    if (targetSection === "left") {
            widgets = SettingsData.shellitBarLeftWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setShellitBarLeftWidgets(widgets)
        } else if (targetSection === "center") {
            widgets = SettingsData.shellitBarCenterWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setShellitBarCenterWidgets(widgets)
        } else if (targetSection === "right") {
            widgets = SettingsData.shellitBarRightWidgets.slice()
            widgets.push(widgetObj)
            SettingsData.setShellitBarRightWidgets(widgets)
        }
    }

    function removeWidgetFromSection(sectionId, widgetIndex) {
        var widgets = []
        if (sectionId === "left") {
            widgets = SettingsData.shellitBarLeftWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setShellitBarLeftWidgets(widgets)
        } else if (sectionId === "center") {
            widgets = SettingsData.shellitBarCenterWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setShellitBarCenterWidgets(widgets)
        } else if (sectionId === "right") {
            widgets = SettingsData.shellitBarRightWidgets.slice()
            if (widgetIndex >= 0 && widgetIndex < widgets.length) {
                widgets.splice(widgetIndex, 1)
            }
            SettingsData.setShellitBarRightWidgets(widgets)
        }
    }

    function handleItemEnabledChanged(sectionId, itemId, enabled) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.shellitBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.shellitBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.shellitBarRightWidgets.slice()
        for (var i = 0; i < widgets.length; i++) {
            var widget = widgets[i]
            var widgetId = typeof widget === "string" ? widget : widget.id
            if (widgetId === itemId) {
                if (typeof widget === "string") {
                    widgets[i] = {
                        "id": widget,
                        "enabled": enabled
                    }
                } else {
                    var newWidget = {
                        "id": widget.id,
                        "enabled": enabled
                    }
                    if (widget.size !== undefined)
                        newWidget.size = widget.size
                    if (widget.selectedGpuIndex !== undefined)
                        newWidget.selectedGpuIndex = widget.selectedGpuIndex
                    else if (widget.id === "gpuTemp")
                        newWidget.selectedGpuIndex = 0
                    if (widget.pciId !== undefined)
                        newWidget.pciId = widget.pciId
                    else if (widget.id === "gpuTemp")
                        newWidget.pciId = ""
                    if (widget.id === "controlCenterButton") {
                        newWidget.showNetworkIcon = widget.showNetworkIcon !== undefined ? widget.showNetworkIcon : true
                        newWidget.showBluetoothIcon = widget.showBluetoothIcon !== undefined ? widget.showBluetoothIcon : true
                        newWidget.showAudioIcon = widget.showAudioIcon !== undefined ? widget.showAudioIcon : true
                    }
                    widgets[i] = newWidget
                }
                break
            }
        }
        if (sectionId === "left")
            SettingsData.setShellitBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setShellitBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setShellitBarRightWidgets(widgets)
    }

    function handleItemOrderChanged(sectionId, newOrder) {
        if (sectionId === "left")
            SettingsData.setShellitBarLeftWidgets(newOrder)
        else if (sectionId === "center")
            SettingsData.setShellitBarCenterWidgets(newOrder)
        else if (sectionId === "right")
            SettingsData.setShellitBarRightWidgets(newOrder)
    }

    function handleSpacerSizeChanged(sectionId, widgetIndex, newSize) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.shellitBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.shellitBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.shellitBarRightWidgets.slice()

        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            var widgetId = typeof widget === "string" ? widget : widget.id
            if (widgetId === "spacer") {
                if (typeof widget === "string") {
                    widgets[widgetIndex] = {
                        "id": widget,
                        "enabled": true,
                        "size": newSize
                    }
                } else {
                    var newWidget = {
                        "id": widget.id,
                        "enabled": widget.enabled,
                        "size": newSize
                    }
                    if (widget.selectedGpuIndex !== undefined)
                        newWidget.selectedGpuIndex = widget.selectedGpuIndex
                    if (widget.pciId !== undefined)
                        newWidget.pciId = widget.pciId
                    if (widget.id === "controlCenterButton") {
                        newWidget.showNetworkIcon = widget.showNetworkIcon !== undefined ? widget.showNetworkIcon : true
                        newWidget.showBluetoothIcon = widget.showBluetoothIcon !== undefined ? widget.showBluetoothIcon : true
                        newWidget.showAudioIcon = widget.showAudioIcon !== undefined ? widget.showAudioIcon : true
                    }
                    widgets[widgetIndex] = newWidget
                }
            }
        }

        if (sectionId === "left")
            SettingsData.setShellitBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setShellitBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setShellitBarRightWidgets(widgets)
    }

    function handleGpuSelectionChanged(sectionId, widgetIndex, selectedGpuIndex) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.shellitBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.shellitBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.shellitBarRightWidgets.slice()

        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            if (typeof widget === "string") {
                widgets[widgetIndex] = {
                    "id": widget,
                    "enabled": true,
                    "selectedGpuIndex": selectedGpuIndex,
                    "pciId": DgopService.availableGpus
                             && DgopService.availableGpus.length
                             > selectedGpuIndex ? DgopService.availableGpus[selectedGpuIndex].pciId : ""
                }
            } else {
                var newWidget = {
                    "id": widget.id,
                    "enabled": widget.enabled,
                    "selectedGpuIndex": selectedGpuIndex,
                    "pciId": DgopService.availableGpus
                             && DgopService.availableGpus.length
                             > selectedGpuIndex ? DgopService.availableGpus[selectedGpuIndex].pciId : ""
                }
                if (widget.size !== undefined)
                    newWidget.size = widget.size
                widgets[widgetIndex] = newWidget
            }
        }

        if (sectionId === "left")
            SettingsData.setShellitBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setShellitBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setShellitBarRightWidgets(widgets)
    }

    function handleDiskMountSelectionChanged(sectionId, widgetIndex, mountPath) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.shellitBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.shellitBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.shellitBarRightWidgets.slice()

        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            if (typeof widget === "string") {
                widgets[widgetIndex] = {
                    "id": widget,
                    "enabled": true,
                    "mountPath": mountPath
                }
            } else {
                var newWidget = {
                    "id": widget.id,
                    "enabled": widget.enabled,
                    "mountPath": mountPath
                }
                if (widget.size !== undefined)
                    newWidget.size = widget.size
                if (widget.selectedGpuIndex !== undefined)
                    newWidget.selectedGpuIndex = widget.selectedGpuIndex
                if (widget.pciId !== undefined)
                    newWidget.pciId = widget.pciId
                if (widget.id === "controlCenterButton") {
                    newWidget.showNetworkIcon = widget.showNetworkIcon !== undefined ? widget.showNetworkIcon : true
                    newWidget.showBluetoothIcon = widget.showBluetoothIcon !== undefined ? widget.showBluetoothIcon : true
                    newWidget.showAudioIcon = widget.showAudioIcon !== undefined ? widget.showAudioIcon : true
                }
                widgets[widgetIndex] = newWidget
            }
        }

        if (sectionId === "left")
            SettingsData.setShellitBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setShellitBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setShellitBarRightWidgets(widgets)
    }

    function handleControlCenterSettingChanged(sectionId, widgetIndex, settingName, value) {
        // Control Center settings are global, not per-widget instance
        if (settingName === "showNetworkIcon") {
            SettingsData.setControlCenterShowNetworkIcon(value)
        } else if (settingName === "showBluetoothIcon") {
            SettingsData.setControlCenterShowBluetoothIcon(value)
        } else if (settingName === "showAudioIcon") {
            SettingsData.setControlCenterShowAudioIcon(value)
        }
    }

    function handleMinimumWidthChanged(sectionId, widgetIndex, enabled) {
        var widgets = []
        if (sectionId === "left")
            widgets = SettingsData.shellitBarLeftWidgets.slice()
        else if (sectionId === "center")
            widgets = SettingsData.shellitBarCenterWidgets.slice()
        else if (sectionId === "right")
            widgets = SettingsData.shellitBarRightWidgets.slice()

        if (widgetIndex >= 0 && widgetIndex < widgets.length) {
            var widget = widgets[widgetIndex]
            if (typeof widget === "string") {
                widgets[widgetIndex] = {
                    "id": widget,
                    "enabled": true,
                    "minimumWidth": enabled
                }
            } else {
                var newWidget = {
                    "id": widget.id,
                    "enabled": widget.enabled,
                    "minimumWidth": enabled
                }
                if (widget.size !== undefined)
                    newWidget.size = widget.size
                if (widget.selectedGpuIndex !== undefined)
                    newWidget.selectedGpuIndex = widget.selectedGpuIndex
                if (widget.pciId !== undefined)
                    newWidget.pciId = widget.pciId
                if (widget.mountPath !== undefined)
                    newWidget.mountPath = widget.mountPath
                if (widget.id === "controlCenterButton") {
                    newWidget.showNetworkIcon = widget.showNetworkIcon !== undefined ? widget.showNetworkIcon : true
                    newWidget.showBluetoothIcon = widget.showBluetoothIcon !== undefined ? widget.showBluetoothIcon : true
                    newWidget.showAudioIcon = widget.showAudioIcon !== undefined ? widget.showAudioIcon : true
                }
                widgets[widgetIndex] = newWidget
            }
        }

        if (sectionId === "left")
            SettingsData.setShellitBarLeftWidgets(widgets)
        else if (sectionId === "center")
            SettingsData.setShellitBarCenterWidgets(widgets)
        else if (sectionId === "right")
            SettingsData.setShellitBarRightWidgets(widgets)
    }

    function getItemsForSection(sectionId) {
        var widgets = []
        var widgetData = []
        if (sectionId === "left")
            widgetData = SettingsData.shellitBarLeftWidgets || []
        else if (sectionId === "center")
            widgetData = SettingsData.shellitBarCenterWidgets || []
        else if (sectionId === "right")
            widgetData = SettingsData.shellitBarRightWidgets || []
        widgetData.forEach(widget => {
                               var widgetId = typeof widget === "string" ? widget : widget.id
                               var widgetEnabled = typeof widget
                               === "string" ? true : widget.enabled
                               var widgetSize = typeof widget === "string" ? undefined : widget.size
                               var widgetSelectedGpuIndex = typeof widget
                               === "string" ? undefined : widget.selectedGpuIndex
                               var widgetPciId = typeof widget
                               === "string" ? undefined : widget.pciId
                               var widgetMountPath = typeof widget
                               === "string" ? undefined : widget.mountPath
                               var widgetShowNetworkIcon = typeof widget === "string" ? undefined : widget.showNetworkIcon
                               var widgetShowBluetoothIcon = typeof widget === "string" ? undefined : widget.showBluetoothIcon
                               var widgetShowAudioIcon = typeof widget === "string" ? undefined : widget.showAudioIcon
                               var widgetMinimumWidth = typeof widget === "string" ? undefined : widget.minimumWidth
                               var widgetDef = baseWidgetDefinitions.find(w => {
                                                                              return w.id === widgetId
                                                                          })
                               if (widgetDef) {
                                   var item = Object.assign({}, widgetDef)
                                   item.enabled = widgetEnabled
                                   if (widgetSize !== undefined)
                                   item.size = widgetSize
                                   if (widgetSelectedGpuIndex !== undefined)
                                   item.selectedGpuIndex = widgetSelectedGpuIndex
                                   if (widgetPciId !== undefined)
                                   item.pciId = widgetPciId
                                   if (widgetMountPath !== undefined)
                                   item.mountPath = widgetMountPath
                                   if (widgetShowNetworkIcon !== undefined)
                                   item.showNetworkIcon = widgetShowNetworkIcon
                                   if (widgetShowBluetoothIcon !== undefined)
                                   item.showBluetoothIcon = widgetShowBluetoothIcon
                                   if (widgetShowAudioIcon !== undefined)
                                   item.showAudioIcon = widgetShowAudioIcon
                                   if (widgetMinimumWidth !== undefined)
                                   item.minimumWidth = widgetMinimumWidth

                                   widgets.push(item)
                               }
                           })
        return widgets
    }

    Component.onCompleted: {
        // Only set defaults if widgets have never been configured (null/undefined, not empty array)
        if (!SettingsData.shellitBarLeftWidgets)
            SettingsData.setShellitBarLeftWidgets(defaultLeftWidgets)

        if (!SettingsData.shellitBarCenterWidgets)
            SettingsData.setShellitBarCenterWidgets(defaultCenterWidgets)

        if (!SettingsData.shellitBarRightWidgets)
            SettingsData.setShellitBarRightWidgets(defaultRightWidgets)
        const sections = ["left", "center", "right"]
        sections.forEach(sectionId => {
                             var widgets = []
                             if (sectionId === "left")
                             widgets = SettingsData.shellitBarLeftWidgets.slice()
                             else if (sectionId === "center")
                             widgets = SettingsData.shellitBarCenterWidgets.slice()
                             else if (sectionId === "right")
                             widgets = SettingsData.shellitBarRightWidgets.slice()
                             var updated = false
                             for (var i = 0; i < widgets.length; i++) {
                                 var widget = widgets[i]
                                 if (typeof widget === "object"
                                     && widget.id === "spacer"
                                     && !widget.size) {
                                     widgets[i] = Object.assign({}, widget, {
                                                                    "size": 20
                                                                })
                                     updated = true
                                 }
                             }
                             if (updated) {
                                 if (sectionId === "left")
                                 SettingsData.setShellitBarLeftWidgets(widgets)
                                 else if (sectionId === "center")
                                 SettingsData.setShellitBarCenterWidgets(widgets)
                                 else if (sectionId === "right")
                                 SettingsData.setShellitBarRightWidgets(widgets)
                             }
                         })
    }

    ShellitFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        anchors.bottomMargin: Theme.spacingS
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            // Position Section
            StyledRect {
                width: parent.width
                height: positionSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: positionSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "vertical_align_center"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Position"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ShellitButtonGroup {
                            id: positionButtonGroup
                            anchors.verticalCenter: parent.verticalCenter
                            model: ["Top", "Bottom", "Left", "Right"]
                            currentIndex: {
                                switch (SettingsData.shellitBarPosition) {
                                    case SettingsData.Position.Top: return 0
                                    case SettingsData.Position.Bottom: return 1
                                    case SettingsData.Position.Left: return 2
                                    case SettingsData.Position.Right: return 3
                                    default: return 0
                                }
                            }
                            onSelectionChanged: (index, selected) => {
                                if (selected) {
                                    switch (index) {
                                        case 0: SettingsData.setShellitBarPosition(SettingsData.Position.Top); break
                                        case 1: SettingsData.setShellitBarPosition(SettingsData.Position.Bottom); break
                                        case 2: SettingsData.setShellitBarPosition(SettingsData.Position.Left); break
                                        case 3: SettingsData.setShellitBarPosition(SettingsData.Position.Right); break
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ShellitBar Auto-hide Section
            StyledRect {
                width: parent.width
                height: shellitBarAutoHideSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: shellitBarAutoHideSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "visibility_off"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - autoHideToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Auto-hide"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Automatically hide the top bar to expand screen real estate"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        ShellitToggle {
                            id: autoHideToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.ShellitBarAutoHide
                            onToggled: toggled => {
                                           return SettingsData.setShellitBarAutoHide(
                                               toggled)
                                       }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "visibility"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - visibilityToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Manual Show/Hide"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Toggle top bar visibility manually (can be controlled via IPC)"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        ShellitToggle {
                            id: visibilityToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.ShellitBarVisible
                            onToggled: toggled => {
                                           return SettingsData.setShellitBarVisible(
                                               toggled)
                                       }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                        visible: CompositorService.isNiri
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: CompositorService.isNiri

                        ShellitIcon {
                            name: "fullscreen"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width - Theme.iconSize - Theme.spacingM
                                   - overviewToggle.width - Theme.spacingM
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                text: "Show on Overview"
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Always show the top bar when niri's overview is open"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }

                        ShellitToggle {
                            id: overviewToggle

                            anchors.verticalCenter: parent.verticalCenter
                            checked: SettingsData.shellitBarOpenOnOverview
                            onToggled: toggled => {
                                           return SettingsData.setShellitBarOpenOnOverview(
                                               toggled)
                                       }
                        }
                    }
                }
            }


            // Spacing
            StyledRect {
                width: parent.width
                height: shellitBarSpacingSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: shellitBarSpacingSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "space_bar"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Spacing"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Edge Spacing (0 = edge-to-edge)"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: parent.width - edgeSpacingText.implicitWidth - resetEdgeSpacingBtn.width - Theme.spacingS - Theme.spacingM
                                height: 1

                                StyledText {
                                    id: edgeSpacingText
                                    visible: false
                                    text: "Edge Spacing (0 = edge-to-edge)"
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }

                            ShellitActionButton {
                                id: resetEdgeSpacingBtn
                                buttonSize: 20
                                iconName: "refresh"
                                iconSize: 12
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    SettingsData.setShellitBarSpacing(4)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }

                        ShellitSlider {
                            id: edgeSpacingSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.shellitBarSpacing
                            minimum: 0
                            maximum: 32
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setShellitBarSpacing(
                                                          newValue)
                                                  }

                            Binding {
                                target: edgeSpacingSlider
                                property: "value"
                                value: SettingsData.shellitBarSpacing
                                restoreMode: Binding.RestoreBinding
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Exclusive Zone Offset"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: parent.width - exclusiveZoneText.implicitWidth - resetExclusiveZoneBtn.width - Theme.spacingS - Theme.spacingM
                                height: 1

                                StyledText {
                                    id: exclusiveZoneText
                                    visible: false
                                    text: "Exclusive Zone Offset"
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }

                            ShellitActionButton {
                                id: resetExclusiveZoneBtn
                                buttonSize: 20
                                iconName: "refresh"
                                iconSize: 12
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    SettingsData.setShellitBarBottomGap(0)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }

                        ShellitSlider {
                            id: exclusiveZoneSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.shellitBarBottomGap
                            minimum: -50
                            maximum: 50
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setShellitBarBottomGap(
                                                          newValue)
                                                  }

                            Binding {
                                target: exclusiveZoneSlider
                                property: "value"
                                value: SettingsData.shellitBarBottomGap
                                restoreMode: Binding.RestoreBinding
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Size"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Item {
                                width: parent.width - sizeText.implicitWidth - resetSizeBtn.width - Theme.spacingS - Theme.spacingM
                                height: 1

                                StyledText {
                                    id: sizeText
                                    visible: false
                                    text: "Size"
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }

                            ShellitActionButton {
                                id: resetSizeBtn
                                buttonSize: 20
                                iconName: "refresh"
                                iconSize: 12
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    SettingsData.setShellitBarInnerPadding(4)
                                }
                            }

                            Item {
                                width: Theme.spacingS
                                height: 1
                            }
                        }

                        ShellitSlider {
                            id: sizeSlider
                            width: parent.width
                            height: 24
                            value: SettingsData.shellitBarInnerPadding
                            minimum: 0
                            maximum: 24
                            unit: ""
                            showValue: true
                            wheelEnabled: false
                            thumbOutlineColor: Theme.surfaceContainerHigh
                            onSliderValueChanged: newValue => {
                                                      SettingsData.setShellitBarInnerPadding(
                                                          newValue)
                                                  }

                            Binding {
                                target: sizeSlider
                                property: "value"
                                value: SettingsData.shellitBarInnerPadding
                                restoreMode: Binding.RestoreBinding
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitToggle {
                            width: parent.width
                            text: "Auto Popup Gaps"
                            description: "Automatically calculate popup distance from bar edge."
                            checked: SettingsData.popupGapsAuto
                            onToggled: checked => {
                                SettingsData.setPopupGapsAuto(checked)
                            }
                        }

                        Column {
                            width: parent.width
                            leftPadding: Theme.spacingM
                            spacing: Theme.spacingM
                            visible: !SettingsData.popupGapsAuto

                            Rectangle {
                                width: parent.width - parent.leftPadding
                                height: 1
                                color: Theme.outline
                                opacity: 0.2
                            }

                            Column {
                                width: parent.width - parent.leftPadding
                                spacing: Theme.spacingS

                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "Manual Gap Size"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Item {
                                        width: parent.width - manualGapSizeText.implicitWidth - resetManualGapSizeBtn.width - Theme.spacingS - Theme.spacingM
                                        height: 1

                                        StyledText {
                                            id: manualGapSizeText
                                            visible: false
                                            text: "Manual Gap Size"
                                            font.pixelSize: Theme.fontSizeSmall
                                        }
                                    }

                                    ShellitActionButton {
                                        id: resetManualGapSizeBtn
                                        buttonSize: 20
                                        iconName: "refresh"
                                        iconSize: 12
                                        backgroundColor: Theme.surfaceContainerHigh
                                        iconColor: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: {
                                            SettingsData.setPopupGapsManual(4)
                                        }
                                    }

                                    Item {
                                        width: Theme.spacingS
                                        height: 1
                                    }
                                }

                                ShellitSlider {
                                    id: popupGapsManualSlider
                                    width: parent.width
                                    height: 24
                                    value: SettingsData.popupGapsManual
                                    minimum: 0
                                    maximum: 50
                                    unit: ""
                                    showValue: true
                                    wheelEnabled: false
                                    thumbOutlineColor: Theme.surfaceContainerHigh
                                    onSliderValueChanged: newValue => {
                                        SettingsData.setPopupGapsManual(newValue)
                                    }

                                    Binding {
                                        target: popupGapsManualSlider
                                        property: "value"
                                        value: SettingsData.popupGapsManual
                                        restoreMode: Binding.RestoreBinding
                                    }
                                }
                            }
                        }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Square Corners"
                        description: "Removes rounded corners from bar container."
                        checked: SettingsData.shellitBarSquareCorners
                        onToggled: checked => {
                                       SettingsData.setShellitBarSquareCorners(
                                           checked)
                                   }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "No Background"
                        description: "Remove widget backgrounds for a minimal look with tighter spacing."
                        checked: SettingsData.shellitBarNoBackground
                        onToggled: checked => {
                                       SettingsData.setShellitBarNoBackground(
                                           checked)
                                   }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Goth Corners"
                        description: "Add curved swooping tips at the bottom of the bar."
                        checked: SettingsData.shellitBarGothCornersEnabled
                        onToggled: checked => {
                                       SettingsData.setShellitBarGothCornersEnabled(
                                           checked)
                                   }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitToggle {
                            width: parent.width
                            text: "Border"
                            description: "Add a 1px border to the bar. Smart edge detection only shows border on exposed sides."
                            checked: SettingsData.shellitBarBorderEnabled
                            onToggled: checked => {
                                           SettingsData.setShellitBarBorderEnabled(checked)
                                       }
                        }

                        Column {
                            width: parent.width
                            leftPadding: Theme.spacingM
                            spacing: Theme.spacingM
                            visible: SettingsData.ShellitBarBorderEnabled

                            Rectangle {
                                width: parent.width - parent.leftPadding
                                height: 1
                                color: Theme.outline
                                opacity: 0.2
                            }

                            Row {
                                width: parent.width - parent.leftPadding
                                spacing: Theme.spacingM

                                Column {
                                    width: parent.width - borderColorGroup.width - Theme.spacingM
                                    spacing: Theme.spacingXS

                                    StyledText {
                                        text: "Border Color"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                    }

                                    StyledText {
                                        text: "Choose the border accent color"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        width: parent.width
                                    }
                                }

                                ShellitButtonGroup {
                                    id: borderColorGroup
                                    anchors.verticalCenter: parent.verticalCenter
                                    model: ["Surface", "Secondary", "Primary"]
                                    currentIndex: {
                                        const colorOption = SettingsData.shellitBarBorderColor || "surfaceText"
                                        switch (colorOption) {
                                            case "surfaceText": return 0
                                            case "secondary": return 1
                                            case "primary": return 2
                                            default: return 0
                                        }
                                    }
                                    onSelectionChanged: (index, selected) => {
                                        if (selected) {
                                            let newColor = "surfaceText"
                                            switch (index) {
                                                case 0: newColor = "surfaceText"; break
                                                case 1: newColor = "secondary"; break
                                                case 2: newColor = "primary"; break
                                            }
                                            if (SettingsData.shellitBarBorderColor !== newColor) {
                                                SettingsData.shellitBarBorderColor = newColor
                                            }
                                        }
                                    }
                                }
                            }

                            Column {
                                width: parent.width - parent.leftPadding
                                spacing: Theme.spacingS

                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "Border Opacity"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Item {
                                        width: parent.width - borderOpacityText.implicitWidth - resetBorderOpacityBtn.width - Theme.spacingS - Theme.spacingM
                                        height: 1

                                        StyledText {
                                            id: borderOpacityText
                                            visible: false
                                            text: "Border Opacity"
                                            font.pixelSize: Theme.fontSizeSmall
                                        }
                                    }

                                    ShellitActionButton {
                                        id: resetBorderOpacityBtn
                                        buttonSize: 20
                                        iconName: "refresh"
                                        iconSize: 12
                                        backgroundColor: Theme.surfaceContainerHigh
                                        iconColor: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: {
                                            SettingsData.shellitBarBorderOpacity = 1.0
                                        }
                                    }

                                    Item {
                                        width: Theme.spacingS
                                        height: 1
                                    }
                                }

                                ShellitSlider {
                                    id: borderOpacitySlider
                                    width: parent.width
                                    height: 24
                                    value: (SettingsData.shellitBarBorderOpacity ?? 1.0) * 100
                                    minimum: 0
                                    maximum: 100
                                    unit: "%"
                                    showValue: true
                                    wheelEnabled: false
                                    thumbOutlineColor: Theme.surfaceContainerHigh
                                    onSliderValueChanged: newValue => {
                                        SettingsData.shellitBarBorderOpacity = newValue / 100
                                    }

                                    Binding {
                                        target: borderOpacitySlider
                                        property: "value"
                                        value: (SettingsData.shellitBarBorderOpacity ?? 1.0) * 100
                                        restoreMode: Binding.RestoreBinding
                                    }
                                }
                            }

                            Column {
                                width: parent.width - parent.leftPadding
                                spacing: Theme.spacingS

                                Row {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    StyledText {
                                        text: "Border Thickness"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        font.weight: Font.Medium
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Item {
                                        width: parent.width - borderThicknessText.implicitWidth - resetBorderThicknessBtn.width - Theme.spacingS - Theme.spacingM
                                        height: 1

                                        StyledText {
                                            id: borderThicknessText
                                            visible: false
                                            text: "Border Thickness"
                                            font.pixelSize: Theme.fontSizeSmall
                                        }
                                    }

                                    ShellitActionButton {
                                        id: resetBorderThicknessBtn
                                        buttonSize: 20
                                        iconName: "refresh"
                                        iconSize: 12
                                        backgroundColor: Theme.surfaceContainerHigh
                                        iconColor: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: {
                                            SettingsData.shellitBarBorderThickness = 1
                                        }
                                    }

                                    Item {
                                        width: Theme.spacingS
                                        height: 1
                                    }
                                }

                                ShellitSlider {
                                    id: borderThicknessSlider
                                    width: parent.width
                                    height: 24
                                    value: SettingsData.shellitBarBorderThickness ?? 1
                                    minimum: 1
                                    maximum: 10
                                    unit: "px"
                                    showValue: true
                                    wheelEnabled: false
                                    thumbOutlineColor: Theme.surfaceContainerHigh
                                    onSliderValueChanged: newValue => {
                                        SettingsData.shellitBarBorderThickness = newValue
                                    }

                                    Binding {
                                        target: borderThicknessSlider
                                        property: "value"
                                        value: SettingsData.shellitBarBorderThickness ?? 1
                                        restoreMode: Binding.RestoreBinding
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.outline
                        opacity: 0.2
                    }

                    Rectangle {
                        width: parent.width
                        height: 60
                        radius: Theme.cornerRadius
                        color: "transparent"

                        Column {
                            anchors.left: parent.left
                            anchors.right: shellitBarFontScaleControls.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "ShellitBar Font Scale"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                text: "Scale ShellitBar font sizes independently"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                            }
                        }

                        Row {
                            id: shellitBarFontScaleControls

                            width: 180
                            height: 36
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            ShellitActionButton {
                                buttonSize: 32
                                iconName: "remove"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.shellitBarFontScale > 0.5
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.max(0.5, SettingsData.shellitBarFontScale - 0.05)
                                    SettingsData.setShellitBarFontScale(newScale)
                                }
                            }

                            StyledRect {
                                width: 60
                                height: 32
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh
                                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                                border.width: 0

                                StyledText {
                                    anchors.centerIn: parent
                                    text: (SettingsData.ShellitBarFontScale * 100).toFixed(0) + "%"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                }
                            }

                            ShellitActionButton {
                                buttonSize: 32
                                iconName: "add"
                                iconSize: Theme.iconSizeSmall
                                enabled: SettingsData.shellitBarFontScale < 2.0
                                backgroundColor: Theme.surfaceContainerHigh
                                iconColor: Theme.surfaceText
                                onClicked: {
                                    var newScale = Math.min(2.0, SettingsData.shellitBarFontScale + 0.05)
                                    SettingsData.setShellitBarFontScale(newScale)
                                }
                            }
                        }
                    }
                }
            }

            // Widget Management Section
            StyledRect {
                width: parent.width
                height: widgetManagementSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: widgetManagementSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            id: widgetIcon
                            name: "widgets"
                            size: Theme.iconSize
                            color: Theme.primary
                            Layout.alignment: Qt.AlignVCenter
                        }

                        StyledText {
                            id: widgetTitle
                            text: "Widget Management"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item {
                            height: 1
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            id: resetButton
                            width: 80
                            height: 28
                            radius: Theme.cornerRadius
                            color: resetArea.containsMouse ? Theme.surfacePressed : Theme.surfaceVariant
                            Layout.alignment: Qt.AlignVCenter
                            border.width: 0
                            border.color: resetArea.containsMouse ? Theme.outline : Qt.rgba(
                                                                        Theme.outline.r,
                                                                        Theme.outline.g,
                                                                        Theme.outline.b,
                                                                        0.5)

                            Row {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                ShellitIcon {
                                    name: "refresh"
                                    size: 14
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: "Reset"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: resetArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsData.setShellitBarLeftWidgets(
                                                defaultLeftWidgets)
                                    SettingsData.setShellitBarCenterWidgets(
                                                defaultCenterWidgets)
                                    SettingsData.setShellitBarRightWidgets(
                                                defaultRightWidgets)
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }
                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: Theme.shortDuration
                                    easing.type: Theme.standardEasing
                                }
                            }
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: "Drag widgets to reorder within sections. Use the eye icon to hide/show widgets (maintains spacing), or X to remove them completely."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingL

                // Left/Top Section
                StyledRect {
                    width: parent.width
                    height: leftSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                          Theme.outline.b, 0.2)
                    border.width: 0

                    WidgetsTabSection {
                        id: leftSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        title: SettingsData.shellitBarIsVertical ? "Top Section" : "Left Section"
                        titleIcon: "format_align_left"
                        sectionId: "left"
                        allWidgets: shellitBarTab.baseWidgetDefinitions
                        items: shellitBarTab.getItemsForSection("left")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  shellitBarTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                shellitBarTab.handleItemOrderChanged(
                                                    "left", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = shellitBarTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            shellitBarTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 shellitBarTab.handleSpacerSizeChanged(
                                                     sectionId, widgetIndex, newSize)
                                             }
                        onCompactModeChanged: (widgetId, value) => {
                                                  if (widgetId === "clock") {
                                                      SettingsData.setClockCompactMode(
                                                          value)
                                                  } else if (widgetId === "music") {
                                                      SettingsData.setMediaSize(
                                                          value)
                                                  } else if (widgetId === "focusedWindow") {
                                                      SettingsData.setFocusedWindowCompactMode(
                                                          value)
                                                  } else if (widgetId === "runningApps") {
                                                      SettingsData.setRunningAppsCompactMode(
                                                          value)
                                                  }
                                              }
                        onControlCenterSettingChanged: (sectionId, widgetIndex, settingName, value) => {
                                                           handleControlCenterSettingChanged(sectionId, widgetIndex, settingName, value)
                                                       }
                        onGpuSelectionChanged: (sectionId, widgetIndex, selectedIndex) => {
                                                   shellitBarTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         shellitBarTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   shellitBarTab.handleMinimumWidthChanged(
                                                       sectionId, widgetIndex, enabled)
                                               }
                    }
                }

                // Center Section
                StyledRect {
                    width: parent.width
                    height: centerSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                          Theme.outline.b, 0.2)
                    border.width: 0

                    WidgetsTabSection {
                        id: centerSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        title: "Center Section"
                        titleIcon: "format_align_center"
                        sectionId: "center"
                        allWidgets: shellitBarTab.baseWidgetDefinitions
                        items: shellitBarTab.getItemsForSection("center")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  shellitBarTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                shellitBarTab.handleItemOrderChanged(
                                                    "center", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = shellitBarTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            shellitBarTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 shellitBarTab.handleSpacerSizeChanged(
                                                     sectionId, widgetIndex, newSize)
                                             }
                        onCompactModeChanged: (widgetId, value) => {
                                                  if (widgetId === "clock") {
                                                      SettingsData.setClockCompactMode(
                                                          value)
                                                  } else if (widgetId === "music") {
                                                      SettingsData.setMediaSize(
                                                          value)
                                                  } else if (widgetId === "focusedWindow") {
                                                      SettingsData.setFocusedWindowCompactMode(
                                                          value)
                                                  } else if (widgetId === "runningApps") {
                                                      SettingsData.setRunningAppsCompactMode(
                                                          value)
                                                  }
                                              }
                        onControlCenterSettingChanged: (sectionId, widgetIndex, settingName, value) => {
                                                           handleControlCenterSettingChanged(sectionId, widgetIndex, settingName, value)
                                                       }
                        onGpuSelectionChanged: (sectionId, widgetIndex, selectedIndex) => {
                                                   shellitBarTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         shellitBarTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   shellitBarTab.handleMinimumWidthChanged(
                                                       sectionId, widgetIndex, enabled)
                                               }
                    }
                }

                // Right/Bottom Section
                StyledRect {
                    width: parent.width
                    height: rightSection.implicitHeight + Theme.spacingL * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh
                    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                          Theme.outline.b, 0.2)
                    border.width: 0

                    WidgetsTabSection {
                        id: rightSection
                        anchors.fill: parent
                        anchors.margins: Theme.spacingL
                        title: SettingsData.ShellitBarIsVertical ? "Bottom Section" : "Right Section"
                        titleIcon: "format_align_right"
                        sectionId: "right"
                        allWidgets: shellitBarTab.baseWidgetDefinitions
                        items: shellitBarTab.getItemsForSection("right")
                        onItemEnabledChanged: (sectionId, itemId, enabled) => {
                                                  shellitBarTab.handleItemEnabledChanged(
                                                      sectionId,
                                                      itemId, enabled)
                                              }
                        onItemOrderChanged: newOrder => {
                                                shellitBarTab.handleItemOrderChanged(
                                                    "right", newOrder)
                                            }
                        onAddWidget: sectionId => {
                                         widgetSelectionPopup.allWidgets
                                         = shellitBarTab.getWidgetsForPopup()
                                         widgetSelectionPopup.targetSection = sectionId
                                         widgetSelectionPopup.show()
                                     }
                        onRemoveWidget: (sectionId, widgetIndex) => {
                                            shellitBarTab.removeWidgetFromSection(
                                                sectionId, widgetIndex)
                                        }
                        onSpacerSizeChanged: (sectionId, widgetIndex, newSize) => {
                                                 shellitBarTab.handleSpacerSizeChanged(
                                                     sectionId, widgetIndex, newSize)
                                             }
                        onCompactModeChanged: (widgetId, value) => {
                                                  if (widgetId === "clock") {
                                                      SettingsData.setClockCompactMode(
                                                          value)
                                                  } else if (widgetId === "music") {
                                                      SettingsData.setMediaSize(
                                                          value)
                                                  } else if (widgetId === "focusedWindow") {
                                                      SettingsData.setFocusedWindowCompactMode(
                                                          value)
                                                  } else if (widgetId === "runningApps") {
                                                      SettingsData.setRunningAppsCompactMode(
                                                          value)
                                                  }
                                              }
                        onControlCenterSettingChanged: (sectionId, widgetIndex, settingName, value) => {
                                                           handleControlCenterSettingChanged(sectionId, widgetIndex, settingName, value)
                                                       }
                        onGpuSelectionChanged: (sectionId, widgetIndex, selectedIndex) => {
                                                   shellitBarTab.handleGpuSelectionChanged(
                                                       sectionId, widgetIndex,
                                                       selectedIndex)
                                               }
                        onDiskMountSelectionChanged: (sectionId, widgetIndex, mountPath) => {
                                                         shellitBarTab.handleDiskMountSelectionChanged(
                                                             sectionId, widgetIndex, mountPath)
                                                     }
                        onMinimumWidthChanged: (sectionId, widgetIndex, enabled) => {
                                                   shellitBarTab.handleMinimumWidthChanged(
                                                       sectionId, widgetIndex, enabled)
                                               }
                    }
                }
            }
        }
    }

    WidgetSelectionPopup {
        id: widgetSelectionPopup

        parentModal: shellitBarTab.parentModal
        onWidgetSelected: (widgetId, targetSection) => {
                              shellitBarTab.addWidgetToSection(widgetId,
                                                           targetSection)
                          }
    }
}
