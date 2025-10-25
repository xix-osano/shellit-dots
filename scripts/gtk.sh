#!/usr/bin/env bash

CONFIG_DIR="$1"
IS_LIGHT="$2"
SHELL_DIR="$3"

if [ -z "$CONFIG_DIR" ] || [ -z "$IS_LIGHT" ] || [ -z "$SHELL_DIR" ]; then
    echo "Usage: $0 <config_dir> <is_light> <shell_dir>" >&2
    exit 1
fi

apply_gtk3_colors() {
    local config_dir="$1"
    local is_light="$2"
    local shell_dir="$3"
    
    local gtk3_dir="$config_dir/gtk-3.0"
    local Shellit_colors="$gtk3_dir/Shellit-colors.css"
    local gtk_css="$gtk3_dir/gtk.css"
    
    if [ ! -f "$Shellit_colors" ]; then
        echo "Error: Shellit-colors.css not found at $Shellit_colors" >&2
        echo "Run matugen first to generate theme files" >&2
        exit 1
    fi
    
    if [ -L "$gtk_css" ]; then
        rm "$gtk_css"
    elif [ -f "$gtk_css" ]; then
        mv "$gtk_css" "$gtk_css.backup.$(date +%s)"
        echo "Backed up existing gtk.css"
    fi
    
    ln -s "Shellit-colors.css" "$gtk_css"
    echo "Created symlink: $gtk_css -> Shellit-colors.css"
}

apply_gtk4_colors() {
    local config_dir="$1"
    
    local gtk4_dir="$config_dir/gtk-4.0"
    local Shellit_colors="$gtk4_dir/Shellit-colors.css"
    local gtk_css="$gtk4_dir/gtk.css"
    local gtk4_import="@import url(\"Shellit-colors.css\");"
    
    if [ ! -f "$Shellit_colors" ]; then
        echo "Error: GTK4 Shellit-colors.css not found at $Shellit_colors" >&2
        echo "Run matugen first to generate theme files" >&2
        exit 1
    fi
    
    if [ -f "$gtk_css" ]; then
        sed -i '/^@import url.*Shellit-colors\.css.*);$/d' "$gtk_css"
        sed -i "1i\\$gtk4_import" "$gtk_css"
    else
        echo "$gtk4_import" > "$gtk_css"
    fi
    echo "Updated GTK4 CSS import"
}

mkdir -p "$CONFIG_DIR/gtk-3.0" "$CONFIG_DIR/gtk-4.0"

apply_gtk3_colors "$CONFIG_DIR" "$IS_LIGHT" "$SHELL_DIR"
apply_gtk4_colors "$CONFIG_DIR"

echo "GTK colors applied successfully"