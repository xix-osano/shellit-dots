import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs.Common
import qs.Widgets
import qs.Services
import Quickshell

Item {
    id: root
    implicitWidth: 700
    implicitHeight: 410

    property int currentTab: 0
    property var tabButtonList: [
        {"icon": "checklist", "name": "Unfinished"},
        {"icon": "check_circle", "name": "Done"}
    ]

    property bool showAddDialog: false
    property int dialogMargins: 20
    property int fabSize: 48
    property int fabMargins: 14

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            currentTab = event.key === Qt.Key_PageDown
                ? Math.min(currentTab + 1, root.tabButtonList.length - 1)
                : Math.max(currentTab - 1, 0)
            event.accepted = true
        } else if (event.key === Qt.Key_N) {
            root.showAddDialog = true
            event.accepted = true
        } else if (event.key === Qt.Key_Escape && root.showAddDialog) {
            root.showAddDialog = false
            event.accepted = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingL

        // === Tab bar ===
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: currentTab
            onCurrentIndexChanged: currentTab = currentIndex

            Repeater {
                model: root.tabButtonList
                delegate: Button {
                    text: modelData.name
                    icon.name: modelData.icon
                    checked: index == currentTab
                    onClicked: currentTab = index
                }
            }
        }

        // === Swipe views ===
        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: currentTab
            clip: true

            // Unfinished tasks
            TaskList {
                id: unfinishedList
                taskList: TodoService.list
                    .map((item, i) => Object.assign({}, item, { originalIndex: i }))
                    .filter(item => !item.done)
                emptyPlaceholderIcon: "checklist"
                emptyPlaceholderText: "No pending tasks 🎉"
            }

            // Done tasks
            TaskList {
                id: doneList
                taskList: TodoService.list
                    .map((item, i) => Object.assign({}, item, { originalIndex: i }))
                    .filter(item => item.done)
                emptyPlaceholderIcon: "check_circle"
                emptyPlaceholderText: "You’re all caught up ✅"
            }
        }
    }

    // === Floating Action Button ===
    FloatingActionButton {
        id: fabButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: root.fabMargins
        icon.name: "add"
        onClicked: root.showAddDialog = true
    }

    // === Add Task Dialog ===
    Item {
        anchors.fill: parent
        visible: root.showAddDialog
        z: 10

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
            MouseArea {
                anchors.fill: parent
                onClicked: root.showAddDialog = false
            }
        }

        Rectangle {
            id: dialog
            width: parent.width - 60
            anchors.centerIn: parent
            color: Appearance.colors.colSurfaceContainerHigh
            radius: 10
            padding: 16

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                Text {
                    text: "Add Task"
                    font.bold: true
                    font.pixelSize: 18
                    color: Appearance.m3colors.m3onSurface
                }

                TextField {
                    id: todoInput
                    Layout.fillWidth: true
                    placeholderText: "Task description"
                    onAccepted: dialog.addTask()
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8

                    Button {
                        text: "Cancel"
                        onClicked: root.showAddDialog = false
                    }
                    Button {
                        text: "Add"
                        enabled: todoInput.text.length > 0
                        onClicked: dialog.addTask()
                    }
                }
            }

            function addTask() {
                if (todoInput.text.trim().length > 0) {
                    TodoService.addTask(todoInput.text)
                    todoInput.text = ""
                    root.showAddDialog = false
                    root.currentTab = 0
                }
            }
        }
    }

    // === React to TodoService updates ===
    Connections {
        target: TodoService
        function onTasksUpdated() {
            unfinishedList.taskList = TodoService.list
                .map((item, i) => Object.assign({}, item, { originalIndex: i }))
                .filter(item => !item.done)
            doneList.taskList = TodoService.list
                .map((item, i) => Object.assign({}, item, { originalIndex: i }))
                .filter(item => item.done)
        }
    }
}
