import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: taskListItem
    width: parent.width
    height: 60
    
    // The task object from the repeater model: { content, done, created }
    property var task: ({}) 
    
    // Signals to notify the repeater's parent (TodoTab) of user action
    signal statusChanged(bool isDone)
    signal deleted()

    Rectangle {
        anchors.fill: parent
        radius: 8
        border.color: "#A0A0A0" // Medium Gray
        border.width: 1
        color: "white"

        RowLayout {
            anchors.fill: parent
            spacing: 10
            anchors.margins: 10

            // 1. CheckBox for Status
            CheckBox {
                id: statusCheckBox
                Layout.preferredWidth: 30
                checked: task.done
                onCheckedChanged: statusChanged(checked)
            }

            // 2. Task Description/Content
            Text {
                id: taskDescriptionText
                Layout.fillWidth: true
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                color: task.done ? "gray" : "black"
                // Cross out the text if done
                textFormat: Text.RichText
                text: statusCheckBox.checked ? "<s>" + task.content + "</s>" : task.content
            }

            // 3. Date Added (Formatted)
            Text {
                id: dateAddedText
                Layout.preferredWidth: 100
                text: Qt.formatDate(new Date(task.created), "yyyy-MM-dd")
                font.pixelSize: 14
                color: "gray"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
            }
            
            // 4. Delete Button
            Button {
                Layout.preferredWidth: 30
                text: "X"
                font.bold: true
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "red"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: deleted()
            }
        }
    }
}