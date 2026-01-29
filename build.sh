#! /usr/bin/env bash

# Check command availability
function has_command() {
  command -v $1 > /dev/null
}

if [ ! "$(which sassc 2> /dev/null)" ]; then
  echo sassc needs to be installed to generate the css.
  if has_command zypper; then
    sudo zypper in sassc
  elif has_command apt; then
    sudo apt install -y sassc
  elif has_command dnf; then
    sudo dnf install -y sassc
  elif has_command yum; then
    sudo yum install -y sassc
  elif has_command pacman; then
    sudo pacman -S --noconfirm sassc
  elif has_command xbps-install; then
    sudo xbps-install -y sassc
  fi
fi

SASSC_OPT="-M -t expanded"

# Dark-only theme - only compile base files without color variants
cp -rf src/sass/_tweaks.scss src/sass/_tweaks-temp.scss

# Compile Abyssal Dark theme files
echo "==> Generating the 3.0 gtk.css..."
sassc $SASSC_OPT src/main/gtk-3.0/gtk.{scss,css}

echo "==> Generating the 4.0 gtk.css..."
sassc $SASSC_OPT src/main/gtk-4.0/gtk.{scss,css}

echo "==> Generating the libadwaita libadwaita.css..."
sassc $SASSC_OPT src/main/libadwaita/libadwaita.{scss,css}
