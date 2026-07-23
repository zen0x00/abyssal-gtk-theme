{
  lib,
  stdenv,
  sassc,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "abyssal-gtk-theme";
  version = "unstable-2026-07-23";

  src = fetchFromGitHub {
    owner = "rxyenv";
    repo = "abyssal-gtk-theme";
    rev = "e76dde6";
    hash = "sha256-2TtheITjHE/XuUEfGt1B/hi/gHRnrmGwjRTl527DlD4=";
  };

  nativeBuildInputs = [ sassc ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    DEST_DIR="$out/share/themes"
    mkdir -p "$DEST_DIR"

    PALETTES=(
      black catppuccin default dracula everforest gruvbox nord tokyonight
    )

    SASSC_OPT="-M -t expanded"

    # src is read-only in Nix sandbox; copy to writable workdir
    WORK_DIR=$(mktemp -d)
    cp -r src "$WORK_DIR/src"
    SRC_DIR="$WORK_DIR/src"
    SASS_DIR="$SRC_DIR/sass"

    for palette in "''${PALETTES[@]}"; do
      palette_name="''${palette^}"
      theme_fullname="Abyssal-''${palette_name}"
      theme_dir="$DEST_DIR/''${theme_fullname}"

      echo "Building ''${theme_fullname}..."

      echo "@import \"../palettes/''${palette}\";" > "''${SASS_DIR}/_palette.scss"

      mkdir -p "''${theme_dir}/gtk-3.0"
      mkdir -p "''${theme_dir}/gtk-4.0"
      mkdir -p "''${theme_dir}/gnome-shell"

      sassc $SASSC_OPT \
        "''${SRC_DIR}/main/gtk-3.0/gtk.scss" \
        "''${theme_dir}/gtk-3.0/gtk.css"

      sassc $SASSC_OPT \
        "''${SRC_DIR}/main/gtk-4.0/gtk.scss" \
        "''${theme_dir}/gtk-4.0/gtk.css"

      sassc $SASSC_OPT \
        "''${SRC_DIR}/main/gnome-shell/gnome-shell.scss" \
        "''${theme_dir}/gnome-shell/gnome-shell.css"

      sassc $SASSC_OPT \
        "''${SRC_DIR}/main/libadwaita/libadwaita.scss" \
        "''${theme_dir}/gtk-4.0/libadwaita.css"

      if [ -d "''${SRC_DIR}/assets/gtk/assets" ]; then
        cp -r "''${SRC_DIR}/assets/gtk/assets" "''${theme_dir}/gtk-3.0/"
        cp -r "''${SRC_DIR}/assets/gtk/assets" "''${theme_dir}/gtk-4.0/"
      fi

      cat > "''${theme_dir}/index.theme" <<EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=''${theme_fullname}
Comment=Abyssal GTK Theme
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=''${theme_fullname}
IconTheme=Papirus-Dark
CursorTheme=Bibata-Modern-Ice
ButtonLayout=close,minimize,maximize:menu
EOF
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Dark GTK theme with multiple palette variants including libadwaita support";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
