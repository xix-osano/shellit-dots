pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property int currentTab: 0
    property bool showAddDialog: false
    property string emptyPlaceholderText: "Nothing here!"
    property string emptyPlaceholderIcon: "check_circle"
    property int fabSize: 48
    property int fabMargins: 14
    property int dialogMargins: 20

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            currentTab = event.key === Qt.Key_PageDown
                ? Math.min(currentTab + 1, 1)
                : Math.max(currentTab - 1, 0)
            event.accepted = true
        } else if (event.key === Qt.Key_N) {
            showAddDialog = true
            event.accepted = true
        } else if (event.key === Qt.Key_Escape && showAddDialog) {
            showAddDialog = false
            event.accepted = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // === Tab Bar ===
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: root.currentTab
            onCurrentIndexChanged: root.currentTab = currentIndex

            Repeater {
                model: [
                    { icon: "checklist", name: "Unfinished" },
                    { icon: "check_circle", name: "Done" }
                ]
                delegate: SecondaryTabButton {
                    buttonText: modelData.name
                    buttonIcon: modelData.icon
                    selected: index === root.currentTab
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
        }

        // === SwipeView for Tabs ===
        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentTab
            onCurrentIndexChanged: root.currentTab = currentIndex

            // Unfinished
            TaskListView {
                emptyPlaceholderIcon: "check_circle"
                emptyPlaceholderText: "Nothing to do — impressive!"
                taskList: Todo.list
                    .map((item, i) => ({ ...item, originalIndex: i }))
                    .filter(item => !item.done)
            }

            // Done
            TaskListView {
                emptyPlaceholderIcon: "checklist"
                emptyPlaceholderText: "Finished tasks go here."
                taskList: Todo.list
                    .map((item, i) => ({ ...item, originalIndex: i }))
                    .filter(item => item.done)
            }
        }
    }

    // === Floating Action Button ===
    StyledRectangularShadow {
        target: fabButton
        radius: fabButton.buttonRadius
        blur: 0.6 * Appearance.sizes.elevationMargin
    }

    FloatingActionButton {
        id: fabButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: root.fabMargins
        anchors.bottomMargin: root.fabMargins
        onClicked: root.showAddDialog = true

        contentItem: MaterialSymbol {
            text: "add"
            iconSize: Appearance.font.pixelSize.huge
            color: Appearance.m3colors.m3onPrimaryContainer
        }
    }

    // === Add Task Dialog ===
    Item {
        anchors.fill: parent
        z: 1000
        visible: opacity > 0
        opacity: root.showAddDialog ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.elementMoveFast.duration
                easing.type: Appearance.animation.elementMoveFast.type
            }
        }

        Rectangle { // Scrim
            anchors.fill: parent
            color: Appearance.colors.colScrim
            MouseArea {
                anchors.fill: parent
                onClicked: root.showAddDialog = false
            }
        }

        Rectangle {
            id: dialog
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: root.dialogMargins
            radius: Appearance.rounding.normal
            color: Appearance.colors.colSurfaceContainerHigh

            property alias input: todoInput

            function addTask() {
                if (todoInput.text.trim().length > 0) {
                    Todo.addTask(todoInput.text.trim())
                    todoInput.text = ""
                    root.showAddDialog = false
                    root.currentTab = 0
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 16
                padding: 16

                StyledText {
                    text: "Add Task"
                    font.pixelSize: Appearance.font.pixelSize.larger
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
                    spacing: 10
                    DialogButton {
                        buttonText: "Cancel"
                        onClicked: root.showAddDialog = false
                    }
                    DialogButton {
                        buttonText: "Add"
                        enabled: todoInput.text.trim().length > 0
                        onClicked: dialog.addTask()
                    }
                }
            }
        }
    }

    // === Embedded Task List ===
    Component {
        id: taskListDelegate

        Rectangle {
            id: taskItem
            width: parent.width
            height: 55
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer2
            anchors.margins: 8
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10

                CheckBox {
                    checked: modelData.done
                    onCheckedChanged: {
                        if (checked)
                            Todo.markDone(modelData.originalIndex)
                        else
                            Todo.markUnfinished(modelData.originalIndex)
                    }
                }

                StyledText {
                    text: modelData.content
                    Layout.fillWidth: true
                    font.strikeout: modelData.done
                    color: modelData.done
                        ? Qt.rgba(0.8, 0.8, 0.8, 0.8)
                        : Appearance.m3colors.m3onSurface
                }

                RippleButton {
                    buttonText: "✕"
                    tooltipText: "Delete"
                    onClicked: Todo.deleteItem(modelData.originalIndex)
                }
            }
        }
    }

    Component {
        id: TaskListView
        Item {
            id: taskListContainer
            property var taskList: []
            property string emptyPlaceholderIcon: ""
            property string emptyPlaceholderText: ""
            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: taskList
                    delegate: taskListDelegate
                    clip: true
                }

                // Empty placeholder
                Item {
                    Layout.fillWidth: true
                    visible: taskList.length === 0
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        MaterialSymbol {
                            text: emptyPlaceholderIcon
                            iconSize: 48
                            color: Appearance.m3colors.m3outline
                        }
                        StyledText {
                            text: emptyPlaceholderText
                            color: Appearance.m3colors.m3outline
                        }
                    }
                }
            }
        }
    }
}
