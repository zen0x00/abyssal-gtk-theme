make_gtkrc() {
  local dest="${1}"
  local name="${2}"
  local theme="${3}"
  local color="${4}"
  local size="${5}"
  local scheme="${6}"
  local window="${7}"

  local GTKRC_DIR="${SRC_DIR}/main/gtk-2.0"
  local THEME_DIR="${1}/${2}${3}${4}${5}${6}"

  # Abyssal Dark colors (hardcoded)
  theme_color_dark='#3a94c5'
  theme_color_light='#7fbbb3'
  background_light='#fdf6e3'
  background_dark='#2d353b'
  background_darker='#343f44'
  background_alt='#414b50'
  titlebar_light='#f4f0d9'
  titlebar_dark='#272e33'

  # Copy gtkrc file
  cp -r "${GTKRC_DIR}/gtkrc-Dark-default" "${THEME_DIR}/gtk-2.0/gtkrc"
  cp -r "${GTKRC_DIR}/common/"*'.rc' "${THEME_DIR}/gtk-2.0"

  # Replace color values in gtkrc file (Abyssal Dark)
  sed -i "s/#FFFFFF/${background_light}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
  sed -i "s/#2C2C2C/${background_dark}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
  sed -i "s/#464646/${background_alt}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
  sed -i "s/#5b9bf8/${theme_color_light}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
  sed -i "s/#3C3C3C/${background_darker}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
  sed -i "s/#242424/${titlebar_dark}/g" "${THEME_DIR}/gtk-2.0/gtkrc"
}
