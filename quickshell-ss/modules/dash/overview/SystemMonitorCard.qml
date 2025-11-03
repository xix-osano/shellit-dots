import QtQuick
import QtQuick.Effects
import qs.modules.common
import qs.services
import qs.modules.common.widgets

Card {
    id: root

    Component.onCompleted: {
        DgopService.addRef(["cpu", "memory", "system"])
    }
    Component.onDestruction: {
        DgopService.removeRef(["cpu", "memory", "system"])
    }

    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        // CPU Bar
        Column {
            width: (parent.width - 2 * 12) / 3
            height: parent.height
            spacing: 8

            Rectangle {
                width: 8
                height: parent.height - 16 - 8
                radius: 4
                anchors.horizontalCenter: parent.horizontalCenter
                color: Appearance.colors.colOutline

                Rectangle {
                    width: parent.width
                    height: parent.height * Math.min((DgopService.cpuUsage || 6) / 100, 1)
                    radius: parent.radius
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: {
                        if (DgopService.cpuUsage > 80) return "#F2B8B5"
                        if (DgopService.cpuUsage > 60) return "#FF9800"
                        return "#FFFFFF"
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 16

                StyledIcon {
                    name: "memory"
                    size: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    color: {
                        if (DgopService.cpuUsage > 80) return "#F2B8B5"
                        if (DgopService.cpuUsage > 60) return "#FF9800"
                        return Appearance.colors.colLayer1
                    }
                }
            }
        }

        // Temperature Bar
        Column {
            width: (parent.width - 2 * 12) / 3
            height: parent.height
            spacing: 8

            Rectangle {
                width: 8
                height: parent.height - 16 - 8
                radius: 4
                anchors.horizontalCenter: parent.horizontalCenter
                color: Appearance.colors.colOutline

                Rectangle {
                    width: parent.width
                    height: parent.height * Math.min(Math.max((DgopService.cpuTemperature || 40) / 100, 0), 1)
                    radius: parent.radius
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: {
                        if (DgopService.cpuTemperature > 85) return "#F44336"
                        if (DgopService.cpuTemperature > 69) return "#FF9800"
                        return "#FFFFFF"
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 16

                StyledIcon {
                    name: "device_thermostat"
                    size: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    color: {
                        if (DgopService.cpuTemperature > 85) return "#F44336"
                        if (DgopService.cpuTemperature > 69) return "#FF9800"
                        return "#FFFFFF"
                    }
                }
            }
        }

        // RAM Bar
        Column {
            width: (parent.width - 2 * 12) / 3
            height: parent.height
            spacing: 8

            Rectangle {
                width: 8
                height: parent.height - 16 - 8
                radius: 4
                anchors.horizontalCenter: parent.horizontalCenter
                color: Appearance.colors.colOutline

                Rectangle {
                    width: parent.width
                    height: parent.height * Math.min((DgopService.memoryUsage || 42) / 100, 1)
                    radius: parent.radius
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: {
                        if (DgopService.memoryUsage > 90) return "#F44336"
                        if (DgopService.memoryUsage > 75) return "#FF9800"
                        return "#FFFFFF"
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 16

                StyledIcon {
                    name: "developer_board"
                    size: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    color: {
                        if (DgopService.memoryUsage > 90) return "#F44336"
                        if (DgopService.memoryUsage > 75) return "#FF9800"
                        return "#FFFFFF"
                    }
                }
            }
        }
    }
}