pragma Singleton

pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell.Io

Singleton {
    id: service

    property string stateDir: StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/Shellit"
    property string filePath: stateDir + "/todo.json"
    property var list: []

    signal listChanged()

    function ensureStateDir() {
        const dir = stateDir
        const d = new QDir()
        if (!d.exists(dir)) d.mkpath(dir)
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
        path: service.filePath
        blockLoading: true
        blockWrites: false
        watchChanges: true

        onLoaded: {
            try {
                service.list = JSON.parse(todoFile.text())
                console.log("[TodoService] Loaded", service.list.length, "tasks")
            } catch (e) {
                console.warn("[TodoService] Error parsing file:", e)
                service.list = []
            }
        }

        onLoadFailed: {
            console.log("[TodoService] Creating new todo file:", error)
            service.list = []
            service.save()
        }
    }
}



// pragma Singleton
// pragma ComponentBehavior: Bound

// import QtQuick
// import Qt.labs.platform // for StandardPaths
// import QtQuick.LocalStorage
// import QtCore

// Singleton {
//     id: service

//     property string stateDir: StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/Shellit"
//     property string todoFile: stateDir + "/todo.json"

//     function ensureStateDir() {
//         const dir = service.stateDir
//         if (!Qt.resolvedUrl(dir))
//             return
//         const f = new QDir()
//         if (!f.exists(dir))
//             f.mkpath(dir)
//     }

//     function readTodos() {
//         ensureStateDir()
//         try {
//             const file = Qt.openUrlExternally("file://" + todoFile)
//             const f = new QFile(todoFile)
//             if (f.exists && f.open(QIODevice.ReadOnly)) {
//                 const content = f.readAll()
//                 f.close()
//                 return JSON.parse(content)
//             }
//         } catch (e) {
//             console.log("[TodoService] Error reading todos:", e)
//         }
//         return []
//     }

//     function writeTodos(todos) {
//         ensureStateDir()
//         try {
//             const f = new QFile(todoFile)
//             if (f.open(QIODevice.WriteOnly | QIODevice.Truncate)) {
//                 f.write(JSON.stringify(todos, null, 2))
//                 f.close()
//                 console.log("[TodoService] Saved todos:", todoFile)
//             }
//         } catch (e) {
//             console.log("[TodoService] Error writing todos:", e)
//         }
//     }
// }
