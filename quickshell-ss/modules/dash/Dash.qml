import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope { // Scope
    id: root
    property bool detach: false
    property Component contentComponent: DashContent {}
    property Item dashContent

    Component.onCompleted: {
        root.dashContent = contentComponent.createObject(null, {
            "scopeRoot": root,
        });
        sidebarLoader.item.contentParent.children = [root.sidebarContent];
    }

    onDetachChanged: {
        if (root.detach) {
            dashContent.parent = null; // Detach content from dash
            dashLoader.active = false; // Unload dash
            detachedDashLoader.active = true; // Load detached window
            detachedDashLoader.item.contentParent.children = [dashContent];
        } else {
            dashContent.parent = null; // Detach content from window
            detachedDashLoader.active = false; // Unload detached window
            dashLoader.active = true; // Load sidebar
            dashLoader.item.contentParent.children = [dashContent];
        }
    }

    Loader {
        id: dashLoader
        active: true
        
        sourceComponent: PanelWindow { // Window
            id: dashRoot
            visible: GlobalStates.dashOpen
            
            property bool extend: false
            property real dashWidth: Appearance.sizes.dashWidth
            property real dahsHeight: Appearance.sizes.dashHeight
            property var contentParent: sidebarLeftBackground

            function hide() {
                GlobalStates.dashLeftOpen = false
            }

            exclusiveZone: 0
            implicitWidth: Appearance.sizes.dashWidth + Appearance.sizes.elevationMargin
            implicitHeight: Appearance.sizes.dashHeight
            WlrLayershell.namespace: "quickshell:dash"
            // Hyprland 0.49: OnDemand is Exclusive, Exclusive just breaks click-outside-to-close
            // WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            color: "transparent"

            anchors {
                top: true
                left: true
                bottom: true
            }

            mask: Region {
                item: dashBackground
            }

            HyprlandFocusGrab { // Click outside to close
                id: grab
                windows: [ dashRoot ]
                active: dashRoot.visible
                onActiveChanged: { // Focus the selected tab
                    if (active) dashBackground.children[0].focusActiveItem()
                }
                onCleared: () => {
                    if (!active) dashRoot.hide()
                }
            }

            // Content
            StyledRectangularShadow {
                target: dashBackground
                radius: dashBackground.radius
            }
            Rectangle {
                id: dashBackground
                anchors.top: parent.top
                anchors.topMargin: Appearance.sizes.hyprlandGapsOut
                anchors.horizontalCenter: parent.horizontalCenter
                width: dashRoot.dashWidth - Appearance.sizes.hyprlandGapsOut - Appearance.sizes.elevationMargin
                height: dashRoot.dashHeight
                color: Appearance.colors.colLayer0
                border.width: 1
                border.color: Appearance.colors.colLayer0Border
                radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1

                Behavior on width {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        dashRoot.hide();
                    }
                    if (event.modifiers === Qt.ControlModifier) {
                        if (event.key === Qt.Key_P) {
                            root.detach = !root.detach;
                        }
                        event.accepted = true;
                    }
                }
            }
        }
    }

    Loader {
        id: detachedDashLoader
        active: false

        sourceComponent: FloatingWindow {
            id: detachedDashRoot
            property var contentParent: detachedDashBackground

            visible: GlobalStates.dashOpen
            onVisibleChanged: {
                if (!visible) GlobalStates.dashOpen = false;
            }
            
            Rectangle {
                id: detachedDashBackground
                anchors.fill: parent
                color: Appearance.colors.colLayer0

                Keys.onPressed: (event) => {
                    if (event.modifiers === Qt.ControlModifier) {
                        if (event.key === Qt.Key_P) {
                            root.detach = !root.detach;
                        }
                        event.accepted = true;
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "dash"

        function toggle(): void {
            GlobalStates.dashOpen = !GlobalStates.dashOpen
        }

        function close(): void {
            GlobalStates.dashOpen = false
        }

        function open(): void {
            GlobalStates.dashOpen = true
        }
    }

    GlobalShortcut {
        name: "dashToggle"
        description: "Toggles dash on press"

        onPressed: {
            GlobalStates.dashOpen = !GlobalStates.dashOpen;
        }
    }

    GlobalShortcut {
        name: "dashOpen"
        description: "Opens dash on press"

        onPressed: {
            GlobalStates.dashOpen = true;
        }
    }

    GlobalShortcut {
        name: "dashClose"
        description: "Closes dash on press"

        onPressed: {
            GlobalStates.dashOpen = false;
        }
    }

    GlobalShortcut {
        name: "dashToggleDetach"
        description: "Detach dash into a window/Attach it back"

        onPressed: {
            root.detach = !root.detach;
        }
    }

}
