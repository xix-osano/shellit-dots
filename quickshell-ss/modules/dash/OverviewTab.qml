import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.services
import qs.modules.common.widgets
import qs.modules.dash.overview

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 410
    property int spacing: 12

    signal switchToWeatherTab()
    signal switchToMediaTab()

    Item {
        anchors.fill: parent
        // Clock - top left (narrower and shorter)
        ClockCard {
            x: 0
            y: 0
            width: parent.width * 0.2 - root.spacing * 2
            height: 180
        }

        // Weather - top middle-left (narrower)
        WeatherOverviewCard {
            x: Config.options.bar.weather.enable ? parent.width * 0.2 - root.spacing : 0
            y: 0
            width: Config.options.bar.weather.enable ? parent.width * 0.3 : 0
            height: 100
            visible: Config.options.bar.weather.enable

            onClicked: root.switchToWeatherTab()
        }

        // UserInfo - top middle-right (extend when weather disabled)
        UserInfoCard {
            x: Config.options.bar.weather.enable ? parent.width * 0.5 : parent.width * 0.2 - root.spacing
            y: 0
            width: Config.options.bar.weather.enable ? parent.width * 0.5 : parent.width * 0.8
            height: 100
        }

        // SystemMonitor - middle left (narrow and shorter)
        SystemMonitorCard {
            x: 0
            y: 180 + root.spacing
            width: parent.width * 0.2 - root.spacing * 2
            height: 220
        }

        // Calendar - bottom middle (wider and taller)
        CalendarOverviewCard {
            x: parent.width * 0.2 - root.spacing
            y: 100 + root.spacing
            width: parent.width * 0.6
            height: 300
        }

        // Media - bottom right (narrow and taller)
        MediaOverviewCard {
            x: parent.width * 0.8
            y: 100 + root.spacing
            width: parent.width * 0.2
            height: 300

            onClicked: root.switchToMediaTab()
        }
    }
}