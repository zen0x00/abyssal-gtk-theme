# Abyssal GTK Theme

A dark GTK theme with 12 palette variants. Supports GTK 3, GTK 4, GNOME Shell, and Libadwaita.

## Palettes

| Palette | Description |
|---|---|
| `black` | Pure black base |
| `dark` | Deep dark blue-grey |
| `default` | Default Abyssal palette |
| `catppuccin` | Catppuccin Mocha |
| `catppuccin-latte` | Catppuccin Latte (light) |
| `dracula` | Dracula |
| `e-ink` | High contrast greyscale |
| `everforest` | Everforest dark |
| `glass` | Translucent glass effect |
| `gruvbox` | Gruvbox dark |
| `nord` | Nord |
| `tokyonight` | Tokyo Night |

## Installation

### NixOS / nix-darwin

```nix
# flake.nix
inputs.abyssal-gtk-theme.url = "github:rxyenv/abyssal-gtk-theme";

# home-manager config
{ inputs, pkgs, ... }:
let
  abyssal = inputs.abyssal-gtk-theme.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  gtk.enable = true;
  gtk.theme = {
    name = "Abyssal-Catppuccin";
    package = abyssal;
  };
}
```

### Script

Requires `sassc`.

```bash
./install.sh          # all palettes → ~/.local/share/themes/
./install.sh -l       # also compile libadwaita.css per palette
```

Run as root to install system-wide to `/usr/share/themes/`.

### Libadwaita

Libadwaita ignores `GTK_THEME`. After installing with `-l`, add to `~/.config/gtk-4.0/gtk.css`:

```css
@import "/path/to/.local/share/themes/Abyssal-Catppuccin/gtk-4.0/libadwaita.css";
```

## Requirements

- `sassc` — SCSS compiler
- GTK >= 3.20
- GTK 2: `gtk-engine-murrine` (Arch: `gtk-engine-murrine`, Debian/Ubuntu: `gtk2-engines-murrine`, Fedora: `gtk-murrine-engine`)

## Building

```bash
./build.sh   # compile SCSS → CSS in-place (development only)
```

## Project Structure

```
src/
├── palettes/        # per-palette SCSS variable files
├── sass/            # shared SCSS (variables, mixins, components)
├── main/
│   ├── gtk-3.0/
│   ├── gtk-4.0/
│   ├── gnome-shell/
│   ├── libadwaita/
│   └── gtk-2.0/
└── assets/          # GTK button/icon assets
default.nix          # Nix derivation (nixpkgs-compatible)
flake.nix            # Nix flake
install.sh           # installer script
```

## License

GPL-3.0-or-later
