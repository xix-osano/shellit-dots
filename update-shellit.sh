#!/bin/bash
set -euo pipefail

REPO_DIR="$HOME/.config/quickshell/shellit"
INSTALL_PREFIX="/"

# -----------------------------------------------------------------------------
# Version flag
# -----------------------------------------------------------------------------
if [[ "${1:-}" == "--version" ]]; then
    cd "$REPO_DIR"
    VERSION=$(git describe --tags --always 2>/dev/null || echo "unknown")
    echo "Shellit Updater — version $VERSION"
    exit 0
fi

# -----------------------------------------------------------------------------
# Ensure environment
# -----------------------------------------------------------------------------
if [[ ! -d "$REPO_DIR" ]]; then
    echo "[Shellit] ❌ Repository not found at $REPO_DIR"
    exit 1
fi

cd "$REPO_DIR"

# -----------------------------------------------------------------------------
# Pull latest updates
# -----------------------------------------------------------------------------
echo "[Shellit] 🔄 Pulling latest changes..."
git pull --rebase

# -----------------------------------------------------------------------------
# Rebuild project
# -----------------------------------------------------------------------------
echo "[Shellit] ⚙️ Rebuilding..."
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
cmake --build build

# -----------------------------------------------------------------------------
# Install configs
# -----------------------------------------------------------------------------
echo "[Shellit] 📦 Installing..."
sudo cmake --install build

# -----------------------------------------------------------------------------
# Reload quickshell
# -----------------------------------------------------------------------------
# echo "[Shellit] 🌀 Reloading Quickshell..."
# if command -v quickshell >/dev/null 2>&1; then
#     if ! quickshell --reload 2>/dev/null; then
#         echo "[Shellit] ⚠️ Reload not supported — restarting instead..."
#         pkill -HUP quickshell || echo "[Shellit] ℹ️ Please restart Quickshell manually."
#     fi
# else
#     echo "[Shellit] ⚠️ Quickshell not found in PATH."
# fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo "[Shellit] ✅ Update complete — running the freshest configs."

