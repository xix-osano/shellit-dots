import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Widgets

Rectangle {
    id: resultsContainer

    // DEVELOPER NOTE: This component renders the Spotlight launcher (accessed via Mod+Space).
    // Changes to launcher behavior, especially item rendering, filtering, or model structure,
    // likely require corresponding updates in Modules/AppDrawer/AppLauncher.qml and vice versa.

    property var appLauncher: null
    property var contextMenu: null

    function resetScroll() {
        resultsList.contentY = 0
        resultsGrid.contentY = 0
    }

    width: parent.width
    height: parent.height - y
    radius: Theme.cornerRadius
    color: "transparent"
    clip: true

    ShellitListView {
        id: resultsList

        property int itemHeight: 60
        property int iconSize: 40
        property bool showDescription: true
        property int itemSpacing: Theme.spacingS
        property bool hoverUpdatesSelection: false
        property bool keyboardNavigationActive: appLauncher ? appLauncher.keyboardNavigationActive : false

        signal keyboardNavigationReset
        signal itemClicked(int index, var modelData)
        signal itemRightClicked(int index, var modelData, real mouseX, real mouseY)

        function ensureVisible(index) {
            if (index < 0 || index >= count)
                return

            const itemY = index * (itemHeight + itemSpacing)
            const itemBottom = itemY + itemHeight
            if (itemY < contentY)
                contentY = itemY
            else if (itemBottom > contentY + height)
                contentY = itemBottom - height
        }

        anchors.fill: parent
        anchors.margins: Theme.spacingS
        visible: appLauncher && appLauncher.viewMode === "list"
        model: appLauncher ? appLauncher.model : null
        currentIndex: appLauncher ? appLauncher.selectedIndex : -1
        clip: true
        spacing: itemSpacing
        focus: true
        interactive: true
        cacheBuffer: Math.max(0, Math.min(height * 2, 1000))
        reuseItems: true
        onCurrentIndexChanged: {
            if (keyboardNavigationActive)
                ensureVisible(currentIndex)
        }
        onItemClicked: (index, modelData) => {
                           if (appLauncher)
                           appLauncher.launchApp(modelData)
                       }
        onItemRightClicked: (index, modelData, mouseX, mouseY) => {
                                if (contextMenu)
                                contextMenu.show(mouseX, mouseY, modelData)
                            }
        onKeyboardNavigationReset: () => {
                                       if (appLauncher)
                                       appLauncher.keyboardNavigationActive = false
                                   }

        delegate: Rectangle {
            width: ListView.view.width
            height: resultsList.itemHeight
            radius: Theme.cornerRadius
            color: ListView.isCurrentItem ? Theme.primaryPressed : listMouseArea.containsMouse ? Theme.primaryHoverLight : Theme.surfaceContainerHigh

            Row {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingL

                Item {
                    width: resultsList.iconSize
                    height: resultsList.iconSize
                    anchors.verticalCenter: parent.verticalCenter
                    visible: model.icon !== undefined && model.icon !== ""

                    property string iconValue: model.icon || ""
                    property bool isMaterial: iconValue.indexOf("material:") === 0
                    property string materialName: isMaterial ? iconValue.substring(9) : ""

                    ShellitIcon {
                        anchors.centerIn: parent
                        name: parent.materialName
                        size: resultsList.iconSize
                        color: Theme.surfaceText
                        visible: parent.isMaterial
                    }

                    IconImage {
                        id: listIconImg

                        anchors.fill: parent
                        source: parent.isMaterial ? "" : Quickshell.iconPath(parent.iconValue, true)
                        asynchronous: true
                        visible: !parent.isMaterial && status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: !parent.isMaterial && !listIconImg.visible
                        color: Theme.surfaceLight
                        radius: Theme.cornerRadius
                        border.width: 1
                        border.color: Theme.primarySelected

                        StyledText {
                            anchors.centerIn: parent
                            text: (model.name && model.name.length > 0) ? model.name.charAt(0).toUpperCase() : "A"
                            font.pixelSize: resultsList.iconSize * 0.4
                            color: Theme.primary
                            font.weight: Font.Bold
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: (model.icon !== undefined && model.icon !== "") ? (parent.width - resultsList.iconSize - Theme.spacingL) : parent.width
                    spacing: Theme.spacingXS

                    StyledText {
                        width: parent.width
                        text: model.name || ""
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        maximumLineCount: 1
                    }

                    StyledText {
                        width: parent.width
                        text: model.comment || "Application"
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceVariantText
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        visible: resultsList.showDescription && model.comment && model.comment.length > 0
                    }
                }
            }

            MouseArea {
                id: listMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                z: 10
                onEntered: () => {
                               if (resultsList.hoverUpdatesSelection && !resultsList.keyboardNavigationActive)
                               resultsList.currentIndex = index
                           }
                onPositionChanged: () => {
                                       resultsList.keyboardNavigationReset()
                                   }
                onClicked: mouse => {
                               if (mouse.button === Qt.LeftButton) {
                                   resultsList.itemClicked(index, model)
                               } else if (mouse.button === Qt.RightButton && !model.isPlugin) {
                                   const globalPos = mapToItem(null, mouse.x, mouse.y)
                                   const modalPos = resultsContainer.parent.mapFromItem(null, globalPos.x, globalPos.y)
                                   resultsList.itemRightClicked(index, model, modalPos.x, modalPos.y)
                               }
                           }
            }
        }
    }

    ShellitGridView {
        id: resultsGrid

        property int currentIndex: appLauncher ? appLauncher.selectedIndex : -1
        property int columns: 4
        property bool adaptiveColumns: false
        property int minCellWidth: 120
        property int maxCellWidth: 160
        property int cellPadding: 8
        property real iconSizeRatio: 0.55
        property int maxIconSize: 48
        property int minIconSize: 32
        property bool hoverUpdatesSelection: false
        property bool keyboardNavigationActive: appLauncher ? appLauncher.keyboardNavigationActive : false
        property int baseCellWidth: adaptiveColumns ? Math.max(minCellWidth, Math.min(maxCellWidth, width / columns)) : (width - Theme.spacingS * 2) / columns
        property int baseCellHeight: baseCellWidth + 20
        property int actualColumns: adaptiveColumns ? Math.floor(width / cellWidth) : columns
        property int remainingSpace: width - (actualColumns * cellWidth)

        signal keyboardNavigationReset
        signal itemClicked(int index, var modelData)
        signal itemRightClicked(int index, var modelData, real mouseX, real mouseY)

        function ensureVisible(index) {
            if (index < 0 || index >= count)
                return

            const itemY = Math.floor(index / actualColumns) * cellHeight
            const itemBottom = itemY + cellHeight
            if (itemY < contentY)
                contentY = itemY
            else if (itemBottom > contentY + height)
                contentY = itemBottom - height
        }

        anchors.fill: parent
        anchors.margins: Theme.spacingS
        visible: appLauncher && appLauncher.viewMode === "grid"
        model: appLauncher ? appLauncher.model : null
        clip: true
        cellWidth: baseCellWidth
        cellHeight: baseCellHeight
        leftMargin: Math.max(Theme.spacingS, remainingSpace / 2)
        rightMargin: leftMargin
        focus: true
        interactive: true
        cacheBuffer: Math.max(0, Math.min(height * 2, 1000))
        reuseItems: true
        onCurrentIndexChanged: {
            if (keyboardNavigationActive)
                ensureVisible(currentIndex)
        }
        onItemClicked: (index, modelData) => {
                           if (appLauncher)
                           appLauncher.launchApp(modelData)
                       }
        onItemRightClicked: (index, modelData, mouseX, mouseY) => {
                                if (contextMenu)
                                contextMenu.show(mouseX, mouseY, modelData)
                            }
        onKeyboardNavigationReset: () => {
                                       if (appLauncher)
                                       appLauncher.keyboardNavigationActive = false
                                   }

        delegate: Rectangle {
            width: resultsGrid.cellWidth - resultsGrid.cellPadding
            height: resultsGrid.cellHeight - resultsGrid.cellPadding
            radius: Theme.cornerRadius
            color: resultsGrid.currentIndex === index ? Theme.primaryPressed : gridMouseArea.containsMouse ? Theme.primaryHoverLight : Theme.surfaceContainerHigh

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacingS

                Item {
                    property int iconSize: Math.min(resultsGrid.maxIconSize, Math.max(resultsGrid.minIconSize, resultsGrid.cellWidth * resultsGrid.iconSizeRatio))

                    width: iconSize
                    height: iconSize
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: model.icon !== undefined && model.icon !== ""

                    property string iconValue: model.icon || ""
                    property bool isMaterial: iconValue.indexOf("material:") === 0
                    property string materialName: isMaterial ? iconValue.substring(9) : ""

                    ShellitIcon {
                        anchors.centerIn: parent
                        name: parent.materialName
                        size: parent.iconSize
                        color: Theme.surfaceText
                        visible: parent.isMaterial
                    }

                    IconImage {
                        id: gridIconImg

                        anchors.fill: parent
                        source: parent.isMaterial ? "" : Quickshell.iconPath(parent.iconValue, true)
                        smooth: true
                        asynchronous: true
                        visible: !parent.isMaterial && status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: !parent.isMaterial && !gridIconImg.visible
                        color: Theme.surfaceLight
                        radius: Theme.cornerRadius
                        border.width: 1
                        border.color: Theme.primarySelected

                        StyledText {
                            anchors.centerIn: parent
                            text: (model.name && model.name.length > 0) ? model.name.charAt(0).toUpperCase() : "A"
                            font.pixelSize: Math.min(28, parent.width * 0.5)
                            color: Theme.primary
                            font.weight: Font.Bold
                        }
                    }
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: resultsGrid.cellWidth - 12
                    text: model.name || ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 1
                    wrapMode: Text.NoWrap
                }
            }

            MouseArea {
                id: gridMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                z: 10
                onEntered: () => {
                               if (resultsGrid.hoverUpdatesSelection && !resultsGrid.keyboardNavigationActive)
                               resultsGrid.currentIndex = index
                           }
                onPositionChanged: () => {
                                       resultsGrid.keyboardNavigationReset()
                                   }
                onClicked: mouse => {
                               if (mouse.button === Qt.LeftButton) {
                                   resultsGrid.itemClicked(index, model)
                               } else if (mouse.button === Qt.RightButton && !model.isPlugin) {
                                   const globalPos = mapToItem(null, mouse.x, mouse.y)
                                   const modalPos = resultsContainer.parent.mapFromItem(null, globalPos.x, globalPos.y)
                                   resultsGrid.itemRightClicked(index, model, modalPos.x, modalPos.y)
                               }
                           }
            }
        }
    }
}
