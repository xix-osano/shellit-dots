import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.synchronizer

Item {
    id: root
    required property var scopeRoot
    property string settingsQmlPath: Quickshell.shellPath("settings.qml")
    property int dashPadding: 10
    anchors.fill: parent
    property bool weatherEnabled: Config.options.bar.weather.enable
    property var tabButtonList: [
        ...([{"icon": "dashboard", "name": Translation.tr("Overview")}]),
        ...([{"icon": "music_note", "name": Translation.tr("Media")}]),
        ...([{"icon": "wallpaper", "name": Translation.tr("Wallpapers")}]),
        ...([{"icon": "hard_disk", "name": Translation.tr("Performance")}]),
        ...(root.weatherEnabled ? [{"icon": "wb_sunny", "name": Translation.tr("Weather")}] : []),
        ...([{"icon": "settings", "name": Translation.tr("Settings"), isAction: true}])
    ]
    property int selectedTab: 0
    property int tabCount: swipeView.count

    function focusActiveItem() {
        swipeView.currentItem.forceActiveFocus()
    }

    //onSelectedTabChanged: Qt.callLater(root.focusActiveItem)
    //keyboardFocusMode: WlrKeyboardFocus.Exclusive

    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                root.selectedTab = Math.min(root.selectedTab + 1, root.tabCount - 1)
                event.accepted = true;
            } 
            else if (event.key === Qt.Key_PageUp) {
                root.selectedTab = Math.max(root.selectedTab - 1, 0)
                event.accepted = true;
            }
            else if (event.key === Qt.Key_Tab) {
                root.selectedTab = (root.selectedTab + 1) % root.tabCount;
                event.accepted = true;
            }
            else if (event.key === Qt.Key_Backtab) {
                root.selectedTab = (root.selectedTab - 1 + root.tabCount) % root.tabCount;
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: dashPadding
        
        spacing: dashPadding

        PrimaryTabBar { // Tab strip
            id: tabBar
            visible: root.tabButtonList.length > 1
            tabButtonList: root.tabButtonList

            onActionTriggered: function(index) {
                let settingsIndex = weatherEnabled ? 5 : 4
                if (index === settingsIndex) {
                    //dashVisible = false
                    GlobalStates.dashOpen = false
                    Quickshell.execDetached(["qs", "-p", root.settingsQmlPath])
                }
            }

            Synchronizer on currentIndex {
                property alias source: root.selectedTab
            }
        }

        SwipeView { // Content pages
            id: swipeView
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            
            currentIndex: root.selectedTab
            onCurrentIndexChanged: {
                tabBar.enableIndicatorAnimation = true
                root.selectedTab = currentIndex
            }

            clip: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: swipeView.width
                    height: swipeView.height
                    radius: Appearance.rounding.small
                }
            }

            contentChildren: [
                ...([overview.createObject()]),
                ...([mediaPlayer.createObject()]),
                ...([wallpaper.createObject()]),
                ...([performance.createObject()]),
                ...(root.weatherEnabled ? [weather.createObject()] : [])
            ]
        }

        Component {
            id: overview
            OverviewTab {}
        }
        Component {
            id: mediaPlayer
            MediaPlayerTab {}
        }
        Component {
            id: wallpaper
            WallpaperTab {}
        }
        Component {
            id: performance
            PerformanceTab {}
        }
        Component {
            id: weather
            WeatherTab {}
        }
    }
}