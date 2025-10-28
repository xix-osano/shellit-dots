import QtQuick
import QtQuick.Controls
import qs.Services

Item {
    id: todoTab
    width: parent.width
    height: parent.height

    Column {
        anchors.fill: parent
        spacing: 8

        // New task input
        Row {
            spacing: 6
            TextField {
                id: input
                placeholderText: "Add a new task..."
                width: parent.width * 0.8
                onAccepted: {
                    TodoService.addTask(text)
                    text = ""
                }
            }
            Button {
                text: "Add"
                onClicked: {
                    TodoService.addTask(input.text)
                    input.text = ""
                }
            }
        }

        // Scrollable task list
        ScrollView {
            anchors.fill: parent
            ListView {
                id: taskList
                model: TodoService.list
                clip: true
                delegate: Row {
                    spacing: 8
                    CheckBox {
                        checked: modelData.done
                        onToggled: {
                            if (checked)
                                TodoService.markDone(index)
                            else
                                TodoService.markUnfinished(index)
                        }
                    }
                    Text {
                        text: modelData.content
                        font.pixelSize: 15
                        color: modelData.done ? "#777" : "#fff"
                        opacity: modelData.done ? 0.6 : 1.0
                    }
                    Button {
                        text: "🗑"
                        onClicked: TodoService.deleteItem(index)
                    }
                }
            }
        }
    }

    Connections {
        target: TodoService
        function onTasksUpdated() {
            taskList.model = TodoService.list
        }
    }
}
