//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1


import qs.modules.shellitbar
import qs.modules.dock
import qs.utils.modals

import QtQuick
import QtQuick.Window
import Quickshell
import qs.services

ShellRoot {
    id: root

    // Enable/disable modules here. False = not loaded at all, so rest assured
    // no unnecessary stuff will take up memory if you decide to only use, say, the overview.
    property bool enableShellitBar: true
    property bool enableDock: true


    LazyLoader { active: enableShellitBar && Config.ready && !Config.options.bar.vertical; component: ShellitBar {} }
    LazyLoader { active: enableDock && Config.options.dock.enable; component: Dock {} }

    // Load build info
    Component.onCompleted: {
        console.log("Shellit version:", SHELLIT_VERSION, "commit:", SHELLIT_GIT_REVISION)
    }
}
