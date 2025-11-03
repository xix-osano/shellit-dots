import QtQuick
import qs.modules.common

StyledText {
    id: icon

    property alias name: icon.text
    property alias size: icon.font.pixelSize
    property alias color: icon.color
    property bool filled: false
    property real fill: filled ? 1.0 : 0.0
    //property int grade: Theme.isLightMode ? 0 : -25
    property int weight: filled ? 500 : 400

    signal rotationCompleted()

    font.family: "Material Symbols Rounded"
    font.pixelSize: Appearance.font.pixelSize.small
    font.weight: weight
    color: Appearance.colors.colSubtext
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    renderType: Text.NativeRendering
    antialiasing: true
    font.variableAxes: {
        "FILL": fill.toFixed(1),
        "GRAD": grade,
        "opsz": 24,
        "wght": weight
    }

    Behavior on fill {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Behavior on weight {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: rotationTimer
        interval: 16
        repeat: false
        onTriggered: icon.rotationCompleted()
    }

    onRotationChanged: {
        rotationTimer.restart()
    }
}
