pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell.Io

Singleton {
    id: root

    // Paths
    property string stateDir: StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/Shellit"
    property string filePath: stateDir + "/todo.json"

    // Data
    property var list: []

    signal listChanged()

    function ensureStateDir() {
        const dir = stateDir
        const d = new QDir()
        if (!d.exists(dir)) {
            d.mkpath(dir)
        }
    }

    function save() {
        ensureStateDir()
        try {
            todoFile.setText(JSON.stringify(list, null, 2))
        } catch (e) {
            console.warn("[TodoService] Failed to save:", e)
        }
    }

    function refresh() {
        todoFile.reload()
    }

    function addTask(desc) {
        const trimmed = desc.trim()
        if (!trimmed.length) return
        list.push({
            content: trimmed,
            done: false,
            created: new Date().toISOString()
        })
        list = list.slice(0)
        save()
        listChanged()
    }

    function markDone(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = true
            list = list.slice(0)
            save()
            listChanged()
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false
            list = list.slice(0)
            save()
            listChanged()
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            list = list.slice(0)
            save()
            listChanged()
        }
    }

    FileView {
        id: todoFile
        path: root.filePath
        blockLoading: true
        blockWrites: false
        watchChanges: true

        onLoaded: {
            try {
                root.list = JSON.parse(todoFile.text())
                console.log("[TodoService] Loaded", root.list.length, "tasks")
            } catch (e) {
                console.warn("[TodoService] Error parsing file:", e)
                root.list = []
            }
        }

        onLoadFailed: {
            console.log("[TodoService] Creating new todo file due to:", error)
            root.list = []
            root.save()
        }
    }

    Component.onCompleted: {
        refresh()
    }
}
