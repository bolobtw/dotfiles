# Dotfiles

A minimal and keyboard driven environment. 

![Soon to come..](screenshot.png) <!-- Gonna Place the screenshot here once im finished -->

## Pkgs

This setup relies on the following:

*   **OS:** Arch
*   **Window Manager:** Sway (Wayland)
*   **Terminal:** Foot
*   **Status Bar:** Waybar
*   **Launcher:** Fuzzel
*   **Browser:** LibreWolf
*   **Code:** Vis
*   **Files:** Yazi
*   **Music:** Cliamp
*   **Audio:** Wiremix
*   **Network:** Wlctl

## Structure

```text
dotfiles/
├── colors.toml     # Theme color reference
├── config          # Fastfetch configuration
├── config.jsonc    # Waybar layout and modules
├── style.css       # Waybar CSS styling
└── foot.ini        # Foot terminal configuration
```

## Installation

To use these configurations, clone this repository and symlink (or copy) the files to your local `~/.config` directory. 

```bash
# Clone the repository
git clone https://github.com/bolobtw/dotfiles.git ~/dotfiles

# Example of copying files to their respective config folders
mkdir -p ~/.config/waybar ~/.config/foot ~/.config/fastfetch

cp ~/dotfiles/config.jsonc ~/.config/waybar/
cp ~/dotfiles/style.css ~/.config/waybar/
cp ~/dotfiles/foot.ini ~/.config/foot/
cp ~/dotfiles/config ~/.config/fastfetch/
```
