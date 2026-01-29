make_assets() {
  local dest="${1}"
  local name="${2}"
  local theme="${3}"
  local color="${4}"
  local size="${5}"
  local scheme="${6}"
  local window="${7}"

  local THEME_DIR="${1}/${2}${3}${4}${5}${6}"

  # Abyssal Dark colors (hardcoded)
  theme_color_dark='#3a94c5'
  theme_color_light='#7fbbb3'
  background_light='#fdf6e3'
  background_dark='#2d353b'
  background_dark_alt='#343f44'
  titlebar_light='#f4f0d9'
  titlebar_dark='#272e33'

  # GTK 3/4 assets
  cp -r "${SRC_DIR}/assets/gtk/assets" "${THEME_DIR}/gtk-3.0"
  cp -r "${SRC_DIR}/assets/gtk/assets" "${THEME_DIR}/gtk-4.0"

  # Copy and process thumbnails if they exist
  if [[ -f "${SRC_DIR}/assets/gtk/thumbnail-Dark.svg" ]]; then
    cp -r "${SRC_DIR}/assets/gtk/thumbnail-Dark.svg" "${THEME_DIR}/gtk-3.0/thumbnail.png"
    cp -r "${SRC_DIR}/assets/gtk/thumbnail-Dark.svg" "${THEME_DIR}/gtk-4.0/thumbnail.png"
    
    # Dark thumbnails (Abyssal Dark only)
    [[ -f "${THEME_DIR}/gtk-3.0/thumbnail.png" ]] && sed -i "s/#2c2c2c/${background_dark}/g" "${THEME_DIR}/gtk-3.0/thumbnail.png"
    [[ -f "${THEME_DIR}/gtk-4.0/thumbnail.png" ]] && sed -i "s/#2c2c2c/${background_dark}/g" "${THEME_DIR}/gtk-4.0/thumbnail.png"
    [[ -f "${THEME_DIR}/gtk-3.0/thumbnail.png" ]] && sed -i "s/#5b9bf8/${theme_color_light}/g" "${THEME_DIR}/gtk-3.0/thumbnail.png"
    [[ -f "${THEME_DIR}/gtk-4.0/thumbnail.png" ]] && sed -i "s/#5b9bf8/${theme_color_light}/g" "${THEME_DIR}/gtk-4.0/thumbnail.png"
  fi

  # Replace colors in GTK SVG assets (hardcoded Abyssal Dark)
  sed -i "s/#5b9bf8/${theme_color_light}/g" "${THEME_DIR}/"{gtk-3.0,gtk-4.0}/assets/*'.svg'
  sed -i "s/#3c84f7/${theme_color_dark}/g" "${THEME_DIR}/"{gtk-3.0,gtk-4.0}/assets/*'.svg'
  sed -i "s/#ffffff/${background_light}/g" "${THEME_DIR}/"{gtk-3.0,gtk-4.0}/assets/*'.svg'
  sed -i "s/#2c2c2c/${background_dark}/g" "${THEME_DIR}/"{gtk-3.0,gtk-4.0}/assets/*'.svg'
  sed -i "s/#3c3c3c/${background_dark_alt}/g" "${THEME_DIR}/"{gtk-3.0,gtk-4.0}/assets/*'.svg'

  # GTK common and symbolic assets
  cp -r "${SRC_DIR}/assets/gtk/symbolics/"*'.svg' "${THEME_DIR}/gtk-3.0/assets"
  cp -r "${SRC_DIR}/assets/gtk/symbolics/"*'.svg' "${THEME_DIR}/gtk-4.0/assets"

  # GTK-2.0 assets
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets-common-Dark" "${THEME_DIR}/gtk-2.0/assets"
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets-Dark-Abyssal/"*"png" "${THEME_DIR}/gtk-2.0/assets"
}
