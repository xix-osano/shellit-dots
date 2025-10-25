#!/bin/bash
set -euo pipefail

REPO_DIR="$HOME/.config/quickshell/shellit"
INSTALL_PREFIX="/"
BIN_LINK="$HOME/.local/bin/update-shellit"

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
git fetch origin master
git rebase origin/master || {
    echo "[Shellit] ⚠️ Rebase failed. Attempting to continue..."
    git rebase --abort || true
    git pull --rebase
}

# -----------------------------------------------------------------------------
# Rebuild project
# -----------------------------------------------------------------------------
echo "[Shellit] ⚙️ Rebuilding..."
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
cmake --build build --parallel

# -----------------------------------------------------------------------------
# Install configs
# -----------------------------------------------------------------------------
echo "[Shellit] 📦 Installing..."
sudo cmake --install build

# -----------------------------------------------------------------------------
# Ensure symlink exists
# -----------------------------------------------------------------------------
mkdir -p "$(dirname "$BIN_LINK")"
ln -sf "$REPO_DIR/update-shellit.sh" "$BIN_LINK"

# -----------------------------------------------------------------------------
# Reload quickshell
# -----------------------------------------------------------------------------
echo "[Shellit] 🌀 Reloading Quickshell..."
if command -v quickshell >/dev/null 2>&1; then
    quickshell --reload || echo "[Shellit] ⚠️ Quickshell reload failed, restart manually if needed."
else
    echo "[Shellit] ⚠️ Quickshell not found in PATH."
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo "[Shellit] ✅ Update complete — running the freshest configs."

