import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.modules.common
import qs.services
import qs.modules.common.widgets

Card {
    id: root

    signal clicked()

    Component.onCompleted: WeatherService.addRef()
    Component.onDestruction: WeatherService.removeRef()

    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: !WeatherService.weather.available || WeatherService.weather.temp === 0

        StyledIcon {
            name: "cloud_off"
            size: 24
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: WeatherService.weather.loading ? "Loading..." : "No Weather"
            font.pixelSize: 12
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: Translation.tr("Refresh")
            flat: true
            visible: !WeatherService.weather.loading
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: WeatherService.forceRefresh()
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16
        visible: WeatherService.weather.available && WeatherService.weather.temp !== 0

        StyledIcon {
            name: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
            size: 48
            color: Appearance.colors.colLayer1
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            StyledText {
                text: {
                    const temp = Config.options.bar.weather.useUSCS ? WeatherService.weather.tempF : WeatherService.weather.temp;
                    if (temp === undefined || temp === null || temp === 0) {
                        return "--°" + (Config.options.bar.weather.useUSCS ? "F" : "C");
                    }
                    return temp + "°" + (Config.options.bar.weather.useUSCS ? "F" : "C");
                }
                font.pixelSize: 20 + 4
                color: Appearance.colors.colSubtext
                font.weight: Font.Light
            }

            StyledText {
                text: WeatherService.getWeatherCondition(WeatherService.weather.wCode)
                font.pixelSize: 12
                color: Appearance.colors.colSubtext
                elide: Text.ElideRight
                width: parent.parent.parent.width - 48 - 16 * 2
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}