import QtQuick
import qs.modules.common
import qs.modules.common.widgets

StyledRect {
    id: root

    property string iconName: ""
    property int iconSize: 24 - 4
    property color iconColor: Appearance.colors.colSubtext
    property color backgroundColor: "transparent"
    property bool circular: true
    property int buttonSize: 32

    signal clicked
    signal entered
    signal exited

    width: buttonSize
    height: buttonSize
    radius: Appearance.rounding.small
    color: backgroundColor

    StyledIcon {
        anchors.centerIn: parent
        name: root.iconName
        size: root.iconSize
        color: root.iconColor
    }

    StateLayer {
        stateColor: Appearance.colors.colPrimary
        cornerRadius: root.radius
        onClicked: root.clicked()
        onEntered: root.entered()
        onExited: root.exited()
    }
}
