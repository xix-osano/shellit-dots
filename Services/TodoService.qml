pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    signal tasksUpdated()

    // Paths
    property string stateDir: StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/Shellit"
    property string filePath: stateDir + "/todo.json"

    // Data
    property var list: []
    
    function ensureStateDir() {
        const dir = stateDir
        try {
            const fileInfo = File.info(dir)
            if (!fileInfo.exists) {
                File.makePath(dir)
                console.log("[TodoService] Created state directory:", dir)
            }
        } catch (e) {
            console.warn("[TodoService] Failed to ensure state dir:", e)
        }
    }
    
    function save() {
        ensureStateDir()
        if (!todoFile.ready) {
            console.warn("[TodoService] File not ready — delaying save")
            return
        }
        try {
            todoFile.setText(JSON.stringify(list, null, 2))
            console.log("[TodoService] Saved", list.length, "tasks")
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
        tasksUpdated()
    }

    function markDone(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = true
            list = list.slice(0)
            save()
            tasksUpdated()
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false
            list = list.slice(0)
            save()
            tasksUpdated()
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            list = list.slice(0)
            save()
            tasksUpdated()
        }
    }
    
    Component.onCompleted: {
        refresh()
    }

    FileView {
        id: todoFile
        path: root.filePath
        blockLoading: false
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
            root.tasksUpdated()
        }

        onLoadFailed: (error) => {
            console.log("[TodoService] Creating new todo file due to:", error)
            root.list = []
            root.save()
            root.tasksUpdated()
        }
    }
}
