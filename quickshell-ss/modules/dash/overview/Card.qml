import QtQuick
import QtQuick.Controls
import qs.modules.common

Rectangle {
    id: card

    property int pad: 12

    radius: 12
    color: Appearance.colors.colLayer0
    border.color: Appearance.colors.colLayer0Border
    border.width: 1

    default property alias content: contentItem.data

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: card.pad
    }
}