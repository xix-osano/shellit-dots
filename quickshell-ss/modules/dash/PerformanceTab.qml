import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import qs.Common
import qs.Widgets

Item {
    id: root
     
    implicitWidth: 700
    implicitHeight: 410
     
    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingM

        ShellitIcon {
            name: "hard_disk"
            size: Theme.iconSize * 3
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: "PerformanceTab. Coming Soon!"
            font.pixelSize: Theme.fontSizeLarge
            color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}