# Abyssal GTK Theme

A sophisticated, minimalist dark GTK theme built with the Abyssal color palette. Designed for modern Linux desktops with support for GTK 2, GTK 3, GTK 4, and Libadwaita.

## Features

- **Abyssal Color Palette**: Deep blues (#448FFF), soft pinks (#F38BA8), teal accents (#8BD5CA), and warm yellows (#FFD16D)
- **Dark-Only Design**: Optimized single dark theme for consistency and performance
- **Full GTK Support**: GTK 2.0, GTK 3, GTK 4, and Libadwaita compatible
- **Clean Modern Aesthetic**: Minimal, elegant design focused on usability

## Requirements

- GTK `>=3.20`
- `sassc` — build dependency (required for compiling SCSS)
- Murrine engine for GTK 2 support:
  - `gtk-engine-murrine` on Arch Linux
  - `gtk-murrine-engine` on Fedora
  - `gtk2-engine-murrine` on openSUSE
  - `gtk2-engines-murrine` on Debian, Ubuntu, etc.

## Installation

### Quick Start

Simply run the install script:

```bash
./install.sh
```

The theme will be installed to `~/.local/share/themes/Abyssal`

### Installation Options

```bash
./install.sh
```

### Arch Linux (AUR)

Arch Linux users can install the theme directly from the AUR:

Using `yay`:
```bash
yay -S abyssal-gtk-theme
```

## Building from Source

To rebuild the CSS from SCSS:

```bash
./build.sh
```

Requires `sassc` to be installed.

## Color Palette

Abyssal uses a carefully selected color scheme:

- **Primary Blue**: `#448FFF` - Main accent color
- **Pink**: `#F38BA8` - Secondary accent
- **Teal**: `#8BD5CA` - Tertiary accent  
- **Yellow**: `#FFD16D` - Warning/highlight
- **Dark Background**: `#061115` - Deep dark base

## Development

### Building

All required files are pre-compiled. To rebuild:

```bash
./build.sh         # Build CSS from SCSS
./install.sh       # Install the theme
```

### Project Structure

```
abyssal-gtk/
├── src/
│   ├── main/           # Compiled theme directories
│   │   ├── gtk-2.0/   # GTK 2 theme
│   │   ├── gtk-3.0/   # GTK 3 theme
│   │   ├── gtk-4.0/   # GTK 4 theme
│   │   └── libadwaita/ # Libadwaita (GNOME 42+)
│   ├── sass/          # SCSS source files
│   ├── assets/        # GTK assets
│   └── other/         # Additional themes (Firefox, etc.)
├── build.sh           # SCSS to CSS compiler
├── install.sh         # Theme installer
└── README.md          # This file
```

## License

GPL-3.0 or later

## Credits

Created as a customized dark theme focused on the Abyssal color palette for modern Linux desktop environments.
