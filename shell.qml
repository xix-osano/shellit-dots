//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import "modules/drawers"
import "modules/dock"

import QtQuick
import Quickshell

ShellRoot {
    id: root

    Drawers {}
    Dock {}

    // Load build info
    Component.onCompleted: {
        console.log("Shellit version:", SHELLIT_VERSION, "commit:", SHELLIT_GIT_REVISION)
    }
}