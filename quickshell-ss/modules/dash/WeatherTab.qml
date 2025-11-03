import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.modules.common
import qs.services
import qs.modules.common.widgets

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 410

    Column {
        anchors.centerIn: parent
        spacing: 16
        visible: !WeatherService.weather.available || WeatherService.weather.temp === 0

        StyledIcon {
            name: "cloud_off"
            size: 24 * 2
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: Translation.tr("No Weather Data Available")
            font.pixelSize: 16
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Column {
        anchors.fill: parent
        spacing: 12
        visible: WeatherService.weather.available && WeatherService.weather.temp !== 0

        Item {
            width: parent.width
            height: 70

            StyledIcon {
                id: refreshButton
                name: "refresh"
                size: 24 - 4
                color: Appearance.colors.colSubtext
                anchors.right: parent.right
                anchors.top: parent.top

                property bool isRefreshing: false
                enabled: !isRefreshing

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: {
                        refreshButton.isRefreshing = true
                        WeatherService.forceRefresh()
                        refreshTimer.restart()
                    }
                    enabled: parent.enabled
                }

                Timer {
                    id: refreshTimer
                    interval: 2000
                    onTriggered: refreshButton.isRefreshing = false
                }

                NumberAnimation on rotation {
                    running: refreshButton.isRefreshing
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                }
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: weatherIcon.width + tempColumn.width + sunriseColumn.width + 12 * 2
                height: 70

                StyledIcon {
                    id: weatherIcon
                    name: WeatherService.getWeatherIcon(WeatherService.weather.wCode)
                    size: 24 * 1.5
                    color: Appearance.colors.colLayer1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 4
                        shadowBlur: 0.8
                        shadowColor: Qt.rgba(0, 0, 0, 0.2)
                        shadowOpacity: 0.2
                    }
                }

                Column {
                    id: tempColumn
                    spacing: 4
                    anchors.left: weatherIcon.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    Item {
                        width: tempText.width + unitText.width + 4
                        height: tempText.height

                        StyledText {
                            id: tempText
                            text: (Config.options.bar.weather.useUSCS ? WeatherService.weather.tempF : WeatherService.weather.temp) + "°"
                            font.pixelSize: 16 + 4
                            color: Appearance.colors.colSubtext
                            font.weight: Font.Light
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            id: unitText
                            text: Config.options.bar.weather.useUSCS ? "F" : "C"
                            font.pixelSize: 14
                            color: Appearance.colors.colSubtext
                            anchors.left: tempText.right
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (WeatherService.weather.available) {
                                        WeatherService.setTemperatureUnit(!Config.options.bar.weather.useUSCS)
                                    }
                                }
                                enabled: WeatherService.weather.available
                            }
                        }
                    }

                    StyledText {
                        text: WeatherService.weather.city || ""
                        font.pixelSize: 14
                        color: Appearance.colors.colSubtext
                        visible: text.length > 0
                    }
                }

                Column {
                    id: sunriseColumn
                    spacing: 4
                    anchors.left: tempColumn.right
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    visible: WeatherService.weather.sunrise && WeatherService.weather.sunset

                    Item {
                        width: sunriseIcon.width + sunriseText.width + 4
                        height: sunriseIcon.height

                        StyledIcon {
                            id: sunriseIcon
                            name: "wb_twilight"
                            size: 24 - 6
                            color: Appearance.colors.colSubtext
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            id: sunriseText
                            text: WeatherService.weather.sunrise || ""
                            font.pixelSize: 12
                            color: Appearance.colors.colSubtext
                            anchors.left: sunriseIcon.right
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Item {
                        width: sunsetIcon.width + sunsetText.width + 4
                        height: sunsetIcon.height

                        StyledIcon {
                            id: sunsetIcon
                            name: "bedtime"
                            size: 24 - 6
                            color: Appearance.colors.colSubtext
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            id: sunsetText
                            text: WeatherService.weather.sunset || ""
                            font.pixelSize: 12
                            color: Appearance.colors.colSubtext
                            anchors.left: sunsetIcon.right
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Appearance.colors.colOutline
        }

        GridLayout {
            width: parent.width
            height: 95
            columns: 6
            columnSpacing: 8
            rowSpacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.small
                color: Appearance.colors.colSurfaceContainerHigh

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Appearance.colors.colLayer1
                        anchors.horizontalCenter: parent.horizontalCenter

                        DankIcon {
                            anchors.centerIn: parent
                            name: "device_thermostat"
                            size: 24 - 4
                            color: Appearance.colors.colPrimary
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2

                        StyledText {
                            text: Translation.tr("Feels Like")
                            font.pixelSize: 12
                            color: Appearance.colors.colSubtext
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: (Config.options.bar.weather.useUSCS ? (WeatherService.weather.feelsLikeF || WeatherService.weather.tempF) : (WeatherService.weather.feelsLike || WeatherService.weather.temp)) + "°"
                            font.pixelSize: 12 + 1
                            color: Appearance.colors.colSubtext
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.small
                color: Appearance.colors.colSurfaceContainerHigh

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Appearance.colors.colLayer1
                        anchors.horizontalCenter: parent.horizontalCenter

                        DankIcon {
                            anchors.centerIn: parent
                            name: "humidity_low"
                            size: 24 - 4
                            color: Appearance.colors.colPrimary
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2

                        StyledText {
                            text: Translation.tr("Humidity")
                            font.pixelSize: 12
                            color: Appearance.colors.colSubtext
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: WeatherService.weather.humidity ? WeatherService.weather.humidity + "%" : "--"
                            font.pixelSize: 12 + 1
                            color: Appearance.colors.colSubtext
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.small
                color: Appearance.colors.colSurfaceContainerHigh

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Appearance.colors.colLayer1
                        anchors.horizontalCenter: parent.horizontalCenter

                        StyledIcon {
                            anchors.centerIn: parent
                            name: "air"
                            size: 24 - 4
                            color: Appearance.colors.colPrimary
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2

                        StyledText {
                            text: Translation.tr("Wind")
                            font.pixelSize: 12
                            color: Appearance.colors.colSubtext
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: WeatherService.weather.wind || "--"
                            font.pixelSize: 12 + 1
                            color: Appearance.colors.colSubtext
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.small
                color: Appearance.colors.colSurfaceContainerHigh

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Appearance.colors.colLayer1
                        anchors.horizontalCenter: parent.horizontalCenter

                        StyledIcon {
                            anchors.centerIn: parent
                            name: "speed"
                            size: 24 - 4
                            color: Appearance.colors.colPrimary
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2

                        StyledText {
                            text: Translation.tr("Pressure")
                            font.pixelSize: 12
                            color: Appearance.colors.colSubtext
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: WeatherService.weather.pressure ? WeatherService.weather.pressure + " hPa" : "--"
                            font.pixelSize: 12 + 1
                            color: Appearance.colors.colSubtext
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.small
                color: Appearance.colors.colSurfaceContainerHigh

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Appearance.colors.colLayer1
                        anchors.horizontalCenter: parent.horizontalCenter

                        StyledIcon {
                            anchors.centerIn: parent
                            name: "rainy"
                            size: 24 - 4
                            color: Appearance.colors.colPrimary
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2

                        StyledText {
                            text: Translation.tr("Rain Chance")
                            font.pixelSize: 12
                            color: Appearance.colors.colSubtext
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: WeatherService.weather.precipitationProbability ? WeatherService.weather.precipitationProbability + "%" : "0%"
                            font.pixelSize: 12 + 1
                            color: Appearance.colors.colSubtext
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.small
                color: Appearance.colors.colSurfaceContainerHigh

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Appearance.colors.colLayer1
                        anchors.horizontalCenter: parent.horizontalCenter

                        StyledIcon {
                            anchors.centerIn: parent
                            name: "wb_sunny"
                            size: 24 - 4
                            color: Appearance.colors.colPrimary
                        }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2

                        StyledText {
                            text: Translation.tr("Visibility")
                            font.pixelSize: 12
                            color: Appearance.colors.colSubtext
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StyledText {
                            text: Translation.tr("Good")
                            font.pixelSize: 12 + 1
                            color: Appearance.colors.colSubtext
                            font.weight: Font.Medium
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Appearance.colors.colOutline
        }

        Column {
            width: parent.width
            height: parent.height - 70 - 95 - 12 * 3 - 2
            spacing: 8

            StyledText {
                text: Translation.tr("7-Day Forecast")
                font.pixelSize: 12
                color: Appearance.colors.colSubtext
                font.weight: Font.Medium
            }

            Row {
                width: parent.width
                height: parent.height - 12 - 8 - 16
                spacing: 4

                Repeater {
                    model: 7

                    Rectangle {
                        width: (parent.width - 4 * 6) / 7
                        height: parent.height
                        radius: Appearance.rounding.small

                        property var dayDate: {
                            const date = new Date()
                            date.setDate(date.getDate() + index)
                            return date
                        }
                        property bool isToday: index === 0
                        property var forecastData: {
                            if (WeatherService.weather.forecast && WeatherService.weather.forecast.length > index) {
                                return WeatherService.weather.forecast[index]
                            }
                            return null
                        }

                        color: isToday ? Appearance.colors.colPrimary : Appearance.colors.colSurfaceContainerHigh
                        border.color: isToday ? Appearance.colors.colPrimary : "transparent"
                        border.width: isToday ? 1 : 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            StyledText {
                                text: Qt.locale().dayName(dayDate.getDay(), Locale.ShortFormat)
                                font.pixelSize: 12
                                color: isToday ? Appearance.colors.colPrimary : Appearance.colors.colSurfaceText
                                font.weight: isToday ? Font.Medium : Font.Normal
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledIcon {
                                name: forecastData ? WeatherService.getWeatherIcon(forecastData.wCode || 0) : "cloud"
                                size: Theme.iconSize
                                color: isToday ? Appearance.colors.colPrimary : Appearance.colors.colLayer1
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Column {
                                spacing: 2
                                anchors.horizontalCenter: parent.horizontalCenter

                                StyledText {
                                    text: forecastData ? (Config.options.bar.weather.useUSCS ? (forecastData.tempMaxF || forecastData.tempMax) : (forecastData.tempMax || 0)) + "°/" + (Config.options.bar.weather.useUSCS ? (forecastData.tempMinF || forecastData.tempMin) : (forecastData.tempMin || 0)) + "°" : "--/--"
                                    font.pixelSize: 12
                                    color: isToday ? Appearance.colors.colPrimary : Appearance.colors.colSurfaceText
                                    font.weight: Font.Medium
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Column {
                                    spacing: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    visible: forecastData && forecastData.sunrise && forecastData.sunset

                                    Row {
                                        spacing: 2
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        StyledIcon {
                                            name: "wb_twilight"
                                            size: 8
                                            color: Appearance.colors.colSubtext
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: forecastData ? forecastData.sunrise : ""
                                            font.pixelSize: 12 - 2
                                            color: Appearance.colors.colSubtext
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Row {
                                        spacing: 2
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        StyledIcon {
                                            name: "bedtime"
                                            size: 8
                                            color: Appearance.colors.colSubtext
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: forecastData ? forecastData.sunset : ""
                                            font.pixelSize: 12 - 2
                                            color: Appearance.colors.colSubtext
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}