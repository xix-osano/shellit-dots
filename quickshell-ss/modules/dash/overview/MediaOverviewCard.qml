import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell.Services.Mpris
import qs.modules.common
import qs.services
import qs.modules.common.widgets

Card {
    id: root
    clip: false

    signal clicked()

    property MprisPlayer activePlayer: MprisController.proactivePlayer
    property real currentPosition: activePlayer?.positionSupported ? activePlayer.position : 0
    property real displayPosition: currentPosition

    readonly property real ratio: {
        if (!activePlayer || activePlayer.length <= 0) return 0
        const pos = displayPosition % Math.max(1, activePlayer.length)
        const calculatedRatio = pos / activePlayer.length
        return Math.max(0, Math.min(1, calculatedRatio))
    }

    onActivePlayerChanged: {
        if (activePlayer?.positionSupported) {
            currentPosition = Qt.binding(() => activePlayer?.position || 0)
        } else {
            currentPosition = 0
        }
    }

    Timer {
        interval: 300
        running: activePlayer?.playbackState === MprisPlaybackState.Playing && !isSeeking
        repeat: true
        onTriggered: activePlayer?.positionSupported && activePlayer.positionChanged()
    }

    property bool isSeeking: false

    Column {
        anchors.centerIn: parent
        spacing: 8
        visible: !activePlayer

        StyledIcon {
            name: "music_note"
            size: 24
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            text: Translation.tr("No Media")
            font.pixelSize: 12
            color: Appearance.colors.colSubtext
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width - 4 * 2
        spacing: 16
        visible: activePlayer

        Item {
            width: 140
            height: 110
            anchors.horizontalCenter: parent.horizontalCenter
            clip: false

            StyledAlbumArt {
                width: 110
                height: 80
                anchors.centerIn: parent
                activePlayer: root.activePlayer
                albumSize: 76
                animationScale: 1.05
            }
        }

        Column {
            width: parent.width
            spacing: 4
            topPadding: 16

            StyledText {
                text: activePlayer?.trackTitle || "Unknown"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Appearance.colors.colSubtext
                width: parent.width
                elide: Text.ElideRight
                maximumLineCount: 1
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                text: activePlayer?.trackArtist || "Unknown Artist"
                font.pixelSize: 12
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.7)
                width: parent.width
                elide: Text.ElideRight
                maximumLineCount: 1
                horizontalAlignment: Text.AlignHCenter
            }
        }

        StyledSeekbar {
            width: parent.width + 4
            height: 20
            x: -2
            activePlayer: root.activePlayer
            isSeeking: root.isSeeking
            onIsSeekingChanged: root.isSeeking = isSeeking
        }

        Item {
            width: parent.width
            height: 32

            Row {
                spacing: 8
                anchors.centerIn: parent

            Rectangle {
                width: 28
                height: 28
                radius: 14
                anchors.verticalCenter: playPauseButton.verticalCenter
                color: prevArea.containsMouse ? Appearance.colors.colOnPrimaryContainer : "transparent"

                StyledIcon {
                    anchors.centerIn: parent
                    name: "skip_previous"
                    size: 14
                    color: Appearance.colors.colSubtext
                }

                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!activePlayer) return
                        if (activePlayer.position > 8 && activePlayer.canSeek) {
                            activePlayer.position = 0
                        } else {
                            activePlayer.previous()
                        }
                    }
                }
            }

            Rectangle {
                id: playPauseButton
                width: 32
                height: 32
                radius: 16
                color: Appearance.colors.colLayer1

                StyledIcon {
                    anchors.centerIn: parent
                    name: activePlayer?.playbackState === MprisPlaybackState.Playing ? "pause" : "play_arrow"
                    size: 16
                    color: Appearance.colors.colOnLayer0
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: activePlayer?.togglePlaying()
                }
            }

            Rectangle {
                width: 28
                height: 28
                radius: 14
                anchors.verticalCenter: playPauseButton.verticalCenter
                color: nextArea.containsMouse ? Appearance.colors.colOnPrimaryContainer : "transparent"

                StyledIcon {
                    anchors.centerIn: parent
                    name: "skip_next"
                    size: 14
                    color: Appearance.colors.colSubtext
                }

                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: activePlayer?.next()
                }
            }
            }
        }
    }

    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 123
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        visible: activePlayer
    }
}