import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root
     
    implicitWidth: 700
    implicitHeight: 410
     

    Text {
        id: headerText
        text: "To-Do List. Coming Soon!"
        font.pixelSize: 24
        color: Theme.primary
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

}