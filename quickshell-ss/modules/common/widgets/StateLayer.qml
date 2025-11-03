import QtQuick
import qs.modules.common

MouseArea {
    id: root

    property bool disabled: false
    property color stateColor: Appearance.colors.colSubtext
    property real cornerRadius: parent && parent.radius !== undefined ? parent.radius : Appearance.rounding.small

    readonly property real stateOpacity: disabled ? 0 : pressed ? 0.12 : containsMouse ? 0.08 : 0

    anchors.fill: parent
    cursorShape: disabled ? undefined : Qt.PointingHandCursor
    hoverEnabled: true

    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: Qt.rgba(stateColor.r, stateColor.g, stateColor.b, stateOpacity)
    }
}
