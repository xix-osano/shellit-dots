import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
     
    implicitWidth: 700
    implicitHeight: 410
     
    Column {
        anchors.centerIn: parent
        spacing: 12

        StyledIcon {
            name: "hard_disk"
            size: 24 * 3
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: "PerformanceTab. Coming Soon!"
            font.pixelSize: 16
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}