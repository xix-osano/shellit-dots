import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell
import qs.Common
import qs.services
import qs.modules.common.widgets

Card {
    id: root

    property string profileImageSource: "" // Full URL or file path to the profile image
    property string userName: "enosh"

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        StyledCircularImage {
            id: avatarContainer

            width: 77
            height: 77
            anchors.verticalCenter: parent.verticalCenter
            imageSource: {
                if (root.profileImageSource === "")      return ""
                if (root.profileImageSource.startsWith("/"))
                    return "file://" + root.profileImageSource
                return root.profileImageSource
            }
            fallbackIcon: "person"
        }

        Column {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: UserInfoService.username || "enosh"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: Theme.surfaceText
                elide: Text.ElideRight
                width: parent.parent.parent.width - avatarContainer.width - 8 * 3
            }

            Row {
                spacing: 8
                
                IconImage { //SystemLogo
                    property string colorOverride: ""
                    property real brightnessOverride: 0.5
                    property real contrastOverride: 1

                    readonly property bool hasColorOverride: colorOverride !== ""
                    
                    width: 16
                    height: 16
                    anchors.verticalCenter: parent.verticalCenter
                    colorOverride: Appearance.colors.colLayer1
                    smooth: true
                    asynchronous: true
                    layer.enabled: hasColorOverride

                    Component.onCompleted: {
                        Proc.runCommand(null, ["sh", "-c", ". /etc/os-release && echo $LOGO"], (output, exitCode) => {
                            if (exitCode !== 0) return
                            const logo = output.trim()
                            if (logo === "cachyos") {
                                source = "file:///usr/share/icons/cachyos.svg"
                                return
                            }
                            source = Quickshell.iconPath(logo, true)
                        }, 0)
                    }

                    layer.effect: MultiEffect {
                        colorization: 1
                        colorizationColor: colorOverride
                        brightness: brightnessOverride
                        contrast: contrastOverride
                    }
                }

                StyledText {
                    text: "on Hyprland"
                    font.pixelSize: 12
                    color: Appearance.colors.colSubtext
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: parent.parent.parent.parent.width - avatarContainer.width - 12 * 3 - 16 - 8
                }
            }

            Row {
                spacing: 8

                DankIcon {
                    name: "schedule"
                    size: 16
                    color: Appearance.colors.colLayer1
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    id: uptimeText

                    property real availableWidth: parent.parent.parent.parent.width - avatarContainer.width - 12 * 3 - 16 - 8
                    property real longTextWidth: {
                        const fontSize = Math.round(8 || 12)
                        const testMetrics = Qt.createQmlObject('import QtQuick; TextMetrics { font.pixelSize: ' + fontSize + ' }', uptimeText)
                        testMetrics.text = UserInfoService.uptime || "up 1 hour, 23 minutes"
                        const result = testMetrics.width
                        testMetrics.destroy()
                        return result
                    }
                    // Just using truncated is always true initially idk
                    property bool shouldUseShort: longTextWidth > availableWidth

                    text: shouldUseShort ? UserInfoService.shortUptime : UserInfoService.uptime || "up 1h 23m"
                    font.pixelSize: 12
                    color: Appearance.colors.colSubtext
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: availableWidth
                    wrapMode: Text.NoWrap
                }
            }
        }
    }
}