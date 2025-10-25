import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "wallpaperWatcherDaemon"

    StyledText {
        text: "Wallpaper Change Hook"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "scriptPath"
        label: "Script Path"
        description: "Path to a script that will be executed when the wallpaper changes. The new wallpaper path will be passed as the first argument."
        placeholder: "/path/to/your/script.sh"
        defaultValue: ""
    }
}
