import qs.Common
import QtQuick

StyledText {
    id: root
    property real iconSize: ShellitAppearance?.font.pixelSize.small ?? 16
    property real fill: 0
    property real truncatedFill: fill.toFixed(1) // Reduce memory consumption spikes from constant font remapping
    renderType: fill !== 0 ? Text.CurveRendering : Text.NativeRendering
    font {
        hintingPreference: Font.PreferFullHinting
        family: ShellitAppearance?.font.family.iconMaterial ?? "Material Symbols Rounded"
        pixelSize: iconSize
        weight: Font.Normal + (Font.DemiBold - Font.Normal) * truncatedFill
        variableAxes: { 
            "FILL": truncatedFill,
            // "wght": font.weight,
            // "GRAD": 0,
            "opsz": iconSize,
        }
    }

    Behavior on fill { // Leaky leaky, no good
        NumberAnimation {
            duration: ShellitAppearance?.animation.elementMoveFast.duration ?? 200
            easing.type: ShellitAppearance?.animation.elementMoveFast.type ?? Easing.BezierSpline
            easing.bezierCurve: ShellitAppearance?.animation.elementMoveFast.bezierCurve ?? [0.34, 0.80, 0.34, 1.00, 1, 1]
        }
    }
}
