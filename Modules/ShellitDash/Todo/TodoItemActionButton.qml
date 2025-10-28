import qs.Common
import qs.Widgets
import QtQuick

RippleButton {
    id: button
    property string buttonText: ""
    property string tooltipText: ""

    implicitHeight: 30
    implicitWidth: implicitHeight

    Behavior on implicitWidth {
        SmoothedAnimation {
            velocity: ShellitAppearance.animation.elementMove.velocity
        }
    }

    buttonRadius: ShellitAppearance.rounding.small

    contentItem: StyledText {
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: ShellitAppearance.font.pixelSize.larger
        color: ShellitAppearance.colors.colOnLayer1
    }

    StyledToolTip {
        text: tooltipText
        extraVisibleCondition: tooltipText.length > 0
    }
}