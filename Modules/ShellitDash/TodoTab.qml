import qs.Services
import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts 
import Quickshell

Rectangle {
    id: root
    width: 700
    height: 410
    radius: 20
    border.color: "black"
    border.width: 2
    color: "white"

    property int currentFilter: 0 // 0: Unfinished, 1: Done

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Header (TodoTab title)
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: "TodoTab"
                font.pixelSize: 24
                font.bold: true
            }
        }

        // 2. Tabs for Unfinished and Done
        RowLayout {
            Layout.fillWidth: true
            height: 50
            spacing: 10
            padding: 10
            
            // --- Unfinished Button ---
            Button {
                id: unfinishedButton
                text: "Unfinished"
                Layout.preferredWidth: 100
                checked: root.currentFilter === 0
                checkable: true
                ButtonGroup.group: buttonGroup
                onClicked: root.currentFilter = 0
                background: Rectangle {
                    color: unfinishedButton.checked ? "#ADD8E6" : "#E0E0E0" // Light Blue vs Light Gray
                    radius: 5
                    border.color: "black"
                    border.width: 1
                }
            }

            // --- Done Button ---
            Button {
                id: doneButton
                text: "Done"
                Layout.preferredWidth: 100
                checked: root.currentFilter === 1
                checkable: true
                ButtonGroup.group: buttonGroup
                onClicked: root.currentFilter = 1
                background: Rectangle {
                    color: doneButton.checked ? "#ADD8E6" : "#E0E0E0"
                    radius: 5
                    border.color: "black"
                    border.width: 1
                }
            }

            // Button to add new tasks
            TextField {
                id: newTaskInput
                Layout.fillWidth: true
                placeholderText: "Add a new task..."
                onAccepted: {
                    TodoService.addTask(newTaskInput.text)
                    newTaskInput.text = ""
                }
            }
        }

        ButtonGroup {
            id: buttonGroup
            exclusive: true
        }

        // 3. Task List Header
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#D3D3D3" // Light Gray Header
            border.top: 1
            border.bottom: 1
            border.color: "black"

            RowLayout {
                anchors.fill: parent
                spacing: 0
                padding: 10

                Text {
                    Layout.fillWidth: true
                    text: "TaskList"
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    Layout.preferredWidth: 150
                    text: "Date Added"
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        // 4. Task List View
        Flickable {
            id: tasksView
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: column.implicitHeight
            clip: true

            Column {
                id: column
                width: parent.width
                spacing: 5
                padding: 5

                // Filtered List Model: This creates a filtered list based on currentFilter
                Repeater {
                    id: taskRepeater
                    model: TodoService.list.filter(item => {
                        // Filter tasks based on the current tab
                        const isDone = item.done
                        return (root.currentFilter === 0 && !isDone) || (root.currentFilter === 1 && isDone)
                    })

                    delegate: TaskList {
                        width: parent.width
                        task: model.modelData // The filtered task object
                        onStatusChanged: (isDone) => {
                            // Find the index of the task in the *original* TodoService list
                            const originalIndex = TodoService.list.findIndex(t => t.content === task.content && t.created === task.created)
                            if (isDone) {
                                TodoService.markDone(originalIndex)
                            } else {
                                TodoService.markUnfinished(originalIndex)
                            }
                        }
                        onDeleted: {
                            // Find the index of the task in the *original* TodoService list
                            const originalIndex = TodoService.list.findIndex(t => t.content === task.content && t.created === task.created)
                            TodoService.deleteItem(originalIndex)
                        }
                    }
                }
            }

            // Re-evaluate the repeater model when the list or filter changes
            Connections {
                target: TodoService
                function onTasksUpdated() {
                    // Force the repeater to re-evaluate its model
                    taskRepeater.model = TodoService.list.filter(item => {
                        const isDone = item.done
                        return (root.currentFilter === 0 && !isDone) || (root.currentFilter === 1 && isDone)
                    })
                }
            }
            onCurrentFilterChanged: taskRepeater.model = taskRepeater.model
        }
    }
}