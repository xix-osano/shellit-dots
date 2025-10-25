import QtQuick
import Quickshell
import qs.Common
import qs.Services

QtObject {
    id: manager

    property var modelData
    property int topMargin: 0
    property int baseNotificationHeight: 120
    property int maxTargetNotifications: 4
    property var popupWindows: [] // strong refs to windows (live until exitFinished)
    property var destroyingWindows: new Set()
    property Component popupComponent

    popupComponent: Component {
        NotificationPopup {
            onEntered: manager._onPopupEntered(this)
            onExitFinished: manager._onPopupExitFinished(this)
        }
    }

    property Connections notificationConnections

    notificationConnections: Connections {
        function onVisibleNotificationsChanged() {
            manager._sync(NotificationService.visibleNotifications)
        }

        target: NotificationService
    }

    property Timer sweeper

    sweeper: Timer {
        interval: 500
        running: false
        repeat: true
        onTriggered: {
            const toRemove = []
            for (const p of popupWindows) {
                if (!p) {
                    toRemove.push(p)
                    continue
                }
                const isZombie = p.status === Component.Null || (!p.visible && !p.exiting) || (!p.notificationData && !p._isDestroying) || (!p.hasValidData && !p._isDestroying)
                if (isZombie) {
                    toRemove.push(p)
                    if (p.forceExit) {
                        p.forceExit()
                    } else if (p.destroy) {
                        try {
                            p.destroy()
                        } catch (e) {

                        }
                    }
                }
            }
            if (toRemove.length) {
                popupWindows = popupWindows.filter(p => toRemove.indexOf(p) === -1)
                const survivors = _active().sort((a, b) => a.screenY - b.screenY)
                for (let k = 0; k < survivors.length; ++k) {
                    survivors[k].screenY = topMargin + k * baseNotificationHeight
                }
            }
            if (popupWindows.length === 0) {
                sweeper.stop()
            }
        }
    }

    function _hasWindowFor(w) {
        return popupWindows.some(p => p && p.notificationData === w && !p._isDestroying && p.status !== Component.Null)
    }

    function _isValidWindow(p) {
        return p && p.status !== Component.Null && !p._isDestroying && p.hasValidData
    }

    function _canMakeRoomFor(wrapper) {
        const activeWindows = _active()
        if (activeWindows.length < maxTargetNotifications) {
            return true
        }
        if (!wrapper || !wrapper.notification) {
            return false
        }
        const incomingUrgency = wrapper.notification.urgency || 0
        for (const p of activeWindows) {
            if (!p.notificationData || !p.notificationData.notification) {
                continue
            }
            const existingUrgency = p.notificationData.notification.urgency || 0
            if (existingUrgency < incomingUrgency) {
                return true
            }
            if (existingUrgency === incomingUrgency) {
                const timer = p.notificationData.timer
                if (timer && !timer.running) {
                    return true
                }
            }
        }
        return false
    }

    function _makeRoomForNew(wrapper) {
        const activeWindows = _active()
        if (activeWindows.length < maxTargetNotifications) {
            return
        }
        const toRemove = _selectPopupToRemove(activeWindows, wrapper)
        if (toRemove && !toRemove.exiting) {
            toRemove.notificationData.removedByLimit = true
            toRemove.notificationData.popup = false
            if (toRemove.notificationData.timer) {
                toRemove.notificationData.timer.stop()
            }
        }
    }

    function _selectPopupToRemove(activeWindows, incomingWrapper) {
        const incomingUrgency = (incomingWrapper && incomingWrapper.notification) ? incomingWrapper.notification.urgency || 0 : 0
        const sortedWindows = activeWindows.slice().sort((a, b) => {
                                                             const aUrgency = (a.notificationData && a.notificationData.notification) ? a.notificationData.notification.urgency || 0 : 0
                                                             const bUrgency = (b.notificationData && b.notificationData.notification) ? b.notificationData.notification.urgency || 0 : 0
                                                             if (aUrgency !== bUrgency) {
                                                                 return aUrgency - bUrgency
                                                             }
                                                             const aTimer = a.notificationData && a.notificationData.timer
                                                             const bTimer = b.notificationData && b.notificationData.timer
                                                             const aRunning = aTimer && aTimer.running
                                                             const bRunning = bTimer && bTimer.running
                                                             if (aRunning !== bRunning) {
                                                                 return aRunning ? 1 : -1
                                                             }
                                                             return b.screenY - a.screenY
                                                         })
        return sortedWindows[0]
    }

    function _sync(newWrappers) {
        for (const w of newWrappers) {
            if (w && !_hasWindowFor(w)) {
                insertNewestAtTop(w)
            }
        }
        for (const p of popupWindows.slice()) {
            if (!_isValidWindow(p)) {
                continue
            }
            if (p.notificationData && newWrappers.indexOf(p.notificationData) === -1 && !p.exiting) {
                p.notificationData.removedByLimit = true
                p.notificationData.popup = false
            }
        }
    }

    function insertNewestAtTop(wrapper) {
        if (!wrapper) {
            return
        }
        for (const p of popupWindows) {
            if (!_isValidWindow(p)) {
                continue
            }
            if (p.exiting) {
                continue
            }
            p.screenY = p.screenY + baseNotificationHeight
        }
        const notificationId = wrapper && wrapper.notification ? wrapper.notification.id : ""
        const win = popupComponent.createObject(null, {
                                                    "notificationData": wrapper,
                                                    "notificationId": notificationId,
                                                    "screenY": topMargin,
                                                    "screen": manager.modelData
                                                })
        if (!win) {
            return
        }
        if (!win.hasValidData) {
            win.destroy()
            return
        }
        popupWindows.push(win)
        if (!sweeper.running) {
            sweeper.start()
        }
    }

    function _active() {
        return popupWindows.filter(p => _isValidWindow(p) && p.notificationData && p.notificationData.popup && !p.exiting)
    }

    function _bottom() {
        let b = null
        let maxY = -1
        for (const p of _active()) {
            if (p.screenY > maxY) {
                maxY = p.screenY
                b = p
            }
        }
        return b
    }

    function _onPopupEntered(p) {}

    function _onPopupExitFinished(p) {
        if (!p) {
            return
        }
        const windowId = p.toString()
        if (destroyingWindows.has(windowId)) {
            return
        }
        destroyingWindows.add(windowId)
        const i = popupWindows.indexOf(p)
        if (i !== -1) {
            popupWindows.splice(i, 1)
            popupWindows = popupWindows.slice()
        }
        if (NotificationService.releaseWrapper && p.notificationData) {
            NotificationService.releaseWrapper(p.notificationData)
        }
        Qt.callLater(() => {
                         if (p && p.destroy) {
                             try {
                                 p.destroy()
                             } catch (e) {

                             }
                         }
                         Qt.callLater(() => destroyingWindows.delete(windowId))
                     })
        const survivors = _active().sort((a, b) => a.screenY - b.screenY)
        for (let k = 0; k < survivors.length; ++k) {
            survivors[k].screenY = topMargin + k * baseNotificationHeight
        }
    }

    function cleanupAllWindows() {
        sweeper.stop()
        for (const p of popupWindows.slice()) {
            if (p) {
                try {
                    if (p.forceExit) {
                        p.forceExit()
                    } else if (p.destroy) {
                        p.destroy()
                    }
                } catch (e) {

                }
            }
        }
        popupWindows = []
        destroyingWindows.clear()
    }

    onPopupWindowsChanged: {
        if (popupWindows.length > 0 && !sweeper.running) {
            sweeper.start()
        } else if (popupWindows.length === 0 && sweeper.running) {
            sweeper.stop()
        }
    }
}
