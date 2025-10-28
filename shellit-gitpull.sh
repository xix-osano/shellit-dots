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
echo "[Shellit] ✅ Pull complete."