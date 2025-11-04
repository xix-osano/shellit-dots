import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool showDate: Config.options.bar.verbose
    property bool toggled: GlobalStates.dashOpen
    property bool showPing: false
    property color colBackgroundToggled: Appearance.colors.colSecondaryContainer
    property color colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
    property color colRippleToggled: Appearance.colors.colSecondaryContainerActive
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight


    Connections {
        target: Dash
        function onResponseFinished() {
            if (GlobalStates.dashOpen) return;
            root.showPing = true;
        }
    }

    Connections {
        target: GlobalStates
        function onDashOpenChanged() {
            root.showPing = false;
        }
    }

    Rectangle {
        id: bgHover
        anchors.fill: parent
        color: Appearance.colors.colLayer1Hover
        opacity: mouseArea.containsMouse ? 0.12 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Rectangle {
        id: bgPressed
        anchors.fill: parent
        color: Appearance.colors.colLayer1Active
        opacity: mouseArea.pressed ? 0.18 : 0
        Behavior on opacity { NumberAnimation { duration: 80 } }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        StyledText {
            font.pixelSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
            text: DateTime.time
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: "•"
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: DateTime.date
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: GlobalStates.dashOpen = !GlobalStates.dashOpen 

        ClockWidgetTooltip {
            hoverTarget: mouseArea
        }
    }
}
