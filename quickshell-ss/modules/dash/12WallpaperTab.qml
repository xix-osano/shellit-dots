import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.folderlistmodel          // ONLY external dependency kept
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    implicitWidth: 700
    implicitHeight: 410

    /*  --------------  PUBLIC API  --------------  */
    property url    folderUrl: ""               // folder to scan (file://...)  OR  ""
    property string currentWallpaper: ""        // full path to active wallpaper (file://...)
    property int    itemsPerPage: 16
    property bool   active: false               // enables keyboard + focus
    property alias  keyForwardTarget: root      // kept for compat, not used internally

    /*  --------------  READ-ONLY  --------------  */
    readonly property int totalPages: Math.max(1, Math.ceil(wallpaperModel.count / itemsPerPage))
    readonly property string selectedFileName: {
        if (!modelIndexValid()) return ""
        const path = wallpaperModel.get(mapToModel(gridIndex), "filePath").toString()
        return path.substring(path.lastIndexOf("/") + 1)
    }

    /*  --------------  INTERNAL  --------------  */
    property int currentPage: 0
    property int gridIndex: 0
    property bool enableAnimation: false
    property int lastPage: 0

    /*  --------------  SIGNALS  --------------  */
    signal wallpaperChosen(string filePath)     // emitted when user presses Enter or clicks
    signal browseRequested()                    // emitted when folder icon clicked

    /*  ================================================================  */
    /*  Helpers                                                            */
    /*  ================================================================  */
    function mapToModel(gridIdx) { return currentPage * itemsPerPage + gridIdx }
    function modelIndexValid() {
        const idx = mapToModel(gridIndex)
        return idx >= 0 && idx < wallpaperModel.count
    }

    /*  keep highlight in sync  */
    onGridIndexChanged => wallpaperGrid.currentIndex = gridIndex
    onCurrentPageChanged => {
        if (currentPage !== lastPage) enableAnimation = false
        lastPage = currentPage
    }

    /*  ================================================================  */
    /*  Keyboard handling (unchanged logic)                                */
    /*  ================================================================  */
    Keys.onPressed: (event) => root.handleKey(event) && (event.accepted = true)

    function handleKey(event) {
        const cols = 4
        const pageItemCount = Math.min(itemsPerPage, wallpaperModel.count - currentPage * itemsPerPage)

        /*  accept wallpaper  */
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (modelIndexValid()) {
                const path = wallpaperModel.get(mapToModel(gridIndex), "filePath").toString()
                root.wallpaperChosen(path.replace(/^file:\/\//, ""))
            }
            return true
        }

        /*  arrows + paging  */
        if (event.key === Qt.Key_Right) {
            if (gridIndex + 1 < pageItemCount) gridIndex++
            else if (currentPage < totalPages - 1) { gridIndex = 0; currentPage++ }
            return true
        }
        if (event.key === Qt.Key_Left) {
            if (gridIndex > 0) gridIndex--
            else if (currentPage > 0) {
                currentPage--
                gridIndex = Math.min(itemsPerPage, wallpaperModel.count - currentPage * itemsPerPage) - 1
            }
            return true
        }
        if (event.key === Qt.Key_Down) {
            if (gridIndex + cols < pageItemCount) gridIndex += cols
            else if (currentPage < totalPages - 1) { gridIndex = gridIndex % cols; currentPage++ }
            return true
        }
        if (event.key === Qt.Key_Up) {
            if (gridIndex >= cols) gridIndex -= cols
            else if (currentPage > 0) {
                currentPage--
                const prevCount = Math.min(itemsPerPage, wallpaperModel.count - currentPage * itemsPerPage)
                gridIndex = Math.min(Math.floor((prevCount - 1) / cols) * cols + (gridIndex % cols),
                                     prevCount - 1)
            }
            return true
        }
        if (event.key === Qt.Key_PageUp   && currentPage > 0)       { gridIndex = 0; currentPage--; return true }
        if (event.key === Qt.Key_PageDown && currentPage < totalPages - 1) { gridIndex = 0; currentPage++; return true }
        if (event.key === Qt.Key_Home && event.modifiers & Qt.ControlModifier) { currentPage = 0; gridIndex = 0; return true }
        if (event.key === Qt.Key_End  && event.modifiers & Qt.ControlModifier) {
            currentPage = totalPages - 1
            gridIndex = Math.max(0, Math.min(itemsPerPage, wallpaperModel.count - currentPage * itemsPerPage) - 1)
            return true
        }
        return false
    }

    /*  ================================================================  */
    /*  Folder model  */
    /*  ================================================================  */
    FolderListModel {
        id: wallpaperModel
        folder: root.folderUrl
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
        showDirs: false; showFiles: true; showHidden: false
        sortField: FolderListModel.Name
    }

    /*  ================================================================  */
    /*  UI  */
    /*  ================================================================  */
    Column {
        anchors.fill: parent
        spacing: 0

        /*  ---------------  Grid  ---------------  */
        Item {
            width: parent.width
            height: parent.height - 50

            GridView {
                id: wallpaperGrid
                anchors.centerIn: parent
                width: parent.width - 8
                height: parent.height - 8
                cellWidth: width / 4
                cellHeight: height / 4
                clip: true
                interactive: active
                boundsBehavior: Flickable.StopAtBounds
                keyNavigationEnabled: false
                highlightFollowsCurrentItem: true
                highlightMoveDuration: enableAnimation ? 400 : 0

                model: {
                    const start = currentPage * itemsPerPage
                    const end   = Math.min(start + itemsPerPage, wallpaperModel.count)
                    const arr   = []
                    for (let i = start; i < end; ++i) {
                        arr.push(wallpaperModel.get(i, "filePath").toString())
                    }
                    return arr
                }
                onCountChanged => currentIndex = Math.min(gridIndex, count - 1)

                highlight: Rectangle {
                    z: 1000
                    anchors.fill: parent
                    anchors.margins: 4
                    color: "transparent"
                    border.width: 3
                    border.color: Appearance.m3colors.m3primary
                    radius: Appearance.rounding.small
                }

                delegate: Item {
                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight

                    property string imgPath: modelData
                    property bool isSelected: root.currentWallpaper === imgPath

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        color: Appearance.colors.colSurfaceContainerHighest
                        radius: Appearance.rounding.small
                        clip: true

                        Rectangle {
                            anchors.fill: parent
                            color: isSelected ? Appearance.colors.colPrimary : "transparent"
                            radius: parent.radius
                            Behavior on color { ColorAnimation { duration: 400; easing.type: Easing.OutCubic } }
                        }

                        Image {
                            id: thumb
                            anchors.fill: parent
                            source: imgPath
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskThresholdMin: 0.5
                                maskSpreadAtMin: 1.0
                                maskSource: ShaderEffectSource {
                                    sourceItem: Rectangle {
                                        width: thumb.width
                                        height: thumb.height
                                        radius: Appearance.rounding.small
                                    }
                                }
                            }
                        }

                        BusyIndicator {
                            anchors.centerIn: parent
                            running: thumb.status === Image.Loading
                            visible: running
                        }

                        StateLayer {
                            anchors.fill: parent
                            cornerRadius: parent.radius
                            stateColor: Appearance.colors.colPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                gridIndex = index
                                root.wallpaperChosen(imgPath.replace(/^file:\/\//, ""))
                            }
                        }
                    }
                }
            }

            StyledText {
                anchors.centerIn: parent
                visible: wallpaperModel.count === 0
                text: "No wallpapers found\n\nClick the folder icon below to browse"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                color: Appearance.colors.colOutlineVariant
            }
        }

        /*  ---------------  footer  ---------------  */
        Column {
            width: parent.width
            height: 50
            Row {
                width: parent.width
                height: 32
                spacing: 8

                Item { width: (parent.width - controlsRow.width - browseBtn.width - 8) / 2; height: parent.height }

                Row {
                    id: controlsRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    StyledActionButton {
                        iconName: "skip_previous"; iconSize: 20; buttonSize: 32
                        enabled: currentPage > 0; opacity: enabled ? 1.0 : 0.3
                        onClicked: --currentPage
                    }
                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: wallpaperModel.count
                              ? `${wallpaperModel.count} wallpapers  •  ${currentPage + 1} / ${totalPages}`
                              : "No wallpapers"
                        font.pixelSize: 14
                        color: Appearance.colors.colSubtext
                        opacity: 0.7
                    }
                    StyledActionButton {
                        iconName: "skip_next"; iconSize: 20; buttonSize: 32
                        enabled: currentPage < totalPages - 1; opacity: enabled ? 1.0 : 0.3
                        onClicked: ++currentPage
                    }
                }

                StyledActionButton {
                    id: browseBtn
                    iconName: "folder_open"; iconSize: 20; buttonSize: 32
                    opacity: 0.7
                    onClicked: root.browseRequested()
                }
            }

            StyledText {
                width: parent.width
                height: 18
                text: selectedFileName
                visible: selectedFileName !== ""
                font.pixelSize: 12
                color: Appearance.colors.colSubtext
                opacity: 0.5
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}