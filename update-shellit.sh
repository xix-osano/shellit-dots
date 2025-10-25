#!/bin/bash
set -e
cd ~/.config/quickshell/shellit

echo "[Shellit] Pulling latest changes..."
git pull --rebase

echo "[Shellit] Rebuilding..."
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build

echo "[Shellit] Installing..."
sudo cmake --install build

echo "[Shellit] Reloading Quickshell..."

# Check if the Quickshell binary supports --reload, otherwise restart it
if quickshell --help 2>/dev/null | grep -q -- "--reload"; then
    quickshell --reload
else
    echo "[Shellit] --reload not supported. Restarting Quickshell instead..."
    pkill quickshell || true
    sleep 1
    quickshell --config /etc/xdg/quickshell/shellit/shell.qml &
fi

echo "[Shellit] Update complete."
