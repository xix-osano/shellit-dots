import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool isEnabled: pluginData.isEnabled || false
    property var options: pluginData.options || ["Option A", "Option B", "Option C"]

    ccWidgetIcon: isEnabled ? "settings" : "settings"
    ccWidgetPrimaryText: "Detail Example"
    ccWidgetSecondaryText: {
        if (isEnabled) {
            const selected = pluginData.selectedOption || "Option A"
            return selected
        }
        return "Disabled"
    }
    ccWidgetIsActive: isEnabled

    onCcWidgetToggled: {
        isEnabled = !isEnabled
        if (pluginService) {
            pluginService.savePluginData("controlCenterDetailExample", "isEnabled", isEnabled)
        }
    }

    ccDetailContent: Component {
        Rectangle {
            id: detailRoot
            implicitHeight: detailColumn.implicitHeight + Theme.spacingM * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHigh
            border.width: 0
            visible: true

            property var options: ["Option A", "Option B", "Option C"]
            property string currentSelection: SettingsData.getPluginSetting("controlCenterDetailExample", "selectedOption", "Option A")

            Column {
                id: detailColumn
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS

                StyledText {
                    text: "Detail Example Settings"
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Select an option below:"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                Repeater {
                    model: detailRoot.options

                    Rectangle {
                        width: parent.width
                        height: 40
                        radius: Theme.cornerRadius
                        color: optionMouseArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                        border.color: detailRoot.currentSelection === modelData ? Theme.primary : "transparent"
                        border.width: detailRoot.currentSelection === modelData ? 2 : 0

                        MouseArea {
                            id: optionMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: 100
                            onClicked: {
                                SettingsData.setPluginSetting("controlCenterDetailExample", "selectedOption", modelData)
                                detailRoot.currentSelection = modelData
                                PluginService.pluginDataChanged("controlCenterDetailExample")
                                ToastService.showInfo("Option Selected", modelData)
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingS
                            enabled: false

                            ShellitIcon {
                                name: detailRoot.currentSelection === modelData ? "radio_button_checked" : "radio_button_unchecked"
                                color: detailRoot.currentSelection === modelData ? Theme.primary : Theme.surfaceVariantText
                                size: Theme.iconSize
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: modelData
                                color: detailRoot.currentSelection === modelData ? Theme.primary : Theme.surfaceText
                                font.pixelSize: Theme.fontSizeMedium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            ShellitIcon {
                name: root.isEnabled ? "settings" : "settings_off"
                color: root.isEnabled ? Theme.primary : Theme.surfaceVariantText
                font.pixelSize: Theme.iconSize - 4
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: {
                    const selected = root.pluginData.selectedOption || "Option A"
                    return selected.substring(0, 1)
                }
                color: root.isEnabled ? Theme.primary : Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeMedium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
