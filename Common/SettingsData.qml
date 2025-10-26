pragma Singleton

pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

Singleton {
    id: root

    readonly property int settingsConfigVersion: 1

    enum Position {
        Top,
        Bottom,
        Left,
        Right
    }

    enum AnimationSpeed {
        None,
        Short,
        Medium,
        Long,
        Custom
    }

    readonly property string defaultFontFamily: "Inter Variable"
    readonly property string defaultMonoFontFamily: "Fira Code"
    readonly property string _homeUrl: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    readonly property string _configUrl: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
    readonly property string _configDir: Paths.strip(_configUrl)
    readonly property string pluginSettingsPath: _configDir + "/Shellit/plugin_settings.json"

    property bool _loading: false
    property bool _pluginSettingsLoading: false
    property bool hasTriedDefaultSettings: false
    property var pluginSettings: ({})

    property alias shellitBarLeftWidgetsModel: leftWidgetsModel
    property alias shellitBarCenterWidgetsModel: centerWidgetsModel
    property alias shellitBarRightWidgetsModel: rightWidgetsModel

    property string currentThemeName: "blue"
    property string customThemeFile: ""
    property string matugenScheme: "scheme-tonal-spot"
    property bool runUserMatugenTemplates: true
    property real shellitBarTransparency: 1.0
    property real shellitBarWidgetTransparency: 1.0
    property real popupTransparency: 1.0
    property real dockTransparency: 1
    property string widgetBackgroundColor: "sch"
    property string surfaceBase: "s"
    property real cornerRadius: 12

    property bool use24HourClock: true
    property bool showSeconds: false
    property bool useFahrenheit: false
    property bool nightModeEnabled: false
    property int animationSpeed: SettingsData.AnimationSpeed.Short
    property int customAnimationDuration: 500
    property string wallpaperFillMode: "Fill"
    property bool blurredWallpaperLayer: false
    property bool blurWallpaperOnOverview: false

    property bool showLauncherButton: true
    property bool showWorkspaceSwitcher: true
    property bool showFocusedWindow: true
    property bool showWeather: true
    property bool showMusic: true
    property bool showClipboard: true
    property bool showCpuUsage: true
    property bool showMemUsage: true
    property bool showCpuTemp: true
    property bool showGpuTemp: true
    property int selectedGpuIndex: 0
    property var enabledGpuPciIds: []
    property bool showSystemTray: true
    property bool showClock: true
    property bool showNotificationButton: true
    property bool showBattery: true
    property bool showControlCenterButton: true

    property bool controlCenterShowNetworkIcon: true
    property bool controlCenterShowBluetoothIcon: true
    property bool controlCenterShowAudioIcon: true
    property var controlCenterWidgets: [
        {"id": "volumeSlider", "enabled": true, "width": 50},
        {"id": "brightnessSlider", "enabled": true, "width": 50},
        {"id": "wifi", "enabled": true, "width": 50},
        {"id": "bluetooth", "enabled": true, "width": 50},
        {"id": "audioOutput", "enabled": true, "width": 50},
        {"id": "audioInput", "enabled": true, "width": 50},
        {"id": "nightMode", "enabled": true, "width": 50},
        {"id": "darkMode", "enabled": true, "width": 50}
    ]

    property bool showWorkspaceIndex: false
    property bool showWorkspacePadding: false
    property bool workspaceScrolling: false
    property bool showWorkspaceApps: false
    property int maxWorkspaceIcons: 3
    property bool workspacesPerMonitor: true
    property var workspaceNameIcons: ({})
    property bool waveProgressEnabled: true
    property bool clockCompactMode: false
    property bool focusedWindowCompactMode: false
    property bool runningAppsCompactMode: true
    property bool runningAppsCurrentWorkspace: false
    property bool runningAppsGroupByApp: false
    property string clockDateFormat: ""
    property string lockDateFormat: ""
    property int mediaSize: 1

    property var shellitBarLeftWidgets: ["launcherButton", "workspaceSwitcher", "focusedWindow"]
    property var shellitBarCenterWidgets: ["music", "clock", "weather"]
    property var shellitBarRightWidgets: ["systemTray", "clipboard", "cpuUsage", "memUsage", "notificationButton", "battery", "controlCenterButton"]
    property var shellitBarWidgetOrder: []

    property string appLauncherViewMode: "list"
    property string spotlightModalViewMode: "list"
    property bool sortAppsAlphabetically: false

    property string weatherLocation: "New York, NY"
    property string weatherCoordinates: "40.7128,-74.0060"
    property bool useAutoLocation: false
    property bool weatherEnabled: true

    property string networkPreference: "auto"

    property string iconTheme: "System Default"
    property var availableIconThemes: ["System Default"]
    property string systemDefaultIconTheme: ""
    property bool qt5ctAvailable: false
    property bool qt6ctAvailable: false
    property bool gtkAvailable: false

    property string launcherLogoMode: "apps"
    property string launcherLogoCustomPath: ""
    property string launcherLogoColorOverride: ""
    property bool launcherLogoColorInvertOnMode: false
    property real launcherLogoBrightness: 0.5
    property real launcherLogoContrast: 1
    property int launcherLogoSizeOffset: 0

    property string fontFamily: "Inter Variable"
    property string monoFontFamily: "Fira Code"
    property int fontWeight: Font.Normal
    property real fontScale: 1.0
    property real shellitBarFontScale: 1.0

    property bool notepadUseMonospace: true
    property string notepadFontFamily: ""
    property real notepadFontSize: 14
    property bool notepadShowLineNumbers: false
    property real notepadTransparencyOverride: -1
    property real notepadLastCustomTransparency: 0.7

    onNotepadUseMonospaceChanged: saveSettings()
    onNotepadFontFamilyChanged: saveSettings()
    onNotepadFontSizeChanged: saveSettings()
    onNotepadShowLineNumbersChanged: saveSettings()
    onNotepadTransparencyOverrideChanged: {
        if (notepadTransparencyOverride > 0) {
            notepadLastCustomTransparency = notepadTransparencyOverride
        }
        saveSettings()
    }
    onNotepadLastCustomTransparencyChanged: saveSettings()

    property bool soundsEnabled: true
    property bool useSystemSoundTheme: false
    property bool soundNewNotification: true
    property bool soundVolumeChanged: true
    property bool soundPluggedIn: true

    property int acMonitorTimeout: 0
    property int acLockTimeout: 0
    property int acSuspendTimeout: 0
    property int acHibernateTimeout: 0
    property int batteryMonitorTimeout: 0
    property int batteryLockTimeout: 0
    property int batterySuspendTimeout: 0
    property int batteryHibernateTimeout: 0
    property bool lockBeforeSuspend: false
    property bool loginctlLockIntegration: true
    property string launchPrefix: ""
    property var brightnessDevicePins: ({})

    property bool gtkThemingEnabled: false
    property bool qtThemingEnabled: false
    property bool syncModeWithPortal: true

    property bool showDock: false
    property bool dockAutoHide: false
    property bool dockGroupByApp: false
    property bool dockOpenOnOverview: false
    property int dockPosition: SettingsData.Position.Bottom
    property real dockSpacing: 4
    property real dockBottomGap: 0
    property real dockIconSize: 40
    property string dockIndicatorStyle: "circle"

    property bool notificationOverlayEnabled: false
    property bool shellitBarAutoHide: false
    property bool shellitBarOpenOnOverview: false
    property bool shellitBarVisible: true
    property int overviewRows: 2
    property int overviewColumns: 5
    property real overviewScale: 0.16
    property real shellitBarSpacing: 4
    property real shellitBarBottomGap: 0
    property real shellitBarInnerPadding: 4
    property int shellitBarPosition: SettingsData.Position.Top
    property bool shellitBarIsVertical: shellitBarPosition === SettingsData.Position.Left || shellitBarPosition === SettingsData.Position.Right

    property bool shellitBarSquareCorners: false
    property bool shellitBarNoBackground: false
    property bool shellitBarGothCornersEnabled: false
    property bool shellitBarBorderEnabled: false
    property string shellitBarBorderColor: "surfaceText"
    property real shellitBarBorderOpacity: 1.0
    property real shellitBarBorderThickness: 1

    onShellitBarBorderColorChanged: saveSettings()
    onShellitBarBorderOpacityChanged: saveSettings()
    onShellitBarBorderThicknessChanged: saveSettings()

    property bool popupGapsAuto: true
    property int popupGapsManual: 4

    property bool lockScreenShowPowerActions: true
    property bool enableFprint: false
    property int maxFprintTries: 3
    property bool fprintdAvailable: false
    property bool hideBrightnessSlider: false

    property int notificationTimeoutLow: 5000
    property int notificationTimeoutNormal: 5000
    property int notificationTimeoutCritical: 0
    property int notificationPopupPosition: SettingsData.Position.Top

    property bool osdAlwaysShowValue: false

    property bool powerActionConfirm: true
    property string customPowerActionLock: ""
    property string customPowerActionLogout: ""
    property string customPowerActionSuspend: ""
    property string customPowerActionHibernate: ""
    property string customPowerActionReboot: ""
    property string customPowerActionPowerOff: ""

    property bool updaterUseCustomCommand: false
    property string updaterCustomCommand: ""
    property string updaterTerminalAdditionalParams: ""

    property var screenPreferences: ({})
    property var showOnLastDisplay: ({})

    signal forceShellitBarLayoutRefresh
    signal forceDockLayoutRefresh
    signal widgetDataChanged
    signal workspaceIconsUpdated

    Component.onCompleted: {
        loadSettings()
        fontCheckTimer.start()
        initializeListModels()
        fprintdDetectionProcess.running = true
    }

    function loadSettings() {
        _loading = true
        parseSettings(settingsFile.text())
        _loading = false
        loadPluginSettings()
    }

    function loadPluginSettings() {
        _pluginSettingsLoading = true
        parsePluginSettings(pluginSettingsFile.text())
        _pluginSettingsLoading = false
    }

    function parsePluginSettings(content) {
        _pluginSettingsLoading = true
        try {
            if (content && content.trim()) {
                pluginSettings = JSON.parse(content)
            } else {
                pluginSettings = {}
            }
        } catch (e) {
            console.warn("SettingsData: Failed to parse plugin settings:", e.message)
            pluginSettings = {}
        } finally {
            _pluginSettingsLoading = false
        }
    }

    function parseSettings(content) {
        _loading = true
        var shouldMigrate = false
        try {
            if (content && content.trim()) {
                var settings = JSON.parse(content)
                if (settings.pluginSettings !== undefined) {
                    pluginSettings = settings.pluginSettings
                    shouldMigrate = true
                }
                if (settings.themeIndex !== undefined || settings.themeIsDynamic !== undefined) {
                    const themeNames = ["blue", "deepBlue", "purple", "green", "orange", "red", "cyan", "pink", "amber", "coral"]
                    if (settings.themeIsDynamic) {
                        currentThemeName = "dynamic"
                    } else if (settings.themeIndex >= 0 && settings.themeIndex < themeNames.length) {
                        currentThemeName = themeNames[settings.themeIndex]
                    }
                    console.info("Auto-migrated theme from index", settings.themeIndex, "to", currentThemeName)
                } else {
                    currentThemeName = settings.currentThemeName !== undefined ? settings.currentThemeName : "blue"
                }
                customThemeFile = settings.customThemeFile !== undefined ? settings.customThemeFile : ""
                matugenScheme = settings.matugenScheme !== undefined ? settings.matugenScheme : "scheme-tonal-spot"
                runUserMatugenTemplates = settings.runUserMatugenTemplates !== undefined ? settings.runUserMatugenTemplates : true
                shellitBarTransparency = settings.shellitBarTransparency !== undefined ? (settings.shellitBarTransparency > 1 ? settings.shellitBarTransparency / 100 : settings.shellitBarTransparency) : (settings.topBarTransparency !== undefined ? (settings.topBarTransparency > 1 ? settings.topBarTransparency / 100 : settings.topBarTransparency) : 1.0)
                shellitBarWidgetTransparency = settings.shellitBarWidgetTransparency !== undefined ? (settings.shellitBarWidgetTransparency > 1 ? settings.shellitBarWidgetTransparency / 100 : settings.shellitBarWidgetTransparency) : (settings.topBarWidgetTransparency !== undefined ? (settings.topBarWidgetTransparency > 1 ? settings.topBarWidgetTransparency / 100 : settings.topBarWidgetTransparency) : 1.0)
                popupTransparency = settings.popupTransparency !== undefined ? (settings.popupTransparency > 1 ? settings.popupTransparency / 100 : settings.popupTransparency) : 1.0
                dockTransparency = settings.dockTransparency !== undefined ? (settings.dockTransparency > 1 ? settings.dockTransparency / 100 : settings.dockTransparency) : 1
                use24HourClock = settings.use24HourClock !== undefined ? settings.use24HourClock : true
                showSeconds = settings.showSeconds !== undefined ? settings.showSeconds : false
                useFahrenheit = settings.useFahrenheit !== undefined ? settings.useFahrenheit : false
                nightModeEnabled = settings.nightModeEnabled !== undefined ? settings.nightModeEnabled : false
                weatherLocation = settings.weatherLocation !== undefined ? settings.weatherLocation : "New York, NY"
                weatherCoordinates = settings.weatherCoordinates !== undefined ? settings.weatherCoordinates : "40.7128,-74.0060"
                useAutoLocation = settings.useAutoLocation !== undefined ? settings.useAutoLocation : false
                weatherEnabled = settings.weatherEnabled !== undefined ? settings.weatherEnabled : true
                showLauncherButton = settings.showLauncherButton !== undefined ? settings.showLauncherButton : true
                showWorkspaceSwitcher = settings.showWorkspaceSwitcher !== undefined ? settings.showWorkspaceSwitcher : true
                showFocusedWindow = settings.showFocusedWindow !== undefined ? settings.showFocusedWindow : true
                showWeather = settings.showWeather !== undefined ? settings.showWeather : true
                showMusic = settings.showMusic !== undefined ? settings.showMusic : true
                showClipboard = settings.showClipboard !== undefined ? settings.showClipboard : true
                showCpuUsage = settings.showCpuUsage !== undefined ? settings.showCpuUsage : true
                showMemUsage = settings.showMemUsage !== undefined ? settings.showMemUsage : true
                showCpuTemp = settings.showCpuTemp !== undefined ? settings.showCpuTemp : true
                showGpuTemp = settings.showGpuTemp !== undefined ? settings.showGpuTemp : true
                selectedGpuIndex = settings.selectedGpuIndex !== undefined ? settings.selectedGpuIndex : 0
                enabledGpuPciIds = settings.enabledGpuPciIds !== undefined ? settings.enabledGpuPciIds : []
                showSystemTray = settings.showSystemTray !== undefined ? settings.showSystemTray : true
                showClock = settings.showClock !== undefined ? settings.showClock : true
                showNotificationButton = settings.showNotificationButton !== undefined ? settings.showNotificationButton : true
                showBattery = settings.showBattery !== undefined ? settings.showBattery : true
                showControlCenterButton = settings.showControlCenterButton !== undefined ? settings.showControlCenterButton : true
                controlCenterShowNetworkIcon = settings.controlCenterShowNetworkIcon !== undefined ? settings.controlCenterShowNetworkIcon : true
                controlCenterShowBluetoothIcon = settings.controlCenterShowBluetoothIcon !== undefined ? settings.controlCenterShowBluetoothIcon : true
                controlCenterShowAudioIcon = settings.controlCenterShowAudioIcon !== undefined ? settings.controlCenterShowAudioIcon : true
                controlCenterWidgets = settings.controlCenterWidgets !== undefined ? settings.controlCenterWidgets : [
                    {"id": "volumeSlider", "enabled": true, "width": 50},
                    {"id": "brightnessSlider", "enabled": true, "width": 50},
                    {"id": "wifi", "enabled": true, "width": 50},
                    {"id": "bluetooth", "enabled": true, "width": 50},
                    {"id": "audioOutput", "enabled": true, "width": 50},
                    {"id": "audioInput", "enabled": true, "width": 50},
                    {"id": "nightMode", "enabled": true, "width": 50},
                    {"id": "darkMode", "enabled": true, "width": 50}
                ]
                showWorkspaceIndex = settings.showWorkspaceIndex !== undefined ? settings.showWorkspaceIndex : false
                showWorkspacePadding = settings.showWorkspacePadding !== undefined ? settings.showWorkspacePadding : false
                workspaceScrolling = settings.workspaceScrolling !== undefined ? settings.workspaceScrolling : false
                showWorkspaceApps = settings.showWorkspaceApps !== undefined ? settings.showWorkspaceApps : false
                maxWorkspaceIcons = settings.maxWorkspaceIcons !== undefined ? settings.maxWorkspaceIcons : 3
                workspaceNameIcons = settings.workspaceNameIcons !== undefined ? settings.workspaceNameIcons : ({})
                workspacesPerMonitor = settings.workspacesPerMonitor !== undefined ? settings.workspacesPerMonitor : true
                waveProgressEnabled = settings.waveProgressEnabled !== undefined ? settings.waveProgressEnabled : true
                clockCompactMode = settings.clockCompactMode !== undefined ? settings.clockCompactMode : false
                focusedWindowCompactMode = settings.focusedWindowCompactMode !== undefined ? settings.focusedWindowCompactMode : false
                runningAppsCompactMode = settings.runningAppsCompactMode !== undefined ? settings.runningAppsCompactMode : true
                runningAppsCurrentWorkspace = settings.runningAppsCurrentWorkspace !== undefined ? settings.runningAppsCurrentWorkspace : false
                runningAppsGroupByApp = settings.runningAppsGroupByApp !== undefined ? settings.runningAppsGroupByApp : false
                clockDateFormat = settings.clockDateFormat !== undefined ? settings.clockDateFormat : ""
                lockDateFormat = settings.lockDateFormat !== undefined ? settings.lockDateFormat : ""
                mediaSize = settings.mediaSize !== undefined ? settings.mediaSize : (settings.mediaCompactMode !== undefined ? (settings.mediaCompactMode ? 0 : 1) : 1)
                if (settings.shellitBarWidgetOrder || settings.topBarWidgetOrder) {
                    var widgetOrder = settings.shellitBarWidgetOrder || settings.topBarWidgetOrder
                    shellitBarLeftWidgets = widgetOrder.filter(w => {
                                                                              return ["launcherButton", "workspaceSwitcher", "focusedWindow"].includes(w)
                                                                          })
                    shellitBarCenterWidgets = widgetOrder.filter(w => {
                                                                                return ["clock", "music", "weather"].includes(w)
                                                                            })
                    shellitBarRightWidgets = widgetOrder.filter(w => {
                                                                               return ["systemTray", "clipboard", "systemResources", "notificationButton", "battery", "controlCenterButton"].includes(w)
                                                                           })
                } else {
                    var leftWidgets = settings.shellitBarLeftWidgets !== undefined ? settings.shellitBarLeftWidgets : (settings.topBarLeftWidgets !== undefined ? settings.topBarLeftWidgets : ["launcherButton", "workspaceSwitcher", "focusedWindow"])
                    var centerWidgets = settings.shellitBarCenterWidgets !== undefined ? settings.shellitBarCenterWidgets : (settings.topBarCenterWidgets !== undefined ? settings.topBarCenterWidgets : ["music", "clock", "weather"])
                    var rightWidgets = settings.shellitBarRightWidgets !== undefined ? settings.shellitBarRightWidgets : (settings.topBarRightWidgets !== undefined ? settings.topBarRightWidgets : ["systemTray", "clipboard", "cpuUsage", "memUsage", "notificationButton", "battery", "controlCenterButton"])
                    shellitBarLeftWidgets = leftWidgets
                    shellitBarCenterWidgets = centerWidgets
                    shellitBarRightWidgets = rightWidgets
                    updateListModel(leftWidgetsModel, leftWidgets)
                    updateListModel(centerWidgetsModel, centerWidgets)
                    updateListModel(rightWidgetsModel, rightWidgets)
                }
                appLauncherViewMode = settings.appLauncherViewMode !== undefined ? settings.appLauncherViewMode : "list"
                spotlightModalViewMode = settings.spotlightModalViewMode !== undefined ? settings.spotlightModalViewMode : "list"
                sortAppsAlphabetically = settings.sortAppsAlphabetically !== undefined ? settings.sortAppsAlphabetically : false
                networkPreference = settings.networkPreference !== undefined ? settings.networkPreference : "auto"
                iconTheme = settings.iconTheme !== undefined ? settings.iconTheme : "System Default"
                if (settings.useOSLogo !== undefined) {
                    launcherLogoMode = settings.useOSLogo ? "os" : "apps"
                    launcherLogoColorOverride = settings.osLogoColorOverride !== undefined ? settings.osLogoColorOverride : ""
                    launcherLogoBrightness = settings.osLogoBrightness !== undefined ? settings.osLogoBrightness : 0.5
                    launcherLogoContrast = settings.osLogoContrast !== undefined ? settings.osLogoContrast : 1
                } else {
                    launcherLogoMode = settings.launcherLogoMode !== undefined ? settings.launcherLogoMode : "apps"
                    launcherLogoCustomPath = settings.launcherLogoCustomPath !== undefined ? settings.launcherLogoCustomPath : ""
                    launcherLogoColorOverride = settings.launcherLogoColorOverride !== undefined ? settings.launcherLogoColorOverride : ""
                    launcherLogoColorInvertOnMode = settings.launcherLogoColorInvertOnMode !== undefined ? settings.launcherLogoColorInvertOnMode : false
                    launcherLogoBrightness = settings.launcherLogoBrightness !== undefined ? settings.launcherLogoBrightness : 0.5
                    launcherLogoContrast = settings.launcherLogoContrast !== undefined ? settings.launcherLogoContrast : 1
                    launcherLogoSizeOffset = settings.launcherLogoSizeOffset !== undefined ? settings.launcherLogoSizeOffset : 0
                }
                fontFamily = settings.fontFamily !== undefined ? settings.fontFamily : defaultFontFamily
                monoFontFamily = settings.monoFontFamily !== undefined ? settings.monoFontFamily : defaultMonoFontFamily
                fontWeight = settings.fontWeight !== undefined ? settings.fontWeight : Font.Normal
                fontScale = settings.fontScale !== undefined ? settings.fontScale : 1.0
                shellitBarFontScale = settings.shellitBarFontScale !== undefined ? settings.shellitBarFontScale : 1.0
                notepadUseMonospace = settings.notepadUseMonospace !== undefined ? settings.notepadUseMonospace : true
                notepadFontFamily = settings.notepadFontFamily !== undefined ? settings.notepadFontFamily : ""
                notepadFontSize = settings.notepadFontSize !== undefined ? settings.notepadFontSize : 14
                notepadShowLineNumbers = settings.notepadShowLineNumbers !== undefined ? settings.notepadShowLineNumbers : false
                notepadTransparencyOverride = settings.notepadTransparencyOverride !== undefined ? settings.notepadTransparencyOverride : -1
                notepadLastCustomTransparency = settings.notepadLastCustomTransparency !== undefined ? settings.notepadLastCustomTransparency : 0.95
                soundsEnabled = settings.soundsEnabled !== undefined ? settings.soundsEnabled : true
                useSystemSoundTheme = settings.useSystemSoundTheme !== undefined ? settings.useSystemSoundTheme : false
                soundNewNotification = settings.soundNewNotification !== undefined ? settings.soundNewNotification : true
                soundVolumeChanged = settings.soundVolumeChanged !== undefined ? settings.soundVolumeChanged : true
                soundPluggedIn = settings.soundPluggedIn !== undefined ? settings.soundPluggedIn : true
                gtkThemingEnabled = settings.gtkThemingEnabled !== undefined ? settings.gtkThemingEnabled : false
                qtThemingEnabled = settings.qtThemingEnabled !== undefined ? settings.qtThemingEnabled : false
                syncModeWithPortal = settings.syncModeWithPortal !== undefined ? settings.syncModeWithPortal : true
                showDock = settings.showDock !== undefined ? settings.showDock : false
                dockAutoHide = settings.dockAutoHide !== undefined ? settings.dockAutoHide : false
                dockGroupByApp = settings.dockGroupByApp !== undefined ? settings.dockGroupByApp : false
                dockPosition = settings.dockPosition !== undefined ? settings.dockPosition : SettingsData.Position.Bottom
                dockSpacing = settings.dockSpacing !== undefined ? settings.dockSpacing : 4
                dockBottomGap = settings.dockBottomGap !== undefined ? settings.dockBottomGap : 0
                dockIconSize = settings.dockIconSize !== undefined ? settings.dockIconSize : 40
                dockIndicatorStyle = settings.dockIndicatorStyle !== undefined ? settings.dockIndicatorStyle : "circle"
                cornerRadius = settings.cornerRadius !== undefined ? settings.cornerRadius : 12
                notificationOverlayEnabled = settings.notificationOverlayEnabled !== undefined ? settings.notificationOverlayEnabled : false
                shellitBarAutoHide = settings.shellitBarAutoHide !== undefined ? settings.shellitBarAutoHide : (settings.topBarAutoHide !== undefined ? settings.topBarAutoHide : false)
                shellitBarOpenOnOverview = settings.shellitBarOpenOnOverview !== undefined ? settings.shellitBarOpenOnOverview : (settings.topBarOpenOnOverview !== undefined ? settings.topBarOpenOnOverview : false)
                shellitBarVisible = settings.shellitBarVisible !== undefined ? settings.shellitBarVisible : (settings.topBarVisible !== undefined ? settings.topBarVisible : true)
                dockOpenOnOverview = settings.dockOpenOnOverview !== undefined ? settings.dockOpenOnOverview : false
                notificationTimeoutLow = settings.notificationTimeoutLow !== undefined ? settings.notificationTimeoutLow : 5000
                notificationTimeoutNormal = settings.notificationTimeoutNormal !== undefined ? settings.notificationTimeoutNormal : 5000
                notificationTimeoutCritical = settings.notificationTimeoutCritical !== undefined ? settings.notificationTimeoutCritical : 0
                notificationPopupPosition = settings.notificationPopupPosition !== undefined ? settings.notificationPopupPosition : SettingsData.Position.Top
                osdAlwaysShowValue = settings.osdAlwaysShowValue !== undefined ? settings.osdAlwaysShowValue : false
                powerActionConfirm = settings.powerActionConfirm !== undefined ? settings.powerActionConfirm : true
                customPowerActionLock = settings.customPowerActionLock != undefined ? settings.customPowerActionLock : ""
                customPowerActionLogout = settings.customPowerActionLogout != undefined ? settings.customPowerActionLogout : ""
                customPowerActionSuspend = settings.customPowerActionSuspend != undefined ? settings.customPowerActionSuspend : ""
                customPowerActionHibernate = settings.customPowerActionHibernate != undefined ? settings.customPowerActionHibernate : ""
                customPowerActionReboot = settings.customPowerActionReboot != undefined ? settings.customPowerActionReboot : ""
                customPowerActionPowerOff = settings.customPowerActionPowerOff != undefined ? settings.customPowerActionPowerOff : ""
                updaterUseCustomCommand = settings.updaterUseCustomCommand !== undefined ? settings.updaterUseCustomCommand : false;
                updaterCustomCommand = settings.updaterCustomCommand !== undefined ? settings.updaterCustomCommand : "";
                updaterTerminalAdditionalParams = settings.updaterTerminalAdditionalParams !== undefined ? settings.updaterTerminalAdditionalParams : "";
                shellitBarSpacing = settings.shellitBarSpacing !== undefined ? settings.shellitBarSpacing : (settings.topBarSpacing !== undefined ? settings.topBarSpacing : 4)
                shellitBarBottomGap = settings.shellitBarBottomGap !== undefined ? settings.shellitBarBottomGap : (settings.topBarBottomGap !== undefined ? settings.topBarBottomGap : 0)
                shellitBarInnerPadding = settings.shellitBarInnerPadding !== undefined ? settings.shellitBarInnerPadding : (settings.topBarInnerPadding !== undefined ? settings.topBarInnerPadding : 4)
                shellitBarSquareCorners = settings.shellitBarSquareCorners !== undefined ? settings.shellitBarSquareCorners : (settings.topBarSquareCorners !== undefined ? settings.topBarSquareCorners : false)
                shellitBarNoBackground = settings.shellitBarNoBackground !== undefined ? settings.shellitBarNoBackground : (settings.topBarNoBackground !== undefined ? settings.topBarNoBackground : false)
                shellitBarGothCornersEnabled = settings.shellitBarGothCornersEnabled !== undefined ? settings.shellitBarGothCornersEnabled : (settings.topBarGothCornersEnabled !== undefined ? settings.topBarGothCornersEnabled : false)
                shellitBarBorderEnabled = settings.shellitBarBorderEnabled !== undefined ? settings.shellitBarBorderEnabled : false
                shellitBarBorderColor = settings.shellitBarBorderColor !== undefined ? settings.shellitBarBorderColor : "surfaceText"
                shellitBarBorderOpacity = settings.shellitBarBorderOpacity !== undefined ? settings.shellitBarBorderOpacity : 1.0
                shellitBarBorderThickness = settings.shellitBarBorderThickness !== undefined ? settings.shellitBarBorderThickness : 1
                popupGapsAuto = settings.popupGapsAuto !== undefined ? settings.popupGapsAuto : true
                popupGapsManual = settings.popupGapsManual !== undefined ? settings.popupGapsManual : 4
                shellitBarPosition = settings.shellitBarPosition !== undefined ? settings.shellitBarPosition : (settings.shellitBarAtBottom !== undefined ? (settings.shellitBarAtBottom ? SettingsData.Position.Bottom : SettingsData.Position.Top) : (settings.topBarAtBottom !== undefined ? (settings.topBarAtBottom ? SettingsData.Position.Bottom : SettingsData.Position.Top) : SettingsData.Position.Top))
                lockScreenShowPowerActions = settings.lockScreenShowPowerActions !== undefined ? settings.lockScreenShowPowerActions : true
                enableFprint = settings.enableFprint !== undefined ? settings.enableFprint : false
                maxFprintTries = settings.maxFprintTries !== undefined ? settings.maxFprintTries : 3
                hideBrightnessSlider = settings.hideBrightnessSlider !== undefined ? settings.hideBrightnessSlider : false
                widgetBackgroundColor = settings.widgetBackgroundColor !== undefined ? settings.widgetBackgroundColor : "sch"
                surfaceBase = settings.surfaceBase !== undefined ? settings.surfaceBase : "s"
                screenPreferences = settings.screenPreferences !== undefined ? settings.screenPreferences : ({})
                showOnLastDisplay = settings.showOnLastDisplay !== undefined ? settings.showOnLastDisplay : ({})
                wallpaperFillMode = settings.wallpaperFillMode !== undefined ? settings.wallpaperFillMode : "Fill"
                blurredWallpaperLayer = settings.blurredWallpaperLayer !== undefined ? settings.blurredWallpaperLayer : false
                blurWallpaperOnOverview = settings.blurWallpaperOnOverview !== undefined ? settings.blurWallpaperOnOverview : false
                animationSpeed = settings.animationSpeed !== undefined ? settings.animationSpeed : SettingsData.AnimationSpeed.Short
                customAnimationDuration = settings.customAnimationDuration !== undefined ? settings.customAnimationDuration : 500
                acMonitorTimeout = settings.acMonitorTimeout !== undefined ? settings.acMonitorTimeout : 0
                acLockTimeout = settings.acLockTimeout !== undefined ? settings.acLockTimeout : 0
                acSuspendTimeout = settings.acSuspendTimeout !== undefined ? settings.acSuspendTimeout : 0
                acHibernateTimeout = settings.acHibernateTimeout !== undefined ? settings.acHibernateTimeout : 0
                batteryMonitorTimeout = settings.batteryMonitorTimeout !== undefined ? settings.batteryMonitorTimeout : 0
                batteryLockTimeout = settings.batteryLockTimeout !== undefined ? settings.batteryLockTimeout : 0
                batterySuspendTimeout = settings.batterySuspendTimeout !== undefined ? settings.batterySuspendTimeout : 0
                batteryHibernateTimeout = settings.batteryHibernateTimeout !== undefined ? settings.batteryHibernateTimeout : 0
                lockBeforeSuspend = settings.lockBeforeSuspend !== undefined ? settings.lockBeforeSuspend : false
                loginctlLockIntegration = settings.loginctlLockIntegration !== undefined ? settings.loginctlLockIntegration : true
                launchPrefix = settings.launchPrefix !== undefined ? settings.launchPrefix : ""
                brightnessDevicePins = settings.brightnessDevicePins !== undefined ? settings.brightnessDevicePins : ({})

                if (settings.configVersion === undefined) {
                    migrateFromUndefinedToV1(settings)
                    cleanupUnusedKeys()
                    saveSettings()
                }

                applyStoredTheme()
                detectAvailableIconThemes()
                detectQtTools()
                updateGtkIconTheme(iconTheme)
                applyStoredIconTheme()
            } else {
                applyStoredTheme()
            }
        } catch (e) {
            applyStoredTheme()
        } finally {
            _loading = false
        }

        if (shouldMigrate) {
            savePluginSettings()
            saveSettings()
        }
    }

    function saveSettings() {
        if (_loading)
            return
        settingsFile.setText(JSON.stringify({
                                                "currentThemeName": currentThemeName,
                                                "customThemeFile": customThemeFile,
                                                "matugenScheme": matugenScheme,
                                                "runUserMatugenTemplates": runUserMatugenTemplates,
                                                "ShellitBarTransparency": ShellitBarTransparency,
                                                "ShellitBarWidgetTransparency": ShellitBarWidgetTransparency,
                                                "popupTransparency": popupTransparency,
                                                "dockTransparency": dockTransparency,
                                                "use24HourClock": use24HourClock,
                                                "showSeconds": showSeconds,
                                                "useFahrenheit": useFahrenheit,
                                                "nightModeEnabled": nightModeEnabled,
                                                "weatherLocation": weatherLocation,
                                                "weatherCoordinates": weatherCoordinates,
                                                "useAutoLocation": useAutoLocation,
                                                "weatherEnabled": weatherEnabled,
                                                "showLauncherButton": showLauncherButton,
                                                "showWorkspaceSwitcher": showWorkspaceSwitcher,
                                                "showFocusedWindow": showFocusedWindow,
                                                "showWeather": showWeather,
                                                "showMusic": showMusic,
                                                "showClipboard": showClipboard,
                                                "showCpuUsage": showCpuUsage,
                                                "showMemUsage": showMemUsage,
                                                "showCpuTemp": showCpuTemp,
                                                "showGpuTemp": showGpuTemp,
                                                "selectedGpuIndex": selectedGpuIndex,
                                                "enabledGpuPciIds": enabledGpuPciIds,
                                                "showSystemTray": showSystemTray,
                                                "showClock": showClock,
                                                "showNotificationButton": showNotificationButton,
                                                "showBattery": showBattery,
                                                "showControlCenterButton": showControlCenterButton,
                                                "controlCenterShowNetworkIcon": controlCenterShowNetworkIcon,
                                                "controlCenterShowBluetoothIcon": controlCenterShowBluetoothIcon,
                                                "controlCenterShowAudioIcon": controlCenterShowAudioIcon,
                                                "controlCenterWidgets": controlCenterWidgets,
                                                "showWorkspaceIndex": showWorkspaceIndex,
                                                "workspaceScrolling": workspaceScrolling,
                                                "showWorkspacePadding": showWorkspacePadding,
                                                "showWorkspaceApps": showWorkspaceApps,
                                                "maxWorkspaceIcons": maxWorkspaceIcons,
                                                "workspacesPerMonitor": workspacesPerMonitor,
                                                "workspaceNameIcons": workspaceNameIcons,
                                                "waveProgressEnabled": waveProgressEnabled,
                                                "clockCompactMode": clockCompactMode,
                                                "focusedWindowCompactMode": focusedWindowCompactMode,
                                                "runningAppsCompactMode": runningAppsCompactMode,
                                                "runningAppsCurrentWorkspace": runningAppsCurrentWorkspace,
                                                "runningAppsGroupByApp": runningAppsGroupByApp,
                                                "clockDateFormat": clockDateFormat,
                                                "lockDateFormat": lockDateFormat,
                                                "mediaSize": mediaSize,
                                                "ShellitBarLeftWidgets": ShellitBarLeftWidgets,
                                                "ShellitBarCenterWidgets": ShellitBarCenterWidgets,
                                                "ShellitBarRightWidgets": ShellitBarRightWidgets,
                                                "appLauncherViewMode": appLauncherViewMode,
                                                "spotlightModalViewMode": spotlightModalViewMode,
                                                "sortAppsAlphabetically": sortAppsAlphabetically,
                                                "networkPreference": networkPreference,
                                                "iconTheme": iconTheme,
                                                "launcherLogoMode": launcherLogoMode,
                                                "launcherLogoCustomPath": launcherLogoCustomPath,
                                                "launcherLogoColorOverride": launcherLogoColorOverride,
                                                "launcherLogoColorInvertOnMode": launcherLogoColorInvertOnMode,
                                                "launcherLogoBrightness": launcherLogoBrightness,
                                                "launcherLogoContrast": launcherLogoContrast,
                                                "launcherLogoSizeOffset": launcherLogoSizeOffset,
                                                "fontFamily": fontFamily,
                                                "monoFontFamily": monoFontFamily,
                                                "fontWeight": fontWeight,
                                                "fontScale": fontScale,
                                                "shellitBarFontScale": shellitBarFontScale,
                                                "notepadUseMonospace": notepadUseMonospace,
                                                "notepadFontFamily": notepadFontFamily,
                                                "notepadFontSize": notepadFontSize,
                                                "notepadShowLineNumbers": notepadShowLineNumbers,
                                                "notepadTransparencyOverride": notepadTransparencyOverride,
                                                "notepadLastCustomTransparency": notepadLastCustomTransparency,
                                                "soundsEnabled": soundsEnabled,
                                                "useSystemSoundTheme": useSystemSoundTheme,
                                                "soundNewNotification": soundNewNotification,
                                                "soundVolumeChanged": soundVolumeChanged,
                                                "soundPluggedIn": soundPluggedIn,
                                                "gtkThemingEnabled": gtkThemingEnabled,
                                                "qtThemingEnabled": qtThemingEnabled,
                                                "syncModeWithPortal": syncModeWithPortal,
                                                "showDock": showDock,
                                                "dockAutoHide": dockAutoHide,
                                                "dockGroupByApp": dockGroupByApp,
                                                "dockOpenOnOverview": dockOpenOnOverview,
                                                "dockPosition": dockPosition,
                                                "dockSpacing": dockSpacing,
                                                "dockBottomGap": dockBottomGap,
                                                "dockIconSize": dockIconSize,
                                                "dockIndicatorStyle": dockIndicatorStyle,
                                                "cornerRadius": cornerRadius,
                                                "notificationOverlayEnabled": notificationOverlayEnabled,
                                                "shellitBarAutoHide": shellitBarAutoHide,
                                                "shellitBarOpenOnOverview": shellitBarOpenOnOverview,
                                                "shellitBarVisible": shellitBarVisible,
                                                "shellitBarSpacing": shellitBarSpacing,
                                                "shellitBarBottomGap": shellitBarBottomGap,
                                                "shellitBarInnerPadding": shellitBarInnerPadding,
                                                "shellitBarSquareCorners": shellitBarSquareCorners,
                                                "shellitBarNoBackground": shellitBarNoBackground,
                                                "shellitBarGothCornersEnabled": shellitBarGothCornersEnabled,
                                                "shellitBarBorderEnabled": shellitBarBorderEnabled,
                                                "shellitBarBorderColor": shellitBarBorderColor,
                                                "shellitBarBorderOpacity": shellitBarBorderOpacity,
                                                "shellitBarBorderThickness": shellitBarBorderThickness,
                                                "popupGapsAuto": popupGapsAuto,
                                                "popupGapsManual": popupGapsManual,
                                                "shellitBarPosition": shellitBarPosition,
                                                "lockScreenShowPowerActions": lockScreenShowPowerActions,
                                                "enableFprint": enableFprint,
                                                "maxFprintTries": maxFprintTries,
                                                "hideBrightnessSlider": hideBrightnessSlider,
                                                "widgetBackgroundColor": widgetBackgroundColor,
                                                "surfaceBase": surfaceBase,
                                                "wallpaperFillMode": wallpaperFillMode,
                                                "blurredWallpaperLayer": blurredWallpaperLayer,
                                                "blurWallpaperOnOverview": blurWallpaperOnOverview,
                                                "notificationTimeoutLow": notificationTimeoutLow,
                                                "notificationTimeoutNormal": notificationTimeoutNormal,
                                                "notificationTimeoutCritical": notificationTimeoutCritical,
                                                "notificationPopupPosition": notificationPopupPosition,
                                                "osdAlwaysShowValue": osdAlwaysShowValue,
                                                "powerActionConfirm": powerActionConfirm,
                                                "customPowerActionLock": customPowerActionLock,
                                                "customPowerActionLogout": customPowerActionLogout,
                                                "customPowerActionSuspend": customPowerActionSuspend,
                                                "customPowerActionHibernate": customPowerActionHibernate,
                                                "customPowerActionReboot": customPowerActionReboot,
                                                "customPowerActionPowerOff": customPowerActionPowerOff,
                                                "updaterUseCustomCommand": updaterUseCustomCommand,
                                                "updaterCustomCommand": updaterCustomCommand,
                                                "updaterTerminalAdditionalParams": updaterTerminalAdditionalParams,
                                                "screenPreferences": screenPreferences,
                                                "showOnLastDisplay": showOnLastDisplay,
                                                "animationSpeed": animationSpeed,
                                                "customAnimationDuration": customAnimationDuration,
                                                "acMonitorTimeout": acMonitorTimeout,
                                                "acLockTimeout": acLockTimeout,
                                                "acSuspendTimeout": acSuspendTimeout,
                                                "acHibernateTimeout": acHibernateTimeout,
                                                "batteryMonitorTimeout": batteryMonitorTimeout,
                                                "batteryLockTimeout": batteryLockTimeout,
                                                "batterySuspendTimeout": batterySuspendTimeout,
                                                "batteryHibernateTimeout": batteryHibernateTimeout,
                                                "lockBeforeSuspend": lockBeforeSuspend,
                                                "loginctlLockIntegration": loginctlLockIntegration,
                                                "launchPrefix": launchPrefix,
                                                "brightnessDevicePins": brightnessDevicePins,
                                                "configVersion": settingsConfigVersion
                                            }, null, 2))
    }

    function savePluginSettings() {
        if (_pluginSettingsLoading)
            return
        pluginSettingsFile.setText(JSON.stringify(pluginSettings, null, 2))
    }

    function migrateFromUndefinedToV1(settings) {
        console.info("SettingsData: Migrating configuration from undefined to version 1")
    }

    function cleanupUnusedKeys() {
        const validKeys = [
            "currentThemeName", "customThemeFile", "matugenScheme", "runUserMatugenTemplates",
            "shellitBarTransparency", "shellitBarWidgetTransparency", "popupTransparency", "dockTransparency",
            "use24HourClock", "showSeconds", "useFahrenheit", "nightModeEnabled", "weatherLocation",
            "weatherCoordinates", "useAutoLocation", "weatherEnabled", "showLauncherButton",
            "showWorkspaceSwitcher", "showFocusedWindow", "showWeather", "showMusic",
            "showClipboard", "showCpuUsage", "showMemUsage", "showCpuTemp", "showGpuTemp",
            "selectedGpuIndex", "enabledGpuPciIds", "showSystemTray", "showClock",
            "showNotificationButton", "showBattery", "showControlCenterButton",
            "controlCenterShowNetworkIcon", "controlCenterShowBluetoothIcon", "controlCenterShowAudioIcon",
            "controlCenterWidgets", "showWorkspaceIndex", "workspaceScrolling", "showWorkspacePadding", "showWorkspaceApps",
            "maxWorkspaceIcons", "workspacesPerMonitor", "workspaceNameIcons", "waveProgressEnabled",
            "clockCompactMode", "focusedWindowCompactMode", "runningAppsCompactMode",
            "runningAppsCurrentWorkspace", "runningAppsGroupByApp", "clockDateFormat", "lockDateFormat", "mediaSize",
            "shellitBarLeftWidgets", "shellitBarCenterWidgets", "shellitBarRightWidgets",
            "appLauncherViewMode", "spotlightModalViewMode", "sortAppsAlphabetically",
            "networkPreference", "iconTheme", "launcherLogoMode", "launcherLogoCustomPath",
            "launcherLogoColorOverride", "launcherLogoColorInvertOnMode", "launcherLogoBrightness",
            "launcherLogoContrast", "launcherLogoSizeOffset", "fontFamily", "monoFontFamily",
            "fontWeight", "fontScale", "shellitBarFontScale", "notepadUseMonospace",
            "notepadFontFamily", "notepadFontSize", "notepadShowLineNumbers",
            "notepadTransparencyOverride", "notepadLastCustomTransparency", "soundsEnabled",
            "useSystemSoundTheme", "soundNewNotification", "soundVolumeChanged", "soundPluggedIn", "gtkThemingEnabled",
            "qtThemingEnabled", "syncModeWithPortal", "showDock", "dockAutoHide", "dockGroupByApp",
            "dockOpenOnOverview", "dockPosition", "dockSpacing", "dockBottomGap", "dockIconSize", "dockIndicatorStyle",
            "cornerRadius", "notificationOverlayEnabled", "shellitBarAutoHide",
            "shellitBarOpenOnOverview", "shellitBarVisible", "shellitBarSpacing", "shellitBarBottomGap",
            "shellitBarInnerPadding", "shellitBarSquareCorners", "shellitBarNoBackground",
            "shellitBarGothCornersEnabled", "shellitBarBorderEnabled", "shellitBarBorderColor",
            "shellitBarBorderOpacity", "shellitBarBorderThickness", "popupGapsAuto", "popupGapsManual",
            "shellitBarPosition", "lockScreenShowPowerActions", "enableFprint", "maxFprintTries",
            "hideBrightnessSlider", "widgetBackgroundColor", "surfaceBase", "wallpaperFillMode",
            "blurredWallpaperLayer", "blurWallpaperOnOverview", "notificationTimeoutLow", "notificationTimeoutNormal", "notificationTimeoutCritical",
            "notificationPopupPosition", "osdAlwaysShowValue", "powerActionConfirm",
            "customPowerActionLock", "customPowerActionLogout", "customPowerActionSuspend",
            "customPowerActionHibernate", "customPowerActionReboot", "customPowerActionPowerOff",
            "updaterUseCustomCommand", "updaterCustomCommand", "updaterTerminalAdditionalParams",
            "screenPreferences", "showOnLastDisplay", "animationSpeed", "customAnimationDuration", "acMonitorTimeout", "acLockTimeout",
            "acSuspendTimeout", "acHibernateTimeout", "batteryMonitorTimeout", "batteryLockTimeout",
            "batterySuspendTimeout", "batteryHibernateTimeout", "lockBeforeSuspend",
            "loginctlLockIntegration", "launchPrefix", "brightnessDevicePins", "configVersion"
        ]

        try {
            const content = settingsFile.text()
            if (!content || !content.trim()) return

            const settings = JSON.parse(content)
            let needsSave = false

            for (const key in settings) {
                if (!validKeys.includes(key)) {
                    console.log("SettingsData: Removing unused key:", key)
                    delete settings[key]
                    needsSave = true
                }
            }

            if (needsSave) {
                settingsFile.setText(JSON.stringify(settings, null, 2))
            }
        } catch (e) {
            console.warn("SettingsData: Failed to cleanup unused keys:", e.message)
        }
    }

    function getEffectiveTimeFormat() {
        if (use24HourClock) {
            return showSeconds ? "hh:mm:ss" : "hh:mm"
        } else {
            return showSeconds ? "h:mm:ss AP": "h:mm AP"
        }
    }

    function getEffectiveClockDateFormat() {
        return clockDateFormat && clockDateFormat.length > 0 ? clockDateFormat : "ddd d"
    }

    function getEffectiveLockDateFormat() {
        return lockDateFormat && lockDateFormat.length > 0 ? lockDateFormat : Locale.LongFormat
    }

    function initializeListModels() {
        var dummyItem = {
            "widgetId": "dummy",
            "enabled": true,
            "size": 20,
            "selectedGpuIndex": 0,
            "pciId": "",
            "mountPath": "/",
            "minimumWidth": true
        }
        leftWidgetsModel.append(dummyItem)
        centerWidgetsModel.append(dummyItem)
        rightWidgetsModel.append(dummyItem)

        updateListModel(leftWidgetsModel, shellitBarLeftWidgets)
        updateListModel(centerWidgetsModel, shellitBarCenterWidgets)
        updateListModel(rightWidgetsModel, shellitBarRightWidgets)
    }

    function updateListModel(listModel, order) {
        listModel.clear()
        for (var i = 0; i < order.length; i++) {
            var widgetId = typeof order[i] === "string" ? order[i] : order[i].id
            var enabled = typeof order[i] === "string" ? true : order[i].enabled
            var size = typeof order[i] === "string" ? undefined : order[i].size
            var selectedGpuIndex = typeof order[i] === "string" ? undefined : order[i].selectedGpuIndex
            var pciId = typeof order[i] === "string" ? undefined : order[i].pciId
            var mountPath = typeof order[i] === "string" ? undefined : order[i].mountPath
            var minimumWidth = typeof order[i] === "string" ? undefined : order[i].minimumWidth
            var item = {
                "widgetId": widgetId,
                "enabled": enabled
            }
            if (size !== undefined)
                item.size = size
            if (selectedGpuIndex !== undefined)
                item.selectedGpuIndex = selectedGpuIndex
            if (pciId !== undefined)
                item.pciId = pciId
            if (mountPath !== undefined)
                item.mountPath = mountPath
            if (minimumWidth !== undefined)
                item.minimumWidth = minimumWidth

            listModel.append(item)
        }
        widgetDataChanged()
    }

    function hasNamedWorkspaces() {
        if (typeof NiriService === "undefined" || !CompositorService.isNiri)
            return false

        for (var i = 0; i < NiriService.allWorkspaces.length; i++) {
            var ws = NiriService.allWorkspaces[i]
            if (ws.name && ws.name.trim() !== "")
                return true
        }
        return false
    }

    function getNamedWorkspaces() {
        var namedWorkspaces = []
        if (typeof NiriService === "undefined" || !CompositorService.isNiri)
            return namedWorkspaces

        for (const ws of NiriService.allWorkspaces) {
            if (ws.name && ws.name.trim() !== "") {
                namedWorkspaces.push(ws.name)
            }
        }
        return namedWorkspaces
    }

    function applyStoredTheme() {
        if (typeof Theme !== "undefined")
            Theme.switchTheme(currentThemeName, false, false)
        else
            Qt.callLater(() => {
                             if (typeof Theme !== "undefined")
                             Theme.switchTheme(currentThemeName, false, false)
                         })
    }

    function detectAvailableIconThemes() {
        systemDefaultDetectionProcess.running = true
    }

    function detectQtTools() {
        qtToolsDetectionProcess.running = true
    }

    function updateGtkIconTheme(themeName) {
        var gtkThemeName = (themeName === "System Default") ? systemDefaultIconTheme : themeName
        if (gtkThemeName !== "System Default" && gtkThemeName !== "") {
            if (shellitService.apiVersion >= 3) {
                PortalService.setSystemIconTheme(gtkThemeName)
            }

            var configScript = "mkdir -p " + _configDir + "/gtk-3.0 " + _configDir + "/gtk-4.0\n" + "\n" + "for config_dir in " + _configDir + "/gtk-3.0 " + _configDir + "/gtk-4.0; do\n"
                    + "    settings_file=\"$config_dir/settings.ini\"\n" + "    if [ -f \"$settings_file\" ]; then\n" + "        if grep -q '^gtk-icon-theme-name=' \"$settings_file\"; then\n" + "            sed -i 's/^gtk-icon-theme-name=.*/gtk-icon-theme-name=" + gtkThemeName + "/' \"$settings_file\"\n" + "        else\n"
                    + "            if grep -q '\\[Settings\\]' \"$settings_file\"; then\n" + "                sed -i '/\\[Settings\\]/a gtk-icon-theme-name=" + gtkThemeName + "' \"$settings_file\"\n" + "            else\n" + "                echo -e '\\n[Settings]\\ngtk-icon-theme-name=" + gtkThemeName + "' >> \"$settings_file\"\n" + "            fi\n"
                    + "        fi\n" + "    else\n" + "        echo -e '[Settings]\\ngtk-icon-theme-name=" + gtkThemeName + "' > \"$settings_file\"\n" + "    fi\n" + "done\n" + "\n" + "rm -rf ~/.cache/icon-cache ~/.cache/thumbnails 2>/dev/null || true\n" + "pkill -HUP -f 'gtk' 2>/dev/null || true\n"
            Quickshell.execDetached(["sh", "-lc", configScript])
        }
    }

    function updateQtIconTheme(themeName) {
        var qtThemeName = (themeName === "System Default") ? "" : themeName
        var home = _shq(Paths.strip(root._homeUrl))
        if (!qtThemeName) {
            return
        }
        var script = "mkdir -p " + _configDir + "/qt5ct " + _configDir + "/qt6ct " + _configDir + "/environment.d 2>/dev/null || true\n" + "update_qt_icon_theme() {\n" + "  local config_file=\"$1\"\n"
                + "  local theme_name=\"$2\"\n" + "  if [ -f \"$config_file\" ]; then\n" + "    if grep -q '^\\[Appearance\\]' \"$config_file\"; then\n" + "      if grep -q '^icon_theme=' \"$config_file\"; then\n" + "        sed -i \"s/^icon_theme=.*/icon_theme=$theme_name/\" \"$config_file\"\n" + "      else\n" + "        sed -i \"/^\\[Appearance\\]/a icon_theme=$theme_name\" \"$config_file\"\n" + "      fi\n"
                + "    else\n" + "      printf '\\n[Appearance]\\nicon_theme=%s\\n' \"$theme_name\" >> \"$config_file\"\n" + "    fi\n" + "  else\n" + "    printf '[Appearance]\\nicon_theme=%s\\n' \"$theme_name\" > \"$config_file\"\n" + "  fi\n" + "}\n" + "update_qt_icon_theme " + _configDir + "/qt5ct/qt5ct.conf " + _shq(
                    qtThemeName) + "\n" + "update_qt_icon_theme " + _configDir + "/qt6ct/qt6ct.conf " + _shq(qtThemeName) + "\n" + "rm -rf " + home + "/.cache/icon-cache " + home + "/.cache/thumbnails 2>/dev/null || true\n"
        Quickshell.execDetached(["sh", "-lc", script])
    }

    function applyStoredIconTheme() {
        updateGtkIconTheme(iconTheme)
        updateQtIconTheme(iconTheme)
    }

    function getPopupYPosition(barHeight) {
        const gothOffset = shellitBarGothCornersEnabled ? Theme.cornerRadius : 0
        return barHeight + shellitBarSpacing + shellitBarBottomGap - gothOffset + Theme.popupDistance
    }

    function getPopupTriggerPosition(globalPos, screen, barThickness, widgetWidth) {
        const screenX = screen ? screen.x : 0
        const screenY = screen ? screen.y : 0
        const relativeX = globalPos.x - screenX
        const relativeY = globalPos.y - screenY

        if (shellitBarPosition === SettingsData.Position.Left || shellitBarPosition === SettingsData.Position.Right) {
            return {
                x: relativeY,
                y: barThickness + shellitBarSpacing + Theme.popupDistance,
                width: widgetWidth
            }
        }
        return {
            x: relativeX,
            y: barThickness + shellitBarSpacing + shellitBarBottomGap + Theme.popupDistance,
            width: widgetWidth
        }
    }

    function getFilteredScreens(componentId) {
        var prefs = screenPreferences && screenPreferences[componentId] || ["all"]
        if (prefs.includes("all")) {
            return Quickshell.screens
        }
        var filtered = Quickshell.screens.filter(screen => prefs.includes(screen.name))
        if (filtered.length === 0 && showOnLastDisplay && showOnLastDisplay[componentId] && Quickshell.screens.length === 1) {
            return Quickshell.screens
        }
        return filtered
    }

    function sendTestNotifications() {
        sendTestNotification(0)
        testNotifTimer1.start()
        testNotifTimer2.start()
    }

    function sendTestNotification(index) {
        const notifications = [
            ["Notification Position Test", "shellit test notification 1 of 3 ~ Hi there!", "preferences-system"],
            ["Second Test", "shellit Notification 2 of 3 ~ Check it out!", "applications-graphics"],
            ["Third Test", "shellit notification 3 of 3 ~ Enjoy!", "face-smile"]
        ]

        if (index < 0 || index >= notifications.length) {
            return
        }

        const notif = notifications[index]
        testNotificationProcess.command = ["notify-send", "-h", "int:transient:1", "-a", "shellit", "-i", notif[2], notif[0], notif[1]]
        testNotificationProcess.running = true
    }

    function _shq(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function setTheme(themeName) {
        currentThemeName = themeName
        saveSettings()
    }

    function setCustomThemeFile(filePath) {
        customThemeFile = filePath
        saveSettings()
    }

    function setMatugenScheme(scheme) {
        var normalized = scheme || "scheme-tonal-spot"
        if (matugenScheme === normalized)
            return

        matugenScheme = normalized
        saveSettings()

        if (typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setRunUserMatugenTemplates(enabled) {
        if (runUserMatugenTemplates === enabled)
            return

        runUserMatugenTemplates = enabled
        saveSettings()

        if (typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setShellitBarTransparency(transparency) {
        shellitBarTransparency = transparency
        saveSettings()
    }

    function setShellitBarWidgetTransparency(transparency) {
        shellitBarWidgetTransparency = transparency
        saveSettings()
    }

    function setPopupTransparency(transparency) {
        popupTransparency = transparency
        saveSettings()
    }

    function setDockTransparency(transparency) {
        dockTransparency = transparency
        saveSettings()
    }

    function setWidgetBackgroundColor(color) {
        widgetBackgroundColor = color
        saveSettings()
    }

    function setSurfaceBase(base) {
        surfaceBase = base
        saveSettings()
        if (typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setCornerRadius(radius) {
        cornerRadius = radius
        saveSettings()
        NiriService.generateNiriLayoutConfig()
    }

    function setClockFormat(use24Hour) {
        use24HourClock = use24Hour
        saveSettings()
    }

    function setTimeFormat(useSec) {
        showSeconds = useSec
        saveSettings()
    }

    function setTemperatureUnit(fahrenheit) {
        useFahrenheit = fahrenheit
        saveSettings()
    }

    function setNightModeEnabled(enabled) {
        nightModeEnabled = enabled
        saveSettings()
    }

    function setAnimationSpeed(speed) {
        animationSpeed = speed
        saveSettings()
    }

    function setCustomAnimationDuration(duration) {
        customAnimationDuration = duration
        saveSettings()
    }

    function setWallpaperFillMode(mode) {
        wallpaperFillMode = mode
        saveSettings()
    }

    function setBlurredWallpaperLayer(enabled) {
        blurredWallpaperLayer = enabled
        saveSettings()
    }

    function setBlurWallpaperOnOverview(enabled) {
        blurWallpaperOnOverview = enabled
        saveSettings()
    }

    function setShowLauncherButton(enabled) {
        showLauncherButton = enabled
        saveSettings()
    }

    function setShowWorkspaceSwitcher(enabled) {
        showWorkspaceSwitcher = enabled
        saveSettings()
    }

    function setShowFocusedWindow(enabled) {
        showFocusedWindow = enabled
        saveSettings()
    }

    function setShowWeather(enabled) {
        showWeather = enabled
        saveSettings()
    }

    function setShowMusic(enabled) {
        showMusic = enabled
        saveSettings()
    }

    function setShowClipboard(enabled) {
        showClipboard = enabled
        saveSettings()
    }

    function setShowCpuUsage(enabled) {
        showCpuUsage = enabled
        saveSettings()
    }

    function setShowMemUsage(enabled) {
        showMemUsage = enabled
        saveSettings()
    }

    function setShowCpuTemp(enabled) {
        showCpuTemp = enabled
        saveSettings()
    }

    function setShowGpuTemp(enabled) {
        showGpuTemp = enabled
        saveSettings()
    }

    function setSelectedGpuIndex(index) {
        selectedGpuIndex = index
        saveSettings()
    }

    function setEnabledGpuPciIds(pciIds) {
        enabledGpuPciIds = pciIds
        saveSettings()
    }

    function setShowSystemTray(enabled) {
        showSystemTray = enabled
        saveSettings()
    }

    function setShowClock(enabled) {
        showClock = enabled
        saveSettings()
    }

    function setShowNotificationButton(enabled) {
        showNotificationButton = enabled
        saveSettings()
    }

    function setShowBattery(enabled) {
        showBattery = enabled
        saveSettings()
    }

    function setShowControlCenterButton(enabled) {
        showControlCenterButton = enabled
        saveSettings()
    }

    function setControlCenterShowNetworkIcon(enabled) {
        controlCenterShowNetworkIcon = enabled
        saveSettings()
    }

    function setControlCenterShowBluetoothIcon(enabled) {
        controlCenterShowBluetoothIcon = enabled
        saveSettings()
    }

    function setControlCenterShowAudioIcon(enabled) {
        controlCenterShowAudioIcon = enabled
        saveSettings()
    }

    function setControlCenterWidgets(widgets) {
        controlCenterWidgets = widgets
        saveSettings()
    }

    function setShowWorkspaceIndex(enabled) {
        showWorkspaceIndex = enabled
        saveSettings()
    }

    function setWorkspaceScrolling(enabled) {
        workspaceScrolling = enabled
        saveSettings()
    }

    function setShowWorkspacePadding(enabled) {
        showWorkspacePadding = enabled
        saveSettings()
    }

    function setShowWorkspaceApps(enabled) {
        showWorkspaceApps = enabled
        saveSettings()
    }

    function setMaxWorkspaceIcons(maxIcons) {
        maxWorkspaceIcons = maxIcons
        saveSettings()
    }

    function setWorkspacesPerMonitor(enabled) {
        workspacesPerMonitor = enabled
        saveSettings()
    }

    function setWorkspaceNameIcon(workspaceName, iconData) {
        var iconMap = JSON.parse(JSON.stringify(workspaceNameIcons))
        iconMap[workspaceName] = iconData
        workspaceNameIcons = iconMap
        saveSettings()
        workspaceIconsUpdated()
    }

    function removeWorkspaceNameIcon(workspaceName) {
        var iconMap = JSON.parse(JSON.stringify(workspaceNameIcons))
        delete iconMap[workspaceName]
        workspaceNameIcons = iconMap
        saveSettings()
        workspaceIconsUpdated()
    }

    function getWorkspaceNameIcon(workspaceName) {
        return workspaceNameIcons[workspaceName] || null
    }

    function setWaveProgressEnabled(enabled) {
        waveProgressEnabled = enabled
        saveSettings()
    }

    function setClockCompactMode(enabled) {
        clockCompactMode = enabled
        saveSettings()
    }

    function setFocusedWindowCompactMode(enabled) {
        focusedWindowCompactMode = enabled
        saveSettings()
    }

    function setRunningAppsCompactMode(enabled) {
        runningAppsCompactMode = enabled
        saveSettings()
    }

    function setRunningAppsCurrentWorkspace(enabled) {
        runningAppsCurrentWorkspace = enabled
        saveSettings()
    }

    function setRunningAppsGroupByApp(enabled) {
        runningAppsGroupByApp = enabled
        saveSettings()
    }

    function setClockDateFormat(format) {
        clockDateFormat = format || ""
        saveSettings()
    }

    function setLockDateFormat(format) {
        lockDateFormat = format || ""
        saveSettings()
    }

    function setMediaSize(size) {
        mediaSize = size
        saveSettings()
    }

    function setShellitBarWidgetOrder(order) {
        shellitBarWidgetOrder = order
        saveSettings()
    }

    function setShellitBarLeftWidgets(order) {
        shellitBarLeftWidgets = order
        updateListModel(leftWidgetsModel, order)
        saveSettings()
    }

    function setShellitBarCenterWidgets(order) {
        shellitBarCenterWidgets = order
        updateListModel(centerWidgetsModel, order)
        saveSettings()
    }

    function setShellitBarRightWidgets(order) {
        shellitBarRightWidgets = order
        updateListModel(rightWidgetsModel, order)
        saveSettings()
    }

    function resetShellitBarWidgetsToDefault() {
        var defaultLeft = ["launcherButton", "workspaceSwitcher", "focusedWindow"]
        var defaultCenter = ["music", "clock", "weather"]
        var defaultRight = ["systemTray", "clipboard", "notificationButton", "battery", "controlCenterButton"]
        shellitBarLeftWidgets = defaultLeft
        shellitBarCenterWidgets = defaultCenter
        shellitBarRightWidgets = defaultRight
        updateListModel(leftWidgetsModel, defaultLeft)
        updateListModel(centerWidgetsModel, defaultCenter)
        updateListModel(rightWidgetsModel, defaultRight)
        showLauncherButton = true
        showWorkspaceSwitcher = true
        showFocusedWindow = true
        showWeather = true
        showMusic = true
        showClipboard = true
        showCpuUsage = true
        showMemUsage = true
        showCpuTemp = true
        showGpuTemp = true
        showSystemTray = true
        showClock = true
        showNotificationButton = true
        showBattery = true
        showControlCenterButton = true
        saveSettings()
    }

    function setAppLauncherViewMode(mode) {
        appLauncherViewMode = mode
        saveSettings()
    }

    function setSpotlightModalViewMode(mode) {
        spotlightModalViewMode = mode
        saveSettings()
    }

    function setSortAppsAlphabetically(enabled) {
        sortAppsAlphabetically = enabled
        saveSettings()
    }

    function setWeatherLocation(displayName, coordinates) {
        weatherLocation = displayName
        weatherCoordinates = coordinates
        saveSettings()
    }

    function setAutoLocation(enabled) {
        useAutoLocation = enabled
        saveSettings()
    }

    function setWeatherEnabled(enabled) {
        weatherEnabled = enabled
        saveSettings()
    }

    function setNetworkPreference(preference) {
        networkPreference = preference
        saveSettings()
    }

    function setIconTheme(themeName) {
        iconTheme = themeName
        updateGtkIconTheme(themeName)
        updateQtIconTheme(themeName)
        saveSettings()
        if (typeof Theme !== "undefined" && Theme.currentTheme === Theme.dynamic)
            Theme.generateSystemThemesFromCurrentTheme()
    }

    function setLauncherLogoMode(mode) {
        launcherLogoMode = mode
        saveSettings()
    }

    function setLauncherLogoCustomPath(path) {
        launcherLogoCustomPath = path
        saveSettings()
    }

    function setLauncherLogoColorOverride(color) {
        launcherLogoColorOverride = color
        saveSettings()
    }

    function setLauncherLogoColorInvertOnMode(invert) {
        launcherLogoColorInvertOnMode = invert
        saveSettings()
    }

    function setLauncherLogoBrightness(brightness) {
        launcherLogoBrightness = brightness
        saveSettings()
    }

    function setLauncherLogoContrast(contrast) {
        launcherLogoContrast = contrast
        saveSettings()
    }

    function setLauncherLogoSizeOffset(offset) {
        launcherLogoSizeOffset = offset
        saveSettings()
    }

    function setFontFamily(family) {
        fontFamily = family
        saveSettings()
    }

    function setFontWeight(weight) {
        fontWeight = weight
        saveSettings()
    }

    function setMonoFontFamily(family) {
        monoFontFamily = family
        saveSettings()
    }

    function setFontScale(scale) {
        fontScale = scale
        saveSettings()
    }

    function setShellitBarFontScale(scale) {
        shellitBarFontScale = scale
        saveSettings()
    }

    function setSoundsEnabled(enabled) {
        soundsEnabled = enabled
        saveSettings()
    }

    function setUseSystemSoundTheme(enabled) {
        useSystemSoundTheme = enabled
        saveSettings()
    }

    function setSoundNewNotification(enabled) {
        soundNewNotification = enabled
        saveSettings()
    }

    function setSoundVolumeChanged(enabled) {
        soundVolumeChanged = enabled
        saveSettings()
    }

    function setSoundPluggedIn(enabled) {
        soundPluggedIn = enabled
        saveSettings()
    }

    function setAcMonitorTimeout(timeout) {
        acMonitorTimeout = timeout
        saveSettings()
    }

    function setAcLockTimeout(timeout) {
        acLockTimeout = timeout
        saveSettings()
    }

    function setAcSuspendTimeout(timeout) {
        acSuspendTimeout = timeout
        saveSettings()
    }

    function setAcHibernateTimeout(timeout) {
        acHibernateTimeout = timeout
        saveSettings()
    }

    function setBatteryMonitorTimeout(timeout) {
        batteryMonitorTimeout = timeout
        saveSettings()
    }

    function setBatteryLockTimeout(timeout) {
        batteryLockTimeout = timeout
        saveSettings()
    }

    function setBatterySuspendTimeout(timeout) {
        batterySuspendTimeout = timeout
        saveSettings()
    }

    function setBatteryHibernateTimeout(timeout) {
        batteryHibernateTimeout = timeout
        saveSettings()
    }

    function setLockBeforeSuspend(enabled) {
        lockBeforeSuspend = enabled
        saveSettings()
    }

    function setLoginctlLockIntegration(enabled) {
        loginctlLockIntegration = enabled
        saveSettings()
    }

    function setLaunchPrefix(prefix) {
        launchPrefix = prefix
        saveSettings()
    }

    function setGtkThemingEnabled(enabled) {
        gtkThemingEnabled = enabled
        saveSettings()
        if (enabled && typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setQtThemingEnabled(enabled) {
        qtThemingEnabled = enabled
        saveSettings()
        if (enabled && typeof Theme !== "undefined") {
            Theme.generateSystemThemesFromCurrentTheme()
        }
    }

    function setSyncModeWithPortal(enabled) {
        syncModeWithPortal = enabled
        saveSettings()
    }

    function setShowDock(enabled) {
        showDock = enabled
        if (enabled && dockPosition === shellitBarPosition) {
            if (shellitBarPosition === SettingsData.Position.Top) {
                setDockPosition(SettingsData.Position.Bottom)
                return
            }
            if (shellitBarPosition === SettingsData.Position.Bottom) {
                setDockPosition(SettingsData.Position.Top)
                return
            }
            if (shellitBarPosition === SettingsData.Position.Left) {
                setDockPosition(SettingsData.Position.Right)
                return
            }
            if (shellitBarPosition === SettingsData.Position.Right) {
                setDockPosition(SettingsData.Position.Left)
                return
            }
        }
        saveSettings()
    }

    function setDockAutoHide(enabled) {
        dockAutoHide = enabled
        saveSettings()
    }

    function setDockGroupByApp(enabled) {
        dockGroupByApp = enabled
        saveSettings()
    }

    function setdockOpenOnOverview(enabled) {
        dockOpenOnOverview = enabled
        saveSettings()
    }

    function setDockPosition(position) {
        dockPosition = position
        if (position === SettingsData.Position.Bottom && shellitBarPosition === SettingsData.Position.Bottom && showDock) {
            setShellitBarPosition(SettingsData.Position.Top)
        }
        if (position === SettingsData.Position.Top && shellitBarPosition === SettingsData.Position.Top && showDock) {
            setShellitBarPosition(SettingsData.Position.Bottom)
        }
        if (position === SettingsData.Position.Left && shellitBarPosition === SettingsData.Position.Left && showDock) {
            setShellitBarPosition(SettingsData.Position.Right)
        }
        if (position === SettingsData.Position.Right && shellitBarPosition === SettingsData.Position.Right && showDock) {
            setShellitBarPosition(SettingsData.Position.Left)
        }
        saveSettings()
        Qt.callLater(() => forceDockLayoutRefresh())
    }

    function setDockSpacing(spacing) {
        dockSpacing = spacing
        saveSettings()
    }

    function setDockBottomGap(gap) {
        dockBottomGap = gap
        saveSettings()
    }

    function setDockIconSize(size) {
        dockIconSize = size
        saveSettings()
    }

    function setDockOpenOnOverview(enabled) {
        dockOpenOnOverview = enabled
        saveSettings()
    }

    function setDockIndicatorStyle(style) {
        dockIndicatorStyle = style
        saveSettings()
    }

    function setNotificationOverlayEnabled(enabled) {
        notificationOverlayEnabled = enabled
        saveSettings()
    }

    function setShellitBarAutoHide(enabled) {
        shellitBarAutoHide = enabled
        saveSettings()
    }

    function setShellitBarOpenOnOverview(enabled) {
        shellitBarOpenOnOverview = enabled
        saveSettings()
    }

    function setShellitBarVisible(visible) {
        shellitBarVisible = visible
        saveSettings()
    }

    function toggleShellitBarVisible() {
        shellitBarVisible = !shellitBarVisible
        saveSettings()
    }

    function setShellitBarSpacing(spacing) {
        shellitBarSpacing = spacing
        saveSettings()
    }

    function setShellitBarBottomGap(gap) {
        shellitBarBottomGap = gap
        saveSettings()
    }

    function setShellitBarInnerPadding(padding) {
        shellitBarInnerPadding = padding
        saveSettings()
    }

    function setShellitBarPosition(position) {
        shellitBarPosition = position
        if (position === SettingsData.Position.Bottom && dockPosition === SettingsData.Position.Bottom && showDock) {
            setDockPosition(SettingsData.Position.Top)
            return
        }
        if (position === SettingsData.Position.Top && dockPosition === SettingsData.Position.Top && showDock) {
            setDockPosition(SettingsData.Position.Bottom)
            return
        }
        if (position === SettingsData.Position.Left && dockPosition === SettingsData.Position.Left && showDock) {
            setDockPosition(SettingsData.Position.Right)
            return
        }
        if (position === SettingsData.Position.Right && dockPosition === SettingsData.Position.Right && showDock) {
            setDockPosition(SettingsData.Position.Left)
            return
        }
        saveSettings()
    }

    function setShellitBarSquareCorners(enabled) {
        shellitBarSquareCorners = enabled
        saveSettings()
    }

    function setShellitBarNoBackground(enabled) {
        shellitBarNoBackground = enabled
        saveSettings()
    }

    function setShellitBarGothCornersEnabled(enabled) {
        shellitBarGothCornersEnabled = enabled
        saveSettings()
    }

    function setShellitBarBorderEnabled(enabled) {
        shellitBarBorderEnabled = enabled
        saveSettings()
    }

    function setPopupGapsAuto(enabled) {
        popupGapsAuto = enabled
        saveSettings()
    }

    function setPopupGapsManual(value) {
        popupGapsManual = value
        saveSettings()
    }

    function setLockScreenShowPowerActions(enabled) {
        lockScreenShowPowerActions = enabled
        saveSettings()
    }

    function setEnableFprint(enabled) {
        enableFprint = enabled
        saveSettings()
    }

    function setMaxFprintTries(tries) {
        maxFprintTries = tries
        saveSettings()
    }

    function setHideBrightnessSlider(enabled) {
        hideBrightnessSlider = enabled
        saveSettings()
    }

    function setNotificationTimeoutLow(timeout) {
        notificationTimeoutLow = timeout
        saveSettings()
    }

    function setNotificationTimeoutNormal(timeout) {
        notificationTimeoutNormal = timeout
        saveSettings()
    }

    function setNotificationTimeoutCritical(timeout) {
        notificationTimeoutCritical = timeout
        saveSettings()
    }

    function setNotificationPopupPosition(position) {
        notificationPopupPosition = position
        saveSettings()
    }

    function setOsdAlwaysShowValue(enabled) {
        osdAlwaysShowValue = enabled
        saveSettings()
    }

    function setPowerActionConfirm(confirm) {
        powerActionConfirm = confirm;
        saveSettings();
    }

    function setCustomPowerActionLock(command) {
        customPowerActionLock = command;
        saveSettings();
    }

    function setCustomPowerActionLogout(command) {
        customPowerActionLogout = command;
        saveSettings();
    }

    function setCustomPowerActionSuspend(command) {
        customPowerActionSuspend = command;
        saveSettings();
    }

    function setCustomPowerActionHibernate(command) {
        customPowerActionHibernate = command;
        saveSettings();
    }

    function setCustomPowerActionReboot(command) {
        customPowerActionReboot = command;
        saveSettings();
    }

    function setCustomPowerActionPowerOff(command) {
        customPowerActionPowerOff = command;
        saveSettings();
    }

    function setUpdaterUseCustomCommandEnabled(enabled) {
        updaterUseCustomCommand = enabled;
        saveSettings();
    }

    function setUpdaterCustomCommand(command) {
        updaterCustomCommand = command;
        saveSettings();
    }

    function setUpdaterTerminalAdditionalParams(customArgs) {
        updaterTerminalAdditionalParams = customArgs;
        saveSettings();
    }

    function setScreenPreferences(prefs) {
        screenPreferences = prefs
        saveSettings()
    }

    function setShowOnLastDisplay(prefs) {
        showOnLastDisplay = prefs
        saveSettings()
    }

    function setBrightnessDevicePins(pins) {
        brightnessDevicePins = pins
        saveSettings()
    }

    function getPluginSetting(pluginId, key, defaultValue) {
        if (!pluginSettings[pluginId]) {
            return defaultValue
        }
        return pluginSettings[pluginId][key] !== undefined ? pluginSettings[pluginId][key] : defaultValue
    }

    function setPluginSetting(pluginId, key, value) {
        if (!pluginSettings[pluginId]) {
            pluginSettings[pluginId] = {}
        }
        pluginSettings[pluginId][key] = value
        savePluginSettings()
    }

    function removePluginSettings(pluginId) {
        if (pluginSettings[pluginId]) {
            delete pluginSettings[pluginId]
            savePluginSettings()
        }
    }

    function getPluginSettingsForPlugin(pluginId) {
        return pluginSettings[pluginId] || {}
    }

    ListModel {
        id: leftWidgetsModel
    }

    ListModel {
        id: centerWidgetsModel
    }

    ListModel {
        id: rightWidgetsModel
    }

    Timer {
        id: fontCheckTimer

        interval: 3000
        repeat: false
        onTriggered: {
            var availableFonts = Qt.fontFamilies()
            var missingFonts = []
            if (fontFamily === defaultFontFamily && !availableFonts.includes(defaultFontFamily))
            missingFonts.push(defaultFontFamily)

            if (monoFontFamily === defaultMonoFontFamily && !availableFonts.includes(defaultMonoFontFamily))
            missingFonts.push(defaultMonoFontFamily)

            if (missingFonts.length > 0) {
                var message = "Missing fonts: " + missingFonts.join(", ") + ". Using system defaults."
                ToastService.showWarning(message)
            }
        }
    }

    property Process testNotificationProcess

    testNotificationProcess: Process {
        command: []
        running: false
    }

    property Timer testNotifTimer1

    testNotifTimer1: Timer {
        interval: 400
        repeat: false
        onTriggered: sendTestNotification(1)
    }

    property Timer testNotifTimer2

    testNotifTimer2: Timer {
        interval: 800
        repeat: false
        onTriggered: sendTestNotification(2)
    }

    FileView {
        id: settingsFile

        path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/Shellit/settings.json"
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        watchChanges: true
        onLoaded: {
            parseSettings(settingsFile.text())
            hasTriedDefaultSettings = false
        }
        onLoadFailed: error => {
            if (!hasTriedDefaultSettings) {
                hasTriedDefaultSettings = true
                defaultSettingsCheckProcess.running = true
            } else {
                applyStoredTheme()
            }
        }
    }

    FileView {
        id: pluginSettingsFile

        path: pluginSettingsPath
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        watchChanges: true
        onLoaded: {
            parsePluginSettings(pluginSettingsFile.text())
        }
        onLoadFailed: error => {
            pluginSettings = {}
        }
    }

    Process {
        id: systemDefaultDetectionProcess

        command: ["sh", "-c", "gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | sed \"s/'//g\" || echo ''"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0 && stdout && stdout.length > 0)
            systemDefaultIconTheme = stdout.trim()
            else
            systemDefaultIconTheme = ""
            iconThemeDetectionProcess.running = true
        }
    }

    Process {
        id: iconThemeDetectionProcess

        command: ["sh", "-c", "find /usr/share/icons ~/.local/share/icons ~/.icons -maxdepth 1 -type d 2>/dev/null | sed 's|.*/||' | grep -v '^icons$' | sort -u"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var detectedThemes = ["System Default"]
                if (text && text.trim()) {
                    var themes = text.trim().split('\n')
                    for (var i = 0; i < themes.length; i++) {
                        var theme = themes[i].trim()
                        if (theme && theme !== "" && theme !== "default" && theme !== "hicolor" && theme !== "locolor")
                        detectedThemes.push(theme)
                    }
                }
                availableIconThemes = detectedThemes
            }
        }
    }

    Process {
        id: qtToolsDetectionProcess

        command: ["sh", "-c", "echo -n 'qt5ct:'; command -v qt5ct >/dev/null && echo 'true' || echo 'false'; echo -n 'qt6ct:'; command -v qt6ct >/dev/null && echo 'true' || echo 'false'; echo -n 'gtk:'; (command -v gsettings >/dev/null || command -v dconf >/dev/null) && echo 'true' || echo 'false'"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    var lines = text.trim().split('\n')
                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i]
                        if (line.startsWith('qt5ct:'))
                        qt5ctAvailable = line.split(':')[1] === 'true'
                        else if (line.startsWith('qt6ct:'))
                        qt6ctAvailable = line.split(':')[1] === 'true'
                        else if (line.startsWith('gtk:'))
                        gtkAvailable = line.split(':')[1] === 'true'
                    }
                }
            }
        }
    }

    Process {
        id: defaultSettingsCheckProcess

        command: ["sh", "-c", "CONFIG_DIR=\"" + _configDir
            + "/Shellit\"; if [ -f \"$CONFIG_DIR/default-settings.json\" ] && [ ! -f \"$CONFIG_DIR/settings.json\" ]; then cp --no-preserve=mode \"$CONFIG_DIR/default-settings.json\" \"$CONFIG_DIR/settings.json\" && echo 'copied'; else echo 'not_found'; fi"]
        running: false
        onExited: exitCode => {
            if (exitCode === 0) {
                console.info("Copied default-settings.json to settings.json")
                settingsFile.reload()
            } else {
                applyStoredTheme()
            }
        }
    }

    Process {
        id: fprintdDetectionProcess

        command: ["sh", "-c", "command -v fprintd-list >/dev/null 2>&1"]
        running: false
        onExited: exitCode => {
            fprintdAvailable = (exitCode === 0)
        }
    }

    IpcHandler {
        function reveal(): string {
            root.setShellitBarVisible(true)
            return "BAR_SHOW_SUCCESS"
        }

        function hide(): string {
            root.setShellitBarVisible(false)
            return "BAR_HIDE_SUCCESS"
        }

        function toggle(): string {
            root.toggleShellitBarVisible()
            return root.shellitBarVisible ? "BAR_SHOW_SUCCESS" : "BAR_HIDE_SUCCESS"
        }

        function status(): string {
            return root.shellitBarVisible ? "visible" : "hidden"
        }

        target: "bar"
    }
}
