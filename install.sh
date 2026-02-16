#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${REPO_DIR}/src"
SASS_DIR="${SRC_DIR}/sass"

THEME_NAME="Abyssal"
SASSC_OPT="-M -t expanded"

PALETTES=(
  dark
  nord
  everforest
  gruvbox
  tokyonight
  dracula
  catppuccin-frappe
  catppuccin-latte
  catppuccin-macchiato
  catppuccin-mocha
)

if [[ "$EUID" -eq 0 ]]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
fi

ensure_sassc() {
  if ! command -v sassc >/dev/null; then
    echo "sassc is required."
    exit 1
  fi
}

install_index() {
  local theme_dir="$1"
  local theme_fullname="$2"

  cat > "${theme_dir}/index.theme" <<EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=${theme_fullname}
Comment=Abyssal GTK Theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=${theme_fullname}
IconTheme=Papirus-Dark
CursorTheme=Bibata-Modern-Ice
ButtonLayout=close,minimize,maximize:menu
EOF
}

compile_palette() {
  local palette="$1"
  local theme_fullname="${THEME_NAME}-${palette}"
  local theme_dir="${DEST_DIR}/${theme_fullname}"

  echo "Building ${theme_fullname}..."

  # Inject palette
  echo "@import \"../palettes/${palette}\";" > "${SASS_DIR}/_palette.scss"

  rm -rf "${theme_dir}"
  mkdir -p "${theme_dir}/gtk-3.0"
  mkdir -p "${theme_dir}/gtk-4.0"
  mkdir -p "${theme_dir}/gnome-shell"

  # GTK 3
  sassc $SASSC_OPT \
    "${SRC_DIR}/main/gtk-3.0/gtk.scss" \
    "${theme_dir}/gtk-3.0/gtk.css"

  # GTK 4
  sassc $SASSC_OPT \
    "${SRC_DIR}/main/gtk-4.0/gtk.scss" \
    "${theme_dir}/gtk-4.0/gtk.css"

  # GNOME Shell
  sassc $SASSC_OPT \
    "${SRC_DIR}/main/gnome-shell/gnome-shell.scss" \
    "${theme_dir}/gnome-shell/gnome-shell.css"

  # Assets
  cp -r "${SRC_DIR}/assets/gtk/assets" "${theme_dir}/gtk-3.0/" 2>/dev/null || true
  cp -r "${SRC_DIR}/assets/gtk/assets" "${theme_dir}/gtk-4.0/" 2>/dev/null || true

  install_index "${theme_dir}" "${theme_fullname}"
}

main() {
  ensure_sassc
  mkdir -p "${DEST_DIR}"

  for palette in "${PALETTES[@]}"; do
    compile_palette "${palette}"
  done

  echo
  echo "All palettes installed successfully."
}

main
