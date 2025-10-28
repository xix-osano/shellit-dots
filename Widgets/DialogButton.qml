import qs.Common
import qs.Common.functions
import qs.Widgets
import QtQuick

/**
 * Material 3 dialog button. See https://m3.material.io/components/dialogs/overview
 */
RippleButton {
    id: root

    property string buttonText
    padding: 14
    implicitHeight: 36
    implicitWidth: buttonTextWidget.implicitWidth + padding * 2
    buttonRadius: ShellitAppearance?.rounding.full ?? 9999

    property color colEnabled: ShellitAppearance?.colors.colPrimary ?? "#65558F"
    property color colDisabled: ShellitAppearance?.m3colors.m3outline ?? "#8D8C96"
    colBackground: ColorUtils.transparentize(ShellitAppearance.colors.colLayer3)
    colBackgroundHover: ShellitAppearance.colors.colLayer3Hover
    colRipple: ShellitAppearance.colors.colLayer3Active
    property alias colText: buttonTextWidget.color

    contentItem: StyledText {
        id: buttonTextWidget
        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: ShellitAppearance?.font.pixelSize.small ?? 12
        color: root.enabled ? root.colEnabled : root.colDisabled

        Behavior on color {
            animation: ShellitAppearance?.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

}
