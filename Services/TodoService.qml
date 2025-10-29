pragma Singleton
pragma ComponentBehavior: Bound

import qs.Common
import QtQuick
import QtCore
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    signal tasksUpdated()

    // Paths
    readonly property string baseDir: Paths.strip(StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/Shellit")
    readonly property string filePath: baseDir + "/todo.json"

    // Data
    property var list: []
    
    function ensureBaseDir() {
        const dir = baseDir
        try {
            const fileInfo = File.info(dir)
            if (!fileInfo.exists) {
                File.makePath(dir)
                console.log("[TodoService] Created base directory:", dir)
            }
        } catch (e) {
            console.warn("[TodoService] Failed to ensure base dir:", e)
        }
    }
    
    function save() {
        ensureBaseDir()
        if (!todoFile.ready) {
            console.warn("[TodoService] File not ready — delaying save")
            return
        }
        try {
            todoFile.setText(JSON.stringify(root.list, null, 2))
            console.log("[TodoService] Saved", root.list.length, "tasks")
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
            root.list = list.slice(0)
            save()
            tasksUpdated()
        }
    }

    function markUnfinished(index) {
        if (index >= 0 && index < list.length) {
            list[index].done = false
            root.list = list.slice(0)
            save()
            tasksUpdated()
        }
    }

    function deleteItem(index) {
        if (index >= 0 && index < list.length) {
            list.splice(index, 1)
            root.list = list.slice(0)
            save()
            tasksUpdated()
        }
    }
    
    Component.onCompleted: {
        refresh()
    }

    FileView {
        id: todoFile
        path: root.filePath : ""
        blockLoading: false
        blockWrites: true
        atomicWrites: true
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
