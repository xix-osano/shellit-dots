import QtQuick
import QtQuick.Effects
import Quickshell
import qs.modules.common
import qs.modules.common.widgets

Card {
    id: root

    Column {
        anchors.centerIn: parent
        spacing: 8

        Column {
            spacing: -8
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                spacing: 0
                anchors.horizontalCenter: parent.horizontalCenter

                StyledText {
                    text: {
                        if (Config.options.time.format === "hh:mm") {
                            return String(systemClock?.date?.getHours()).padStart(2, '0').charAt(0)
                        } else {
                            const hours = systemClock?.date?.getHours()
                            const display = hours === 0 ? 12 : hours > 12 ? hours - 12 : hours
                            return String(display).padStart(2, '0').charAt(0)
                        }
                    }
                    font.pixelSize: 48
                    color: Appearance.colors.colLayer1
                    font.weight: Font.Medium
                    width: 28
                    horizontalAlignment: Text.AlignHCenter
                }

                StyledText {
                    text: {
                        if (Config.options.time.format === "hh:mm") {
                            return String(systemClock?.date?.getHours()).padStart(2, '0').charAt(1)
                        } else {
                            const hours = systemClock?.date?.getHours()
                            const display = hours === 0 ? 12 : hours > 12 ? hours - 12 : hours
                            return String(display).padStart(2, '0').charAt(1)
                        }
                    }
                    font.pixelSize: 48
                    color: Appearance.colors.colLayer1
                    font.weight: Font.Medium
                    width: 28
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Row {
                spacing: 0
                anchors.horizontalCenter: parent.horizontalCenter

                StyledText {
                    text: String(systemClock?.date?.getMinutes()).padStart(2, '0').charAt(0)
                    font.pixelSize: 48
                    color: Appearance.colors.colLayer1
                    font.weight: Font.Medium
                    width: 28
                    horizontalAlignment: Text.AlignHCenter
                }

                StyledText {
                    text: String(systemClock?.date?.getMinutes()).padStart(2, '0').charAt(1)
                    font.pixelSize: 48
                    color: Appearance.colors.colLayer1
                    font.weight: Font.Medium
                    width: 28
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Row {
                visible: SettingsData.showSeconds
                spacing: 0
                anchors.horizontalCenter: parent.horizontalCenter

                StyledText {
                    text: String(systemClock?.date?.getSeconds()).padStart(2, '0').charAt(0)
                    font.pixelSize: 48
                    color: Appearance.colors.colLayer1
                    font.weight: Font.Medium
                    width: 28
                    horizontalAlignment: Text.AlignHCenter
                }

                StyledText {
                    text: String(systemClock?.date?.getSeconds()).padStart(2, '0').charAt(1)
                    font.pixelSize: 48
                    color: Appearance.colors.colLayer1
                    font.weight: Font.Medium
                    width: 28
                    horizontalAlignment: Text.AlignHCenter
                }
            }

        }

        StyledText {
            text: systemClock?.date?.toLocaleDateString(Qt.locale(), "MMM dd")
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }
}