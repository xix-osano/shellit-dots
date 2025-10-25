import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Common
import qs.Services

Item {
    id: root

    required property var powerMenuModalLoader
    required property var processListModalLoader
    required property var controlCenterLoader
    required property var ShellitDashPopoutLoader
    required property var notepadSlideoutVariants
    required property var hyprKeybindsModalLoader
    required property var ShellitBarLoader
    required property var hyprlandOverviewLoader

    IpcHandler {
        function open() {
            root.powerMenuModalLoader.active = true
            if (root.powerMenuModalLoader.item)
                root.powerMenuModalLoader.item.openCentered()

            return "POWERMENU_OPEN_SUCCESS"
        }

        function close() {
            if (root.powerMenuModalLoader.item)
                root.powerMenuModalLoader.item.close()

            return "POWERMENU_CLOSE_SUCCESS"
        }

        function toggle() {
            root.powerMenuModalLoader.active = true
            if (root.powerMenuModalLoader.item) {
                if (root.powerMenuModalLoader.item.shouldBeVisible) {
                    root.powerMenuModalLoader.item.close()
                } else {
                    root.powerMenuModalLoader.item.openCentered()
                }
            }

            return "POWERMENU_TOGGLE_SUCCESS"
        }

        target: "powermenu"
    }

    IpcHandler {
        function open(): string {
            root.processListModalLoader.active = true
            if (root.processListModalLoader.item)
                root.processListModalLoader.item.show()

            return "PROCESSLIST_OPEN_SUCCESS"
        }

        function close(): string {
            if (root.processListModalLoader.item)
                root.processListModalLoader.item.hide()

            return "PROCESSLIST_CLOSE_SUCCESS"
        }

        function toggle(): string {
            root.processListModalLoader.active = true
            if (root.processListModalLoader.item)
                root.processListModalLoader.item.toggle()

            return "PROCESSLIST_TOGGLE_SUCCESS"
        }

        target: "processlist"
    }

    IpcHandler {
        function open(): string {
            if (root.ShellitBarLoader.item) {
                root.ShellitBarLoader.item.triggerControlCenterOnFocusedScreen()
                return "CONTROL_CENTER_OPEN_SUCCESS"
            }
            return "CONTROL_CENTER_OPEN_FAILED"
        }

        function close(): string {
            if (root.controlCenterLoader.item) {
                root.controlCenterLoader.item.close()
                return "CONTROL_CENTER_CLOSE_SUCCESS"
            }
            return "CONTROL_CENTER_CLOSE_FAILED"
        }

        function toggle(): string {
            if (root.ShellitBarLoader.item) {
                root.ShellitBarLoader.item.triggerControlCenterOnFocusedScreen()
                return "CONTROL_CENTER_TOGGLE_SUCCESS"
            }
            return "CONTROL_CENTER_TOGGLE_FAILED"
        }

        target: "control-center"
    }

    IpcHandler {
        function open(tab: string): string {
            root.ShellitDashPopoutLoader.active = true
            if (root.ShellitDashPopoutLoader.item) {
                switch (tab.toLowerCase()) {
                case "media":
                    root.ShellitDashPopoutLoader.item.currentTabIndex = 1
                    break
                case "weather":
                    root.ShellitDashPopoutLoader.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0
                    break
                default:
                    root.ShellitDashPopoutLoader.item.currentTabIndex = 0
                    break
                }
                root.ShellitDashPopoutLoader.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen)
                root.ShellitDashPopoutLoader.item.dashVisible = true
                return "DASH_OPEN_SUCCESS"
            }
            return "DASH_OPEN_FAILED"
        }

        function close(): string {
            if (root.ShellitDashPopoutLoader.item) {
                root.ShellitDashPopoutLoader.item.dashVisible = false
                return "DASH_CLOSE_SUCCESS"
            }
            return "DASH_CLOSE_FAILED"
        }

        function toggle(tab: string): string {
            root.ShellitDashPopoutLoader.active = true
            if (root.ShellitDashPopoutLoader.item) {
                if (root.ShellitDashPopoutLoader.item.dashVisible) {
                    root.ShellitDashPopoutLoader.item.dashVisible = false
                } else {
                    switch (tab.toLowerCase()) {
                    case "media":
                        root.ShellitDashPopoutLoader.item.currentTabIndex = 1
                        break
                    case "weather":
                        root.ShellitDashPopoutLoader.item.currentTabIndex = SettingsData.weatherEnabled ? 2 : 0
                        break
                    default:
                        root.ShellitDashPopoutLoader.item.currentTabIndex = 0
                        break
                    }
                    root.ShellitDashPopoutLoader.item.setTriggerPosition(Screen.width / 2, Theme.barHeight + Theme.spacingS, 100, "center", Screen)
                    root.ShellitDashPopoutLoader.item.dashVisible = true
                }
                return "DASH_TOGGLE_SUCCESS"
            }
            return "DASH_TOGGLE_FAILED"
        }

        target: "dash"
    }

    IpcHandler {
        function getFocusedScreenName() {
            if (CompositorService.isHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.monitor) {
                return Hyprland.focusedWorkspace.monitor.name
            }
            if (CompositorService.isNiri && NiriService.currentOutput) {
                return NiriService.currentOutput
            }
            return ""
        }

        function getActiveNotepadInstance() {
            if (root.notepadSlideoutVariants.instances.length === 0) {
                return null
            }

            if (root.notepadSlideoutVariants.instances.length === 1) {
                return root.notepadSlideoutVariants.instances[0]
            }

            var focusedScreen = getFocusedScreenName()
            if (focusedScreen && root.notepadSlideoutVariants.instances.length > 0) {
                for (var i = 0; i < root.notepadSlideoutVariants.instances.length; i++) {
                    var slideout = root.notepadSlideoutVariants.instances[i]
                    if (slideout.modelData && slideout.modelData.name === focusedScreen) {
                        return slideout
                    }
                }
            }

            for (var i = 0; i < root.notepadSlideoutVariants.instances.length; i++) {
                var slideout = root.notepadSlideoutVariants.instances[i]
                if (slideout.isVisible) {
                    return slideout
                }
            }

            return root.notepadSlideoutVariants.instances[0]
        }

        function open(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.show()
                return "NOTEPAD_OPEN_SUCCESS"
            }
            return "NOTEPAD_OPEN_FAILED"
        }

        function close(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.hide()
                return "NOTEPAD_CLOSE_SUCCESS"
            }
            return "NOTEPAD_CLOSE_FAILED"
        }

        function toggle(): string {
            var instance = getActiveNotepadInstance()
            if (instance) {
                instance.toggle()
                return "NOTEPAD_TOGGLE_SUCCESS"
            }
            return "NOTEPAD_TOGGLE_FAILED"
        }

        target: "notepad"
    }

    IpcHandler {
        function toggle(): string {
            SessionService.toggleIdleInhibit()
            return SessionService.idleInhibited ? "Idle inhibit enabled" : "Idle inhibit disabled"
        }

        function enable(): string {
            SessionService.enableIdleInhibit()
            return "Idle inhibit enabled"
        }

        function disable(): string {
            SessionService.disableIdleInhibit()
            return "Idle inhibit disabled"
        }

        function status(): string {
            return SessionService.idleInhibited ? "Idle inhibit is enabled" : "Idle inhibit is disabled"
        }

        function reason(newReason: string): string {
            if (!newReason) {
                return `Current reason: ${SessionService.inhibitReason}`
            }

            SessionService.setInhibitReason(newReason)
            return `Inhibit reason set to: ${newReason}`
        }

        target: "inhibit"
    }

    IpcHandler {
        function list(): string {
            return MprisController.availablePlayers.map(p => p.identity).join("\n")
        }

        function play(): void {
            if (MprisController.activePlayer && MprisController.activePlayer.canPlay) {
                MprisController.activePlayer.play()
            }
        }

        function pause(): void {
            if (MprisController.activePlayer && MprisController.activePlayer.canPause) {
                MprisController.activePlayer.pause()
            }
        }

        function playPause(): void {
            if (MprisController.activePlayer && MprisController.activePlayer.canTogglePlaying) {
                MprisController.activePlayer.togglePlaying()
            }
        }

        function previous(): void {
            if (MprisController.activePlayer && MprisController.activePlayer.canGoPrevious) {
                MprisController.activePlayer.previous()
            }
        }

        function next(): void {
            if (MprisController.activePlayer && MprisController.activePlayer.canGoNext) {
                MprisController.activePlayer.next()
            }
        }

        function stop(): void {
            if (MprisController.activePlayer) {
                MprisController.activePlayer.stop()
            }
        }

        target: "mpris"
    }

    IpcHandler {
        function openBinds(): string {
            if (!CompositorService.isHyprland) {
                return "HYPR_NOT_AVAILABLE"
            }
            root.hyprKeybindsModalLoader.active = true
            if (root.hyprKeybindsModalLoader.item) {
                root.hyprKeybindsModalLoader.item.open()
                return "HYPR_KEYBINDS_OPEN_SUCCESS"
            }
            return "HYPR_KEYBINDS_OPEN_FAILED"
        }

        function closeBinds(): string {
            if (!CompositorService.isHyprland) {
                return "HYPR_NOT_AVAILABLE"
            }
            if (root.hyprKeybindsModalLoader.item) {
                root.hyprKeybindsModalLoader.item.close()
                return "HYPR_KEYBINDS_CLOSE_SUCCESS"
            }
            return "HYPR_KEYBINDS_CLOSE_FAILED"
        }

        function toggleBinds(): string {
            if (!CompositorService.isHyprland) {
                return "HYPR_NOT_AVAILABLE"
            }
            root.hyprKeybindsModalLoader.active = true
            if (root.hyprKeybindsModalLoader.item) {
                if (root.hyprKeybindsModalLoader.item.shouldBeVisible) {
                    root.hyprKeybindsModalLoader.item.close()
                } else {
                    root.hyprKeybindsModalLoader.item.open()
                }
                return "HYPR_KEYBINDS_TOGGLE_SUCCESS"
            }
            return "HYPR_KEYBINDS_TOGGLE_FAILED"
        }

        function toggleOverview(): string {
            if (!CompositorService.isHyprland || !root.hyprlandOverviewLoader.item) {
                return "HYPR_NOT_AVAILABLE"
            }
            root.hyprlandOverviewLoader.item.overviewOpen = !root.hyprlandOverviewLoader.item.overviewOpen
            return root.hyprlandOverviewLoader.item.overviewOpen ? "OVERVIEW_OPEN_SUCCESS" : "OVERVIEW_CLOSE_SUCCESS"
        }

        function closeOverview(): string {
            if (!CompositorService.isHyprland || !root.hyprlandOverviewLoader.item) {
                return "HYPR_NOT_AVAILABLE"
            }
            root.hyprlandOverviewLoader.item.overviewOpen = false
            return "OVERVIEW_CLOSE_SUCCESS"
        }

        function openOverview(): string {
            if (!CompositorService.isHyprland || !root.hyprlandOverviewLoader.item) {
                return "HYPR_NOT_AVAILABLE"
            }
            root.hyprlandOverviewLoader.item.overviewOpen = true
            return "OVERVIEW_OPEN_SUCCESS"
        }

        target: "hypr"
    }

    IpcHandler {
        function wallpaper(): string {
            if (root.ShellitBarLoader.item && root.ShellitBarLoader.item.triggerWallpaperBrowserOnFocusedScreen()) {
                return "SUCCESS: Toggled wallpaper browser"
            }
            return "ERROR: Failed to toggle wallpaper browser"
        }

        target: "Shellitdash"
    }
}
