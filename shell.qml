//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import Quickshell
import "." as Shellit

ShellRoot {
    id: root

    Shellit.Bar {}
    Shellit.Dock {}

    // Load build info
    Component.onCompleted: {
        console.log("Shellit version:", SHELLIT_VERSION, "commit:", SHELLIT_GIT_REVISION)
    }
}