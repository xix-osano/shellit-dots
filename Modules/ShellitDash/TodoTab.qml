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
    property var tabButtonList: [{"icon": "checklist", "name": "Unfinished"}, {"name": "Done", "icon": "check_circle"}]
    property bool showAddDialog: false
    property int dialogMargins: 20
    property int fabSize: 48
    property int fabMargins: 14

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown) {
                currentTab = Math.min(currentTab + 1, root.tabButtonList.length - 1)
            } else if (event.key === Qt.Key_PageUp) {
                currentTab = Math.max(currentTab - 1, 0)
            }
            event.accepted = true;
        }
        // Open add dialog on "N" (any modifiers)
        else if (event.key === Qt.Key_N) {
            root.showAddDialog = true
            event.accepted = true;
        }
        // Close dialog on Esc if open
        else if (event.key === Qt.Key_Escape && root.showAddDialog) {
            root.showAddDialog = false
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingL

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: currentTab
            onCurrentIndexChanged: currentTab = currentIndex

            background: Item {
                WheelHandler {
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0)
                            tabBar.currentIndex = Math.min(tabBar.currentIndex + 1, root.tabButtonList.length - 1)
                        else if (event.angleDelta.y > 0)
                            tabBar.currentIndex = Math.max(tabBar.currentIndex - 1, 0)
                    }
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                }
            }

            Repeater {
                model: root.tabButtonList
                delegate: SecondaryTabButton {
                    selected: (index == currentTab)
                    buttonText: modelData.name
                    buttonIcon: modelData.icon
                }
            }
        }

        Item { // Tab indicator
            id: tabIndicator
            Layout.fillWidth: true
            height: 3
            property bool enableIndicatorAnimation: false
            Connections {
                target: root
                function onCurrentTabChanged() {
                    tabIndicator.enableIndicatorAnimation = true
                }
            }

            Rectangle {
                id: indicator
                property int tabCount: root.tabButtonList.length
                property real fullTabSize: root.width / tabCount;
                property real targetWidth: tabBar?.contentItem?.children[0]?.children[tabBar.currentIndex]?.tabContentWidth ?? 0

                implicitWidth: targetWidth
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                x: tabBar.currentIndex * fullTabSize + (fullTabSize - targetWidth) / 2

                color: Theme.Primary
                radius: Appearance.rounding.full

                Behavior on x {
                    enabled: tabIndicator.enableIndicatorAnimation
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

                Behavior on implicitWidth {
                    enabled: tabIndicator.enableIndicatorAnimation
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
            }
        }

        Rectangle { // Tabbar bottom border
            id: tabBarBottomBorder
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
        }

        SwipeView {
            id: swipeView
            Layout.topMargin: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            currentIndex: currentTab
            onCurrentIndexChanged: {
                tabIndicator.enableIndicatorAnimation = true
                currentTab = currentIndex
            }

            // To Do tab
            TaskList {
                id: unfinishedList
                listBottomPadding: root.fabSize + root.fabMargins * 2
                emptyPlaceholderIcon: "check_circle"
                emptyPlaceholderText: "No pending tasks!"
                taskList: TodoService.list
                    .map(function(item, i) { return Object.assign({}, item, {originalIndex: i}); })
                    .filter(function(item) { return !item.done; })
            }
            TaskList {
                id: doneList
                listBottomPadding: root.fabSize + root.fabMargins * 2
                emptyPlaceholderIcon: "checklist"
                emptyPlaceholderText: "Finished tasks will go here"
                taskList: TodoService.list
                    .map(function(item, i) { return Object.assign({}, item, {originalIndex: i}); })
                    .filter(function(item) { return item.done; })
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

    // // + FAB
    // StyledRectangularShadow {
    //     target: fabButton
    //     radius: fabButton.buttonRadius
    //     blur: 0.6 * Appearance.sizes.elevationMargin
    // }
    // FloatingActionButton {
    //     id: fabButton
    //     anchors.right: parent.right
    //     anchors.bottom: parent.bottom
    //     anchors.rightMargin: root.fabMargins
    //     anchors.bottomMargin: root.fabMargins

    //     onClicked: root.showAddDialog = true

    //     contentItem: MaterialSymbol {
    //         text: "add"
    //         horizontalAlignment: Text.AlignHCenter
    //         iconSize: Appearance.font.fontSize.huge
    //         color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
    //     }
    // }

    Item {
        anchors.fill: parent
        z: 9999

        visible: opacity > 0
        opacity: root.showAddDialog ? 1 : 0
        Behavior on opacity {
            NumberAnimation { 
                duration: Appearance.animation.elementMoveFast.duration
                easing.type: Appearance.animation.elementMoveFast.type
                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
            }
        }

        onVisibleChanged: {
            if (!visible) {
                todoInput.text = ""
                fabButton.focus = true
            }
        }

        Rectangle { // Scrim
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Theme.surfaceContainerHigh
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
            }
        }

        Rectangle { // The dialog
            id: dialog
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: root.dialogMargins
            implicitHeight: dialogColumnLayout.implicitHeight

            color: Theme.surfaceContainerHigh
            radius: Appearance.rounding.normal

            function addTask() {
                if (todoInput.text.length > 0) {
                    TodoService.addTask(todoInput.text)
                    todoInput.text = ""
                    root.showAddDialog = false
                    root.currentTab = 0 // Show unfinished tasks
                }
            }

            ColumnLayout {
                id: dialogColumnLayout
                anchors.fill: parent
                spacing: 16

                StyledText {
                    Layout.topMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignLeft
                    color: Theme.surfaceContainerHigh
                    font.pixelSize: Appearance.font.fontSize.extraLarge
                    text: "Add task"
                }

                TextField {
                    id: todoInput
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    padding: 10
                    color: Theme.surfaceContainerHigh
                    renderType: Text.NativeRendering
                    selectedTextColor: Theme.surfaceContainerHigh
                    selectionColor: Theme.surfaceContainerHigh
                    placeholderText: "Task description"
                    placeholderTextColor: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                    focus: root.showAddDialog
                    onAccepted: dialog.addTask()

                    background: Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.small
                        border.width: 2
                        border.color: todoInput.activeFocus ? Theme.Primary : Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                        color: "transparent"
                    }

                    cursorDelegate: Rectangle {
                        width: 1
                        color: todoInput.activeFocus ? Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7) : "transparent"
                        radius: 1
                    }
                }

                RowLayout {
                    Layout.bottomMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignRight
                    spacing: 5

                    Button {
                        buttonText: "Cancel"
                        onClicked: root.showAddDialog = false
                    }
                    Button {
                        buttonText: "Add"
                        enabled: todoInput.text.length > 0
                        onClicked: dialog.addTask()
                    }
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
