#! /usr/bin/env bash

set -Eeo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="${REPO_DIR}/src"

source "${REPO_DIR}/gtkrc.sh"
source "${REPO_DIR}/assets.sh"

ROOT_UID=0
DEST_DIR=

scheme=
window=

# Destination directory
if [[ "$UID" -eq "$ROOT_UID" ]]; then
  DEST_DIR="/usr/share/themes"
elif [[ -n "$XDG_DATA_HOME" ]]; then
  DEST_DIR="$XDG_DATA_HOME/themes"
elif [[ -d "$HOME/.themes" ]]; then
  DEST_DIR="$HOME/.themes"
elif [[ -d "$HOME/.local/share/themes" ]]; then
  DEST_DIR="$HOME/.local/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SASSC_OPT="-M -t expanded"

THEME_NAME=Abyssal
THEME_VARIANTS=('')
SCHEME_VARIANTS=('')
COLOR_VARIANTS=('')
SIZE_VARIANTS=('')

usage() {
cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)

  -n, --name NAME         Specify theme name (Default: $THEME_NAME)

  -l, --libadwaita        Install gtk-4.0 theme into config folder ($HOME/.config/gtk-4.0) for all gtk4 apps

  -r, --remove,
  -u, --uninstall         Uninstall/Remove installed themes or links

  -h, --help              Show help
EOF
}


install() {
  local dest="${1}"
  local name="${2}"
  local theme="${3}"
  local color="${4}"
  local size="${5}"
  local scheme="${6}"
  local window="${7}"

  [[ "${color}" == '-Light' ]] && local ELSE_LIGHT="${color}"
  [[ "${color}" == '-Dark' ]] && local ELSE_DARK="${color}"

  local THEME_DIR="${1}/${2}${3}${4}${5}${6}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"{'','-hdpi','-xhdpi'}

  echo "Installing '${THEME_DIR}'..."

  theme_tweaks

  mkdir -p                                                                                   "${THEME_DIR}"

  echo "[Desktop Entry]" >>                                                                  "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                                           "${THEME_DIR}/index.theme"
  echo "Name=${2}${3}${4}${5}${6}" >>                                                        "${THEME_DIR}/index.theme"
  echo "Comment=An Flat Gtk+ theme based on Elegant Design" >>                               "${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                                   "${THEME_DIR}/index.theme"
  echo "" >>                                                                                 "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                              "${THEME_DIR}/index.theme"
  echo "GtkTheme=${2}${3}${4}${5}${6}" >>                                                    "${THEME_DIR}/index.theme"
  echo "IconTheme=Abyssal${3}${6}${4}" >>                                                    "${THEME_DIR}/index.theme"
  echo "CursorTheme=${2}-cursors" >>                                                         "${THEME_DIR}/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                        "${THEME_DIR}/index.theme"

  mkdir -p                                                                                   "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/main/gtk-2.0/common/"*'.rc'                                              "${THEME_DIR}/gtk-2.0"

  mkdir -p                                                                                   "${THEME_DIR}/gtk-3.0"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk.scss"                                         "${THEME_DIR}/gtk-3.0/gtk.css"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-3.0/gtk.scss"                                         "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  mkdir -p                                                                                   "${THEME_DIR}/gtk-4.0"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk.scss"                                         "${THEME_DIR}/gtk-4.0/gtk.css"
  sassc $SASSC_OPT "${SRC_DIR}/main/gtk-4.0/gtk.scss"                                         "${THEME_DIR}/gtk-4.0/gtk-dark.css"

  mkdir -p                                                                                   "${THEME_DIR}/libadwaita"
  sassc $SASSC_OPT "${SRC_DIR}/main/libadwaita/libadwaita.scss"                               "${THEME_DIR}/libadwaita/libadwaita.css"
}

themes=()
colors=()
sizes=()
lcolors=()
schemes=()

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo -e "\nDestination directory does not exist. Let's make a new one..."
        mkdir -p ${dest}
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -r|--remove|-u|--uninstall)
      uninstall="true"
      shift
      ;;
    -l|--libadwaita)
      libadwaita="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo -e "\nERROR: Unrecognized installation option '$1'."
      echo -e "\nTry '$0 --help' for more information."
      exit 1
      ;;
  esac
done

# Set hardcoded variants for Abyssal Dark theme
themes=("${THEME_VARIANTS[@]}")
colors=("${COLOR_VARIANTS[@]}")
lcolors=("${COLOR_VARIANTS[@]}")
sizes=("${SIZE_VARIANTS[@]}")
schemes=("${SCHEME_VARIANTS[@]}")

# Enable Abyssal color scheme by default
colorscheme='true'
echo -e "\nInstalling Abyssal Dark theme..."

#  Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

#  Install needed packages
install_package() {
  if ! has_command sassc; then
    echo sassc needs to be installed to generate the css.
    if has_command zypper; then
      sudo zypper in sassc
    elif has_command apt; then
      sudo apt install sassc
    elif has_command apt-get; then
      sudo apt-get install sassc
    elif has_command dnf; then
      sudo dnf install sassc
    elif has_command yum; then
      sudo yum install sassc
    elif has_command pacman; then
      sudo pacman -S --noconfirm sassc
    elif has_command xbps-install; then
      sudo xbps-install -y sassc
    fi
  fi
}

tweaks_temp() {
  cp -rf "${SRC_DIR}/sass/_tweaks.scss" "${SRC_DIR}/sass/_tweaks-temp.scss"
}

compact_size() {
  sed -i "/\$compact:/s/false/true/" "${SRC_DIR}/sass/_tweaks-temp.scss"
}

color_schemes() {
  if [[ "$scheme" != '' ]]; then
    case "$scheme" in
      -Nord)
        scheme_color='nord'
        ;;
      -Dracula)
        scheme_color='dracula'
        ;;
      -Gruvbox)
        scheme_color='gruvbox'
        ;;
      -Dark)
        scheme_color='abyssal'
        ;;
      -Catppuccin)
        scheme_color='catppuccin'
        ;;
    esac
    sed -i "/\@import/s/color-palette-default/color-palette-${scheme_color}/" "${SRC_DIR}/sass/_tweaks-temp.scss"
    sed -i "/\$colorscheme:/s/default/${scheme_color}/" "${SRC_DIR}/sass/_tweaks-temp.scss"
  fi
}

color_type() {
  sed -i "/\$colortype:/s/system/fixed/" "${SRC_DIR}/sass/_tweaks-temp.scss"
}

blackness_color() {
  sed -i "/\$blackness:/s/false/true/" "${SRC_DIR}/sass/_tweaks-temp.scss"
}

border_rimless() {
  sed -i "/\$rimless:/s/false/true/" "${SRC_DIR}/sass/_tweaks-temp.scss"
}

normal_winbutton() {
  sed -i "/\$window_button:/s/mac/normal/" "${SRC_DIR}/sass/_tweaks-temp.scss"
}

float_panel() {
  sed -i "/\$float:/s/false/true/" "${SRC_DIR}/sass/_tweaks-temp.scss"
}

theme_color() {
  if [[ "$theme" != '' ]]; then
    case "$theme" in
      -Purple)
        theme_color='purple'
        ;;
      -Pink)
        theme_color='pink'
        ;;
      -Red)
        theme_color='red'
        ;;
      -Orange)
        theme_color='orange'
        ;;
      -Yellow)
        theme_color='yellow'
        ;;
      -Green)
        theme_color='green'
        ;;
      -Teal)
        theme_color='teal'
        ;;
      -Grey)
        theme_color='grey'
        ;;
    esac
    sed -i "/\$theme:/s/default/${theme_color}/" "${SRC_DIR}/sass/_tweaks-temp.scss"
  fi
}

theme_tweaks() {
  tweaks_temp
  color_schemes
}

uninstall_libadwaita() {
  rm -rf "${HOME}/.config/gtk-4.0/"{assets,windows-assets,gtk.css,gtk-dark.css,gtk-Light.css,gtk-Dark.css}
}

link_libadwaita() {
  local dest="${1}"
  local name="${2}"
  local theme="${3}"
  local color="${4}"
  local size="${5}"
  local scheme="${6}"

  local THEME_DIR="${1}/${2}${3}${4}${5}${6}"

  rm -rf "${HOME}/.config/gtk-4.0/"{assets,gtk.css,gtk-dark.css}

  echo -e "\nLink '${THEME_DIR}/gtk-4.0' to '${HOME}/.config/gtk-4.0' for libadwaita...\n"

  mkdir -p                                                                      "${HOME}/.config/gtk-4.0"
  ln -sf "${THEME_DIR}/gtk-4.0/assets"                                          "${HOME}/.config/gtk-4.0/assets"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk.css"                                         "${HOME}/.config/gtk-4.0/gtk.css"
  ln -sf "${THEME_DIR}/gtk-4.0/gtk-dark.css"                                    "${HOME}/.config/gtk-4.0/gtk-dark.css"
}

libadwaita_theme() {
  local dest="${1}"
  local name="${2}"
  local theme="${3}"
  local color="${4}"
  local size="${5}"
  local scheme="${6}"

  theme_tweaks

  rm -rf "${HOME}/.config/gtk-4.0/"{assets,gtk.css,gtk-dark.css}

  echo -e "\nInstalling ${2}${3}${4}${5}${6} theme into '${HOME}/.config/gtk-4.0' for libadwaita..."

  mkdir -p                                                                      "${HOME}/.config/gtk-4.0"
  cp -r "${SRC_DIR}/assets/gtk/assets"                                          "${HOME}/.config/gtk-4.0"
  cp -r "${SRC_DIR}/assets/gtk/symbolics/"*'.svg'                               "${HOME}/.config/gtk-4.0/assets"

  sassc $SASSC_OPT "${SRC_DIR}/main/libadwaita/libadwaita.scss"                 "${HOME}/.config/gtk-4.0/gtk.css"
}

link_theme() {
  for theme in "${themes[@]}"; do
    for color in "${lcolors[@]}"; do
      for size in "${sizes[@]}"; do
        for scheme in "${schemes[@]}"; do
          link_libadwaita "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$scheme"
        done
      done
    done
  done
}

install_libadwaita() {
  for theme in "${themes[@]}"; do
    for color in "${lcolors[@]}"; do
      for size in "${sizes[@]}"; do
        for scheme in "${schemes[@]}"; do
          libadwaita_theme "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$scheme"
        done
      done
    done
  done
}

install_theme() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      for size in "${sizes[@]}"; do
        for scheme in "${schemes[@]}"; do
          install "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$scheme" "$window"
          make_gtkrc "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$scheme" "$window"
          make_assets "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$scheme" "$window"
        done
      done
    done
  done

  if (command -v xfce4-popup-whiskermenu &> /dev/null) && $(sed -i "s|.*menu-opacity=.*|menu-opacity=95|" "$HOME/.config/xfce4/panel/whiskermenu"*".rc" &> /dev/null); then
    sed -i "s|.*menu-opacity=.*|menu-opacity=95|" "$HOME/.config/xfce4/panel/whiskermenu"*".rc"
  fi

  if (pgrep xfce4-session &> /dev/null); then
    xfce4-panel -r
  fi
}

uninstall() {
  local dest="${1}"
  local name="${2}"
  local theme="${3}"
  local color="${4}"
  local size="${5}"
  local scheme="${6}"

  local THEME_DIR="${1}/${2}${3}${4}${5}${6}"

  if [[ "$uninstall" == 'true' ]]; then
    type='Uninstall'
  else
    type='Clean'
  fi

  if [[ -d "${THEME_DIR}" ]]; then
    echo -e "${type} ${THEME_DIR}... "
    rm -rf "${THEME_DIR}"{'','-hdpi','-xhdpi'}
  fi
}

uninstall_theme() {
  for theme in "${THEME_VARIANTS[@]}"; do
    for color in "${COLOR_VARIANTS[@]}"; do
      for size in "${SIZE_VARIANTS[@]}"; do
        for scheme in "${SCHEME_VARIANTS[@]}"; do
          uninstall "${dest:-$DEST_DIR}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$scheme"
        done
      done
    done
  done
}

clean_theme() {
  if [[ "$UID" != "$ROOT_UID" ]]; then
    if [[ "$DEST_DIR" == "$HOME/.themes" ]]; then
      local dest="$HOME/.local/share/themes"
    elif [[ "$DEST_DIR" == "$XDG_DATA_HOME/themes" || "$DEST_DIR" == "$HOME/.local/share/themes" ]]; then
      local dest="$HOME/.themes"
    fi

    for theme in "${themes[@]}"; do
      for color in "${colors[@]}"; do
        for size in "${sizes[@]}"; do
          for scheme in "${schemes[@]}"; do
            uninstall "${dest}" "${name:-$THEME_NAME}" "$theme" "$color" "$size" "$scheme"
          done
        done
      done
    done
  fi
}

if [[ "$uninstall" == 'true' ]]; then
  if [[ "$libadwaita" == 'true' ]]; then
    echo -e "\nUninstall libadwaita theme from ${HOME}/.config/gtk-4.0 ..."
    uninstall_libadwaita
  else
    echo && uninstall_theme && uninstall_libadwaita
  fi
else
  install_package && tweaks_temp
  echo && clean_theme && install_theme

  if [[ "$libadwaita" == 'true' ]]; then
    uninstall_libadwaita && install_libadwaita
  fi
fi

echo
echo Done.
