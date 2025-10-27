import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Services.TodoService
import Quickshell

Item {
    id: root
    implicitWidth: 700
    implicitHeight: 410

    TodoService {
        id: todo
    }

    property string newTaskText: ""

    Column {
        anchors.fill: parent
        spacing: Theme.spacingM
        anchors.margins: Theme.spacingM

        // Header row — add & refresh
        Row {
            Layout.fillWidth: true
            spacing: Theme.spacingS

            TextField {
                id: newTaskInput
                Layout.fillWidth: true
                placeholderText: "Add a new task..."
                text: root.newTaskText
                onTextChanged: root.newTaskText = text
                Keys.onReturnPressed: {
                    if (text.trim().length > 0) {
                        todo.addTask(text.trim())
                        text = ""
                    }
                }
            }

            Button {
                text: "Add"
                enabled: root.newTaskText.trim().length > 0
                onClicked: {
                    todo.addTask(root.newTaskText.trim())
                    root.newTaskText = ""
                }
            }

            ShellitIcon {
                name: "refresh"
                size: Theme.iconSize - 4
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.4)
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: todo.refresh()
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.1)
        }

        // List of todos
        ListView {
            id: todoList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Theme.spacingS
            model: todo.list

            delegate: Rectangle {
                width: parent.width
                height: 55
                radius: Theme.cornerRadius
                color: Qt.rgba(Theme.surfaceContainerHigh.r, Theme.surfaceContainerHigh.g, Theme.surfaceContainerHigh.b, 0.5)

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowVerticalOffset: 3
                    shadowBlur: 0.6
                    shadowColor: Qt.rgba(0, 0, 0, 0.2)
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingS
                    spacing: Theme.spacingM

                    CheckBox {
                        checked: modelData.done
                        onCheckedChanged: {
                            if (checked) todo.markDone(index)
                            else todo.markUnfinished(index)
                        }
                    }

                    StyledText {
                        text: modelData.content
                        font.pixelSize: Theme.fontSizeMedium
                        color: modelData.done
                               ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.4)
                               : Theme.surfaceText
                        font.strikeout: modelData.done
                        Layout.fillWidth: true
                        verticalAlignment: Text.AlignVCenter
                    }

                    ShellitIcon {
                        name: "delete"
                        size: Theme.iconSize - 2
                        color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.8)
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: todo.deleteItem(model.index)
                        }
                    }
                }
            }

            footer: Item {
                width: parent.width
                height: todo.list.length === 0 ? 160 : 0
                visible: todo.list.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.spacingS

                    ShellitIcon {
                        name: "playlist_remove"
                        size: Theme.iconSize * 2
                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.3)
                    }

                    StyledText {
                        text: "No tasks yet — add one above!"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.5)
                    }
                }
            }
        }
    }
}
