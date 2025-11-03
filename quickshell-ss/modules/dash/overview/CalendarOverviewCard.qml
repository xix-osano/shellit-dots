import QtQuick
import QtQuick.Effects
import Quickshell
import qs.modules.common
import qs.services
import qs.modules.common.widgets

Rectangle {
    id: root

    property bool showEventDetails: false
    property date selectedDate: systemClock.date
    property var selectedDateEvents: []
    property bool hasEvents: selectedDateEvents && selectedDateEvents.length > 0

    function weekStartJs() {
        return Qt.locale().firstDayOfWeek % 7
    }

    function startOfWeek(dateObj) {
        const d = new Date(dateObj)
        const jsDow = d.getDay()
        const diff = (jsDow - weekStartJs() + 7) % 7
        d.setDate(d.getDate() - diff)
        return d
    }

    function endOfWeek(dateObj) {
        const d = new Date(dateObj)
        const jsDow = d.getDay()
        const add = (weekStartJs() + 6 - jsDow + 7) % 7
        d.setDate(d.getDate() + add)
        return d
    }

    function updateSelectedDateEvents() {
        if (CalendarService && CalendarService.khalAvailable) {
            const events = CalendarService.getEventsForDate(selectedDate)
            selectedDateEvents = events
        } else {
            selectedDateEvents = []
        }
    }

    function loadEventsForMonth() {
        if (!CalendarService || !CalendarService.khalAvailable) {
            return
        }

        const firstOfMonth = new Date(calendarGrid.displayDate.getFullYear(),
                                      calendarGrid.displayDate.getMonth(), 1)
        const lastOfMonth  = new Date(calendarGrid.displayDate.getFullYear(),
                                      calendarGrid.displayDate.getMonth() + 1, 0)

        const startDate = startOfWeek(firstOfMonth)
        startDate.setDate(startDate.getDate() - 7)

        const endDate = endOfWeek(lastOfMonth)
        endDate.setDate(endDate.getDate() + 7)

        CalendarService.loadEvents(startDate, endDate)
    }

    onSelectedDateChanged: updateSelectedDateEvents()
    Component.onCompleted: {
        loadEventsForMonth()
        updateSelectedDateEvents()
    }

    Connections {
        function onEventsByDateChanged() {
            updateSelectedDateEvents()
        }

        function onKhalAvailableChanged() {
            if (CalendarService && CalendarService.khalAvailable) {
                loadEventsForMonth()
            }
            updateSelectedDateEvents()
        }

        target: CalendarService
        enabled: CalendarService !== null
    }

    radius: Appearance.rounding.small
    color: Appearance.colors.colLayer0
    border.color: Appearance.colors.colLayer0Border
    border.width: 1

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Item {
            width: parent.width
            height: 40
            visible: showEventDetails

            Rectangle {
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                radius: Appearance.rounding.small
                color: backButtonArea.containsMouse ? Appearance.m3colors.m3onPrimary : "transparent"

                StyledIcon {
                    anchors.centerIn: parent
                    name: "arrow_back"
                    size: 14
                    color: Appearance.colors.colOnLayer1
                }

                MouseArea {
                    id: backButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showEventDetails = false
                }
            }

            StyledText {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 32 + 8 * 2
                anchors.rightMargin: 8
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    const dateStr = Qt.formatDate(selectedDate, "MMM d")
                    if (selectedDateEvents && selectedDateEvents.length > 0) {
                        const eventCount = selectedDateEvents.length === 1 ? Translation.tr("1 event") : selectedDateEvents.length + " " + Translation.tr("events")
                        return dateStr + " • " + eventCount
                    }
                    return dateStr
                }
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colSubtext
                font.weight: Font.Medium
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
        Row {
            width: parent.width
            height: 28
            visible: !showEventDetails

            Rectangle {
                width: 28
                height: 28
                radius: Appearance.rounding.small
                color: prevMonthArea.containsMouse ? Appearance.m3colors.m3onPrimary : "transparent"

                StyledIcon {
                    anchors.centerIn: parent
                    name: "chevron_left"
                    size: 14
                    color:  Appearance.colors.colOnLayer1
                }

                MouseArea {
                    id: prevMonthArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let newDate = new Date(calendarGrid.displayDate)
                        newDate.setMonth(newDate.getMonth() - 1)
                        calendarGrid.displayDate = newDate
                        loadEventsForMonth()
                    }
                }
            }

            StyledText {
                width: parent.width - 56
                height: 28
                text: calendarGrid.displayDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colText
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                width: 28
                height: 28
                radius: Theme.cornerRadius
                color: nextMonthArea.containsMouse ? Appearance.m3colors.m3onPrimary : "transparent"

                StyledIcon {
                    anchors.centerIn: parent
                    name: "chevron_right"
                    size: 14
                    color: Appearance.colors.colOnLayer1
                }

                MouseArea {
                    id: nextMonthArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let newDate = new Date(calendarGrid.displayDate)
                        newDate.setMonth(newDate.getMonth() + 1)
                        calendarGrid.displayDate = newDate
                        loadEventsForMonth()
                    }
                }
            }
        }

        Row {
            width: parent.width
            height: 18
            visible: !showEventDetails

            Repeater {
                model: {
                    const days = []
                    const loc = Qt.locale()
                    const qtFirst = loc.firstDayOfWeek
                    for (let i = 0; i < 7; ++i) {
                        const qtDay = ((qtFirst - 1 + i) % 7) + 1
                        days.push(loc.dayName(qtDay, Locale.ShortFormat))
                    }
                    return days
                }

                Rectangle {
                    width: parent.width / 7
                    height: 18
                    color: "transparent"

                    StyledText {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Theme.fontSizeSmall
                        color: Appearance.colors.colText
                        font.weight: Font.Medium
                    }
                }
            }
        }

        Grid {
            id: calendarGrid
            visible: !showEventDetails

            property date displayDate: systemClock.date
            property date selectedDate: systemClock.date

            readonly property date firstDay: {
                const firstOfMonth = new Date(displayDate.getFullYear(), displayDate.getMonth(), 1)
                return startOfWeek(firstOfMonth)
            }

            width: parent.width
            height: parent.height - 28 - 18 - 8 * 2
            columns: 7
            rows: 6

            Repeater {
                model: 42

                Rectangle {
                    readonly property date dayDate: {
                        const date = new Date(parent.firstDay)
                        date.setDate(date.getDate() + index)
                        return date
                    }
                    readonly property bool isCurrentMonth: dayDate.getMonth() === calendarGrid.displayDate.getMonth()
                    readonly property bool isToday: dayDate.toDateString() === new Date().toDateString()
                    readonly property bool isSelected: dayDate.toDateString() === calendarGrid.selectedDate.toDateString()

                    width: parent.width / 7
                    height: parent.height / 6
                    color: "transparent"

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(parent.width - 4, parent.height - 4, 32)
                        height: width
                        color: isToday ? Appearance.m3colors.m3onPrimary : dayArea.containsMouse ? Appearance.colors.colOnLayer1 : "transparent"
                        radius: width / 2

                        StyledText {
                            anchors.centerIn: parent
                            text: dayDate.getDate()
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: isToday ? Appearance.colors.colOnLayer1 : isCurrentMonth ? Appearance.colors.colText : Appearance.colors.colOutlineVariant
                            font.weight: isToday ? Font.Medium : Font.Normal
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 4
                            width: 12
                            height: 2
                            radius: 1
                            visible: CalendarService && CalendarService.khalAvailable && CalendarService.hasEventsForDate(dayDate)
                            color: isToday ? Qt.lighter(Appearance.m3colors.m3onPrimary , 1.3) : Appearance.m3colors.m3onPrimary 
                            opacity: isToday ? 0.9 : 0.7

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: dayArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (CalendarService && CalendarService.khalAvailable && CalendarService.hasEventsForDate(dayDate)) {
                                root.selectedDate = dayDate
                                root.showEventDetails = true
                            }
                        }
                    }
                }
            }
        }
        StyledListView {
            width: parent.width - 8 * 2
            height: parent.height - (showEventDetails ? 40 : 28 + 18) - 8
            anchors.horizontalCenter: parent.horizontalCenter
            model: selectedDateEvents
            visible: showEventDetails
            clip: true
            spacing: 4

            delegate: Rectangle {
                width: parent ? parent.width : 0
                height: eventContent.implicitHeight + 8
                radius: Appearance.rounding.small
                color: {
                    if (modelData.url && eventMouseArea.containsMouse) {
                        return Appearance.colors.colOnLayer1
                    } else if (eventMouseArea.containsMouse) {
                        return Qt.rgba(Appearance.colors.colOnLayer1, 0.06)
                    }
                    return Appearance.colors.colLayer0
                }
                border.color: {
                    if (modelData.url && eventMouseArea.containsMouse) {
                        return Qt.rgba(Appearance.colors.colOnLayer1, 0.3)
                    } else if (eventMouseArea.containsMouse) {
                        return Qt.rgba(Appearance.colors.colOnLayer1, 0.15)
                    }
                    return "transparent"
                }
                border.width: 1

                Rectangle {
                    width: 3
                    height: parent.height - 6
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    color: Appearance.colors.colOnLayer1
                    opacity: 0.8
                }

                Column {
                    id: eventContent

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8 + 6
                    anchors.rightMargin: 4
                    spacing: 2

                    StyledText {
                        width: parent.width
                        text: modelData.title
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    StyledText {
                        width: parent.width
                        text: {
                            if (!modelData || modelData.allDay) {
                                return Translation.tr("All day")
                            } else if (modelData.start && modelData.end) {
                                const timeFormat = Config.options.time.format === "hh:mm" ? "HH:mm" : "h:mm AP"
                                const startTime = Qt.formatTime(modelData.start, timeFormat)
                                if (modelData.start.toDateString() !== modelData.end.toDateString() || modelData.start.getTime() !== modelData.end.getTime()) {
                                    return startTime + " – " + Qt.formatTime(modelData.end, timeFormat)
                                }
                                return startTime
                            }
                            return ""
                        }
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                        font.weight: Font.Normal
                        visible: text !== ""
                    }
                }

                MouseArea {
                    id: eventMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: modelData.url ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: modelData.url !== ""
                    onClicked: {
                        if (modelData.url && modelData.url !== "") {
                            if (Qt.openUrlExternally(modelData.url) === false) {
                                console.warn("Failed to open URL: " + modelData.url)
                            }
                        }
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Hours
    }
}