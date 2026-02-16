#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${REPO_DIR}/src"

THEME_NAME="Abyssal"
SASSC_OPT="-M -t expanded"

if [[ "$EUID" -eq 0 ]]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
fi

usage() {
  echo "Usage: $0 [--dest DIR] [--name NAME] [--uninstall]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)
      DEST_DIR="$2"
      shift 2
      ;;
    --name)
      THEME_NAME="$2"
      shift 2
      ;;
    -u|--uninstall)
      UNINSTALL=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

THEME_DIR="${DEST_DIR}/${THEME_NAME}"

ensure_sassc() {
  if ! command -v sassc >/dev/null; then
    echo "sassc is required."
    exit 1
  fi
}

compile() {
  mkdir -p "${THEME_DIR}/gtk-3.0"
  mkdir -p "${THEME_DIR}/gtk-4.0"

  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk.scss" \
    "${THEME_DIR}/gtk-3.0/gtk.css"

  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk.scss" \
    "${THEME_DIR}/gtk-4.0/gtk.css"

  cp -r "${SRC_DIR}/assets/gtk/assets" "${THEME_DIR}/gtk-3.0/" 2>/dev/null || true
  cp -r "${SRC_DIR}/assets/gtk/assets" "${THEME_DIR}/gtk-4.0/" 2>/dev/null || true
}

install_index() {
  cat > "${THEME_DIR}/index.theme" <<EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=${THEME_NAME}
Comment=Abyssal GTK Theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=${THEME_NAME}
IconTheme=Papirus-Dark
CursorTheme=Bibata-Modern-Ice
ButtonLayout=close,minimize,maximize:menu
EOF
}

install_libadwaita_override() {
  mkdir -p "${HOME}/.config/gtk-4.0"

  rm -f "${HOME}/.config/gtk-4.0/gtk.css"
  rm -f "${HOME}/.config/gtk-4.0/gtk-dark.css"

  ln -sf "${THEME_DIR}/gtk-4.0/gtk.css" \
    "${HOME}/.config/gtk-4.0/gtk.css"

  ln -sf "${THEME_DIR}/gtk-4.0/gtk.css" \
    "${HOME}/.config/gtk-4.0/gtk-dark.css"
}

uninstall() {
  echo "Removing theme..."
  rm -rf "${THEME_DIR}"
  rm -f "${HOME}/.config/gtk-4.0/gtk.css"
  rm -f "${HOME}/.config/gtk-4.0/gtk-dark.css"
  echo "Done."
  exit 0
}

main() {
  if [[ "${UNINSTALL:-false}" == true ]]; then
    uninstall
  fi

  ensure_sassc

  mkdir -p "${DEST_DIR}"

  echo "Installing ${THEME_NAME} to ${DEST_DIR}..."
  rm -rf "${THEME_DIR}"
  mkdir -p "${THEME_DIR}"

  compile
  install_index
  install_libadwaita_override

  echo "Installation complete."
}

main
