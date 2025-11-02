import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: widgetTweaksTab

    ShellitFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: workspaceSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: workspaceSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "view_module"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Workspace Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Workspace Index Numbers"
                        description: "Show workspace index numbers in the top bar workspace switcher"
                        checked: SettingsData.showWorkspaceIndex
                        onToggled: checked => {
                                       return SettingsData.setShowWorkspaceIndex(
                                           checked)
                                   }
                    }
                    ShellitToggle {
                        width: parent.width
                        text: "Window Scrolling"
                        description: "Scroll through windows, rather than workspaces"
                        checked: SettingsData.workspaceScrolling
                        visible: CompositorService.isNiri
                        onToggled: checked => {
                            return SettingsData.setWorkspaceScrolling(checked)
                        }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Workspace Padding"
                        description: "Always show a minimum of 3 workspaces, even if fewer are available"
                        checked: SettingsData.showWorkspacePadding
                        onToggled: checked => {
                                       return SettingsData.setShowWorkspacePadding(
                                           checked)
                                   }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Show Workspace Apps"
                        description: "Display application icons in workspace indicators"
                        checked: SettingsData.showWorkspaceApps
                        onToggled: checked => {
                                       return SettingsData.setShowWorkspaceApps(
                                           checked)
                                   }
                    }

		    Row {
                        width: parent.width - Theme.spacingL
                        spacing: Theme.spacingL
                        visible: SettingsData.showWorkspaceApps
                        opacity: visible ? 1 : 0
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingL

                        Column {
                            width: 120
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Max apps to show"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            ShellitTextField {
                                width: 100
                                height: 28
                                placeholderText: "#ffffff"
                                text: SettingsData.maxWorkspaceIcons
                                maximumLength: 7
                                font.pixelSize: Theme.fontSizeSmall
                                topPadding: Theme.spacingXS
                                bottomPadding: Theme.spacingXS
                                onEditingFinished: {
                                    SettingsData.setMaxWorkspaceIcons(parseInt(text, 10))
                                }
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                                easing.type: Theme.emphasizedEasing
                            }
                        }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Per-Monitor Workspaces"
                        description: "Show only workspaces belonging to each specific monitor."
                        checked: SettingsData.workspacesPerMonitor
                        onToggled: checked => {
                            return SettingsData.setWorkspacesPerMonitor(checked);
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: mediaSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: mediaSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "music_note"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Media Player Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Wave Progress Bars"
                        description: "Use animated wave progress bars for media playback"
                        checked: SettingsData.waveProgressEnabled
                        onToggled: checked => {
                            return SettingsData.setWaveProgressEnabled(checked);
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: updaterSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: updaterSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "refresh"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "System Updater"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Use Custom Command"
                        description: "Use custom command for update your system"
                        checked: SettingsData.updaterUseCustomCommand
                        onToggled: checked => {
                            if (!checked) {
                                updaterCustomCommand.text = "";
                                updaterTerminalCustomClass.text = "";
                                SettingsData.setUpdaterCustomCommand("");
                                SettingsData.setUpdaterTerminalAdditionalParams("");
                            }
                            return SettingsData.setUpdaterUseCustomCommandEnabled(checked);
                        }
                    }

                    FocusScope {
                        width: parent.width - Theme.spacingM * 2
                        height: customCommandColumn.implicitHeight
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM

                        Column {
                            id: customCommandColumn
                            width: parent.width
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "System update custom command"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            ShellitTextField {
                                id: updaterCustomCommand
                                width: parent.width
                                height: 48
                                placeholderText: "myPkgMngr --sysupdate"
                                backgroundColor: Theme.surfaceVariant
                                normalBorderColor: Theme.primarySelected
                                focusedBorderColor: Theme.primary

                                Component.onCompleted: {
                                    if (SettingsData.updaterCustomCommand) {
                                        text = SettingsData.updaterCustomCommand;
                                    }
                                }

                                onTextEdited: {
                                    SettingsData.setUpdaterCustomCommand(text.trim());
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed: mouse => {
                                        updaterCustomCommand.forceActiveFocus()
                                        mouse.accepted = false
                                    }
                                }
                            }
                        }
                    }

                    FocusScope {
                        width: parent.width - Theme.spacingM * 2
                        height: terminalParamsColumn.implicitHeight
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM

                        Column {
                            id: terminalParamsColumn
                            width: parent.width
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Terminal custom additional parameters"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            ShellitTextField {
                                id: updaterTerminalCustomClass
                                width: parent.width
                                height: 48
                                placeholderText: "-T udpClass"
                                backgroundColor: Theme.surfaceVariant
                                normalBorderColor: Theme.primarySelected
                                focusedBorderColor: Theme.primary

                                Component.onCompleted: {
                                    if (SettingsData.updaterTerminalAdditionalParams) {
                                        text = SettingsData.updaterTerminalAdditionalParams;
                                    }
                                }

                                onTextEdited: {
                                    SettingsData.setUpdaterTerminalAdditionalParams(text.trim());
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed: mouse => {
                                        updaterTerminalCustomClass.forceActiveFocus()
                                        mouse.accepted = false
                                    }
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: runningAppsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: runningAppsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "apps"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Running Apps Settings"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    ShellitToggle {
                        width: parent.width
                        text: "Running Apps Only In Current Workspace"
                        description: "Show only apps running in current workspace"
                        checked: SettingsData.runningAppsCurrentWorkspace
                        onToggled: checked => {
                                       return SettingsData.setRunningAppsCurrentWorkspace(
                                           checked)
                                   }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: workspaceIconsSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0
                visible: SettingsData.hasNamedWorkspaces()

                Column {
                    id: workspaceIconsSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "label"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Named Workspace Icons"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: "Configure icons for named workspaces. Icons take priority over numbers when both are enabled."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.outline
                        wrapMode: Text.WordWrap
                    }

                    Repeater {
                        model: SettingsData.getNamedWorkspaces()

                        Rectangle {
                            width: parent.width
                            height: workspaceIconRow.implicitHeight + Theme.spacingM
                            radius: Theme.cornerRadius
                            color: Qt.rgba(Theme.surfaceContainer.r,
                                           Theme.surfaceContainer.g,
                                           Theme.surfaceContainer.b, 0.5)
                            border.color: Qt.rgba(Theme.outline.r,
                                                  Theme.outline.g,
                                                  Theme.outline.b, 0.3)
                            border.width: 0

                            Row {
                                id: workspaceIconRow

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: Theme.spacingM
                                anchors.rightMargin: Theme.spacingM
                                spacing: Theme.spacingM

                                StyledText {
                                    text: "\"" + modelData + "\""
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 150
                                    elide: Text.ElideRight
                                }

                                ShellitIconPicker {
                                    id: iconPicker
                                    anchors.verticalCenter: parent.verticalCenter

                                    Component.onCompleted: {
                                        var iconData = SettingsData.getWorkspaceNameIcon(
                                                    modelData)
                                        if (iconData) {
                                            setIcon(iconData.value,
                                                    iconData.type)
                                        }
                                    }

                                    onIconSelected: (iconName, iconType) => {
                                                        SettingsData.setWorkspaceNameIcon(
                                                            modelData, {
                                                                "type": iconType,
                                                                "value": iconName
                                                            })
                                                        setIcon(iconName,
                                                                iconType)
                                                    }

                                    Connections {
                                        target: SettingsData
                                        function onWorkspaceIconsUpdated() {
                                            var iconData = SettingsData.getWorkspaceNameIcon(
                                                        modelData)
                                            if (iconData) {
                                                iconPicker.setIcon(
                                                            iconData.value,
                                                            iconData.type)
                                            } else {
                                                iconPicker.setIcon("", "icon")
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: Theme.cornerRadius
                                    color: clearMouseArea.containsMouse ? Theme.errorHover : Theme.surfaceContainer
                                    border.color: clearMouseArea.containsMouse ? Theme.error : Theme.outline
                                    border.width: 0
                                    anchors.verticalCenter: parent.verticalCenter

                                    ShellitIcon {
                                        name: "close"
                                        size: 16
                                        color: clearMouseArea.containsMouse ? Theme.error : Theme.outline
                                        anchors.centerIn: parent
                                    }

                                    MouseArea {
                                        id: clearMouseArea

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            SettingsData.removeWorkspaceNameIcon(
                                                        modelData)
                                        }
                                    }
                                }

                                Item {
                                    width: parent.width - 150 - 240 - 28 - Theme.spacingM * 4
                                    height: 1
                                }
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: notificationSection.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Column {
                    id: notificationSection

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        ShellitIcon {
                            name: "notifications"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Notification Popups"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 0
                        leftPadding: Theme.spacingM
                        rightPadding: Theme.spacingM

                        ShellitDropdown {
                            width: parent.width - parent.leftPadding - parent.rightPadding
                            text: "Popup Position"
                            description: "Choose where notification popups appear on screen"
                            currentValue: {
                                if (SettingsData.notificationPopupPosition === -1) {
                                    return "Top Center"
                                }
                                switch (SettingsData.notificationPopupPosition) {
                                case SettingsData.Position.Top:
                                    return "Top Right"
                                case SettingsData.Position.Bottom:
                                    return "Bottom Left"
                                case SettingsData.Position.Left:
                                    return "Top Left"
                                case SettingsData.Position.Right:
                                    return "Bottom Right"
                                default:
                                    return "Top Right"
                                }
                            }
                            options: ["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left"]
                            onValueChanged: value => {
                                switch (value) {
                                case "Top Right":
                                    SettingsData.setNotificationPopupPosition(SettingsData.Position.Top)
                                    break
                                case "Top Left":
                                    SettingsData.setNotificationPopupPosition(SettingsData.Position.Left)
                                    break
                                case "Top Center":
                                    SettingsData.setNotificationPopupPosition(-1)
                                    break
                                case "Bottom Right":
                                    SettingsData.setNotificationPopupPosition(SettingsData.Position.Right)
                                    break
                                case "Bottom Left":
                                    SettingsData.setNotificationPopupPosition(SettingsData.Position.Bottom)
                                    break
                                }
                                SettingsData.sendTestNotifications()
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: osdRow.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.color: Qt.rgba(Theme.outline.r, Theme.outline.g,
                                      Theme.outline.b, 0.2)
                border.width: 0

                Row {
                    id: osdRow

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    ShellitIcon {
                        name: "tune"
                        size: Theme.iconSize
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - Theme.iconSize - Theme.spacingM - osdToggle.width - Theme.spacingM
                        spacing: Theme.spacingXS
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: "Always Show OSD Percentage"
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: Theme.surfaceText
                        }

                        StyledText {
                            text: "Display volume and brightness percentage values by default in OSD popups"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }

                    ShellitToggle {
                        id: osdToggle

                        anchors.verticalCenter: parent.verticalCenter
                        checked: SettingsData.osdAlwaysShowValue
                        onToggleCompleted: checked => {
                                       SettingsData.setOsdAlwaysShowValue(checked)
                                   }
                    }
                }
            }
        }
    }
}
