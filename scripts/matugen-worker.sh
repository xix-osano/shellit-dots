#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 5 ]; then
    echo "Usage: $0 STATE_DIR SHELL_DIR CONFIG_DIR SYNC_MODE_WITH_PORTAL --run" >&2
    exit 1
fi

STATE_DIR="$1"
SHELL_DIR="$2"
CONFIG_DIR="$3"
SYNC_MODE_WITH_PORTAL="$4"

if [ ! -d "$STATE_DIR" ]; then
    echo "Error: STATE_DIR '$STATE_DIR' does not exist" >&2
    exit 1
fi

if [ ! -d "$SHELL_DIR" ]; then
    echo "Error: SHELL_DIR '$SHELL_DIR' does not exist" >&2
    exit 1
fi

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: CONFIG_DIR '$CONFIG_DIR' does not exist" >&2
    exit 1
fi

shift 4

if [[ "${1:-}" != "--run" ]]; then
  echo "usage: $0 STATE_DIR SHELL_DIR CONFIG_DIR SYNC_MODE_WITH_PORTAL --run" >&2
  exit 1
fi

DESIRED_JSON="$STATE_DIR/matugen.desired.json"
BUILT_KEY="$STATE_DIR/matugen.key"
LAST_JSON="$STATE_DIR/last.json"
LOCK="$STATE_DIR/matugen-worker.lock"

exec 9>"$LOCK"
flock 9


read_desired() {
  [[ ! -f "$DESIRED_JSON" ]] && { echo "no desired state" >&2; exit 0; }
  cat "$DESIRED_JSON"
}

key_of() {
  local json="$1"
  local kind=$(echo "$json" | sed 's/.*"kind": *"\([^"]*\)".*/\1/')
  local value=$(echo "$json" | sed 's/.*"value": *"\([^"]*\)".*/\1/')
  local mode=$(echo "$json" | sed 's/.*"mode": *"\([^"]*\)".*/\1/')
  local icon=$(echo "$json" | sed 's/.*"iconTheme": *"\([^"]*\)".*/\1/')
  local matugen_type=$(echo "$json" | sed 's/.*"matugenType": *"\([^"]*\)".*/\1/')
  local surface_base=$(echo "$json" | sed 's/.*"surfaceBase": *"\([^"]*\)".*/\1/')
  local run_user_templates=$(echo "$json" | sed 's/.*"runUserTemplates": *\([^,}]*\).*/\1/')
  [[ -z "$icon" ]] && icon="System Default"
  [[ -z "$matugen_type" ]] && matugen_type="scheme-tonal-spot"
  [[ -z "$surface_base" ]] && surface_base="sc"
  [[ -z "$run_user_templates" ]] && run_user_templates="true"
  echo "${kind}|${value}|${mode}|${icon}|${matugen_type}|${surface_base}|${run_user_templates}" | sha256sum | cut -d' ' -f1
}

set_system_color_scheme() {
  local mode="$1"

  if [[ "$SYNC_MODE_WITH_PORTAL" != "true" ]]; then
    return 0
  fi

  local target_scheme
  if [[ "$mode" == "light" ]]; then
    target_scheme="default"
  else
    target_scheme="prefer-dark"
  fi

  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme "$target_scheme" >/dev/null 2>&1 || true
  elif command -v dconf >/dev/null 2>&1; then
    dconf write /org/gnome/desktop/interface/color-scheme "'$target_scheme'" >/dev/null 2>&1 || true
  fi
}

build_once() {
  local json="$1"
  local kind value mode icon matugen_type surface_base run_user_templates
  kind=$(echo "$json" | sed 's/.*"kind": *"\([^"]*\)".*/\1/')
  value=$(echo "$json" | sed 's/.*"value": *"\([^"]*\)".*/\1/')
  mode=$(echo "$json" | sed 's/.*"mode": *"\([^"]*\)".*/\1/')
  icon=$(echo "$json" | sed 's/.*"iconTheme": *"\([^"]*\)".*/\1/')
  matugen_type=$(echo "$json" | sed 's/.*"matugenType": *"\([^"]*\)".*/\1/')
  surface_base=$(echo "$json" | sed 's/.*"surfaceBase": *"\([^"]*\)".*/\1/')
  run_user_templates=$(echo "$json" | sed 's/.*"runUserTemplates": *\([^,}]*\).*/\1/')
  [[ -z "$icon" ]] && icon="System Default"
  [[ -z "$matugen_type" ]] && matugen_type="scheme-tonal-spot"
  [[ -z "$surface_base" ]] && surface_base="sc"
  [[ -z "$run_user_templates" ]] && run_user_templates="true"

  USER_MATUGEN_DIR="$CONFIG_DIR/matugen/dms"
  
  TMP_CFG="$(mktemp)"
  trap 'rm -f "$TMP_CFG"' RETURN

  if [[ "$run_user_templates" == "true" ]] && [[ -f "$CONFIG_DIR/matugen/config.toml" ]]; then
    awk '/^\[config/{p=1} /^\[templates/{p=0} p' "$CONFIG_DIR/matugen/config.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  else
    echo "[config]" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  grep -v '^\[config\]' "$SHELL_DIR/matugen/configs/base.toml" >> "$TMP_CFG"
  echo "" >> "$TMP_CFG"

  cat >> "$TMP_CFG" << EOF
[templates.Shellit]
input_path = '$SHELL_DIR/matugen/templates/Shellit.json'
output_path = '$STATE_DIR/dms-colors.json'

EOF

  # If light mode, use gtk3 light config
  if [[ "$mode" == "light" ]]; then
    cat "$SHELL_DIR/matugen/configs/gtk3-light.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  else
    cat "$SHELL_DIR/matugen/configs/gtk3-dark.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  if command -v niri >/dev/null 2>&1; then
    cat "$SHELL_DIR/matugen/configs/niri.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  if command -v qt5ct >/dev/null 2>&1; then
    cat "$SHELL_DIR/matugen/configs/qt5ct.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  if command -v qt6ct >/dev/null 2>&1; then
    cat "$SHELL_DIR/matugen/configs/qt6ct.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  if command -v firefox >/dev/null 2>&1; then
    cat "$SHELL_DIR/matugen/configs/firefox.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  if command -v pywalfox >/dev/null 2>&1; then
    cat "$SHELL_DIR/matugen/configs/pywalfox.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  if command -v vesktop >/dev/null 2>&1 && [[ -d "$CONFIG_DIR/vesktop" ]]; then
    cat "$SHELL_DIR/matugen/configs/vesktop.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  if [[ "$run_user_templates" == "true" ]] && [[ -f "$CONFIG_DIR/matugen/config.toml" ]]; then
    awk '/^\[templates/{p=1} p' "$CONFIG_DIR/matugen/config.toml" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  fi

  for config in "$USER_MATUGEN_DIR/configs"/*.toml; do
    [[ -f "$config" ]] || continue
    cat "$config" >> "$TMP_CFG"
    echo "" >> "$TMP_CFG"
  done
  
  # Handle surface shifting if needed
  if [[ "$surface_base" == "s" ]]; then
    TMP_TEMPLATES_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_TEMPLATES_DIR"' RETURN

    # Create shifted versions of templates
    for template in "$SHELL_DIR/matugen/templates"/*.{css,conf,json,kdl,colors} \
                    "$USER_MATUGEN_DIR/templates"/*.{css,conf,json,kdl,colors,toml}; do
      [[ -f "$template" ]] || continue
      template_name="$(basename "$template")"
      shifted_template="$TMP_TEMPLATES_DIR/$template_name"

      # Apply surface shifting transformations
      sed -e 's/{{colors\.surface\.default\.hex}}/{{colors.background.default.hex}}/g' \
          -e 's/{{colors\.surface_container\.default\.hex}}/{{colors.surface.default.hex}}/g' \
          -e 's/{{colors\.surface_container_high\.default\.hex}}/{{colors.surface_container.default.hex}}/g' \
          -e 's/{{colors\.surface_container_highest\.default\.hex}}/{{colors.surface_container_high.default.hex}}/g' \
          "$template" > "$shifted_template"
    done

    # Update config to use shifted templates
    sed -i "s|input_path = '$SHELL_DIR/matugen/templates/|input_path = '$TMP_TEMPLATES_DIR/|g" "$TMP_CFG"
    sed -i "s|input_path = '$USER_MATUGEN_DIR/templates/|input_path = '$TMP_TEMPLATES_DIR/|g" "$TMP_CFG"
    sed -i "s|input_path = '\\./matugen/templates/|input_path = '$TMP_TEMPLATES_DIR/|g" "$TMP_CFG"
  fi

  pushd "$SHELL_DIR" >/dev/null
  MAT_MODE=(-m "$mode")
  MAT_TYPE=(-t "$matugen_type")

  case "$kind" in
    image)
      [[ -f "$value" ]] || { echo "wallpaper not found: $value" >&2; popd >/dev/null; return 2; }
      JSON=$(matugen -c "$TMP_CFG" --json hex image "$value" "${MAT_MODE[@]}" "${MAT_TYPE[@]}")
      matugen -c "$TMP_CFG" image "$value" "${MAT_MODE[@]}" "${MAT_TYPE[@]}" >/dev/null
      ;;
    hex)
      [[ "$value" =~ ^#[0-9A-Fa-f]{6}$ ]] || { echo "invalid hex: $value" >&2; popd >/dev/null; return 2; }
      JSON=$(matugen -c "$TMP_CFG" --json hex color hex "$value" "${MAT_MODE[@]}" "${MAT_TYPE[@]}")
      matugen -c "$TMP_CFG" color hex "$value" "${MAT_MODE[@]}" "${MAT_TYPE[@]}" >/dev/null
      ;;
    *)
      echo "unknown kind: $kind" >&2; popd >/dev/null; return 2;;
  esac
  
  TMP_CONTENT_CFG="$(mktemp)"
  echo "[config]" > "$TMP_CONTENT_CFG"
  echo "" >> "$TMP_CONTENT_CFG"
  
  # Use shifted templates for content config if surface_base is "s"
  CONTENT_TEMPLATES_PATH="$SHELL_DIR/matugen/templates/"
  if [[ "$surface_base" == "s" && -n "${TMP_TEMPLATES_DIR:-}" ]]; then
    CONTENT_TEMPLATES_PATH="$TMP_TEMPLATES_DIR/"
  fi

  if command -v ghostty >/dev/null 2>&1; then
    cat "$SHELL_DIR/matugen/configs/ghostty.toml" >> "$TMP_CONTENT_CFG"
    sed -i "s|input_path = './matugen/templates/|input_path = '${CONTENT_TEMPLATES_PATH}|g" "$TMP_CONTENT_CFG"
    echo "" >> "$TMP_CONTENT_CFG"
  fi

  if command -v kitty >/dev/null 2>&1; then
    cat "$SHELL_DIR/matugen/configs/kitty.toml" >> "$TMP_CONTENT_CFG"
    sed -i "s|input_path = './matugen/templates/|input_path = '${CONTENT_TEMPLATES_PATH}|g" "$TMP_CONTENT_CFG"
    echo "" >> "$TMP_CONTENT_CFG"
  fi

  if command -v dgop >/dev/null 2>&1; then
    cat "$SHELL_DIR/matugen/configs/dgop.toml" >> "$TMP_CONTENT_CFG"
    sed -i "s|input_path = './matugen/templates/|input_path = '${CONTENT_TEMPLATES_PATH}|g" "$TMP_CONTENT_CFG"
    echo "" >> "$TMP_CONTENT_CFG"
  fi
  
  if [[ -s "$TMP_CONTENT_CFG" ]] && grep -q '\[templates\.' "$TMP_CONTENT_CFG"; then
    case "$kind" in
      image)
        matugen -c "$TMP_CONTENT_CFG" image "$value" "${MAT_MODE[@]}" "${MAT_TYPE[@]}" >/dev/null
        ;;
      hex)
        matugen -c "$TMP_CONTENT_CFG" color hex "$value" "${MAT_MODE[@]}" "${MAT_TYPE[@]}" >/dev/null
        ;;
    esac
  fi
  
  rm -f "$TMP_CONTENT_CFG"
  popd >/dev/null

  echo "$JSON" | grep -q '"primary"' || { echo "matugen JSON missing primary" >&2; set_system_color_scheme "$mode"; return 2; }
  printf "%s" "$JSON" > "$LAST_JSON"

  GTK_CSS="$CONFIG_DIR/gtk-3.0/gtk.css"
  SHOULD_RUN_HOOK=false

  if [[ -L "$GTK_CSS" ]]; then
    LINK_TARGET=$(readlink "$GTK_CSS")
    if [[ "$LINK_TARGET" == *"Shellit-colors.css"* ]]; then
      SHOULD_RUN_HOOK=true
    fi
  elif [[ -f "$GTK_CSS" ]] && grep -q "Shellit-colors.css" "$GTK_CSS"; then
    SHOULD_RUN_HOOK=true
  fi

  if [[ "$SHOULD_RUN_HOOK" == "true" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-${mode}" >/dev/null 2>&1 || true
  fi

  if [ "$mode" = "light" ]; then
    SECTION=$(echo "$JSON" | sed -n 's/.*"light":{\([^}]*\)}.*/\1/p')
  else
    SECTION=$(echo "$JSON" | sed -n 's/.*"dark":{\([^}]*\)}.*/\1/p')
  fi

  PRIMARY=$(echo "$SECTION" | sed -n 's/.*"primary_container":"\(#[0-9a-fA-F]\{6\}\)".*/\1/p')
  HONOR=$(echo "$SECTION"  | sed -n 's/.*"primary":"\(#[0-9a-fA-F]\{6\}\)".*/\1/p')
  SURFACE=$(echo "$SECTION" | sed -n 's/.*"surface":"\(#[0-9a-fA-F]\{6\}\)".*/\1/p')

  if command -v ghostty >/dev/null 2>&1 && [[ -f "$CONFIG_DIR/ghostty/config-Shellitcolors" ]]; then
    OUT=$("$SHELL_DIR/matugen/Shellit16.py" "$PRIMARY" $([[ "$mode" == "light" ]] && echo --light) ${HONOR:+--honor-primary "$HONOR"} ${SURFACE:+--background "$SURFACE"} 2>/dev/null || true)
    if [[ -n "${OUT:-}" ]]; then
      TMP="$(mktemp)"
      printf "%s\n\n" "$OUT" > "$TMP"
      cat "$CONFIG_DIR/ghostty/config-Shellitcolors" >> "$TMP"
      mv "$TMP" "$CONFIG_DIR/ghostty/config-Shellitcolors"
      if [[ -f "$CONFIG_DIR/ghostty/config" ]] && grep -q "^[^#]*config-Shellitcolors" "$CONFIG_DIR/ghostty/config" 2>/dev/null; then
        pkill -USR2 -x 'ghostty|.ghostty-wrappe' >/dev/null 2>&1 || true
      fi
    fi
  fi

  if command -v kitty >/dev/null 2>&1 && [[ -f "$CONFIG_DIR/kitty/Shellit-theme.conf" ]]; then
    OUT=$("$SHELL_DIR/matugen/Shellit16.py" "$PRIMARY" $([[ "$mode" == "light" ]] && echo --light) ${HONOR:+--honor-primary "$HONOR"} ${SURFACE:+--background "$SURFACE"} --kitty 2>/dev/null || true)
    if [[ -n "${OUT:-}" ]]; then
      TMP="$(mktemp)"
      printf "%s\n\n" "$OUT" > "$TMP"
      cat "$CONFIG_DIR/kitty/Shellit-theme.conf" >> "$TMP"
      mv "$TMP" "$CONFIG_DIR/kitty/Shellit-theme.conf"
    fi
  fi

  set_system_color_scheme "$mode"
}

if command -v pywalfox >/dev/null 2>&1 && [[ -f "$HOME/.cache/wal/colors.json" ]]; then
  pywalfox update >/dev/null 2>&1 || true
fi

while :; do
  DESIRED="$(read_desired)"
  WANT_KEY="$(key_of "$DESIRED")"
  HAVE_KEY=""
  [[ -f "$BUILT_KEY" ]] && HAVE_KEY="$(cat "$BUILT_KEY" 2>/dev/null || true)"

  if [[ "$WANT_KEY" == "$HAVE_KEY" ]]; then
    exit 0
  fi

  if build_once "$DESIRED"; then
    echo "$WANT_KEY" > "$BUILT_KEY"
  else
    exit 2
  fi
done

exit 0
