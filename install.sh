#!/usr/bin/env bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAVED_LW_PATH_FILE="$HOME/.config/dotfiles_lw_profile"

echo "========================================="
echo "       Dotfiles Theme Switcher"
echo "========================================="
echo "1) kyanite (Swaybar + Wmenu + Desert Night)"
echo "2) gruvbox (Waybar + Fuzzel + Gruvbox Dark)"
echo "-----------------------------------------"
read -rp "Select which theme to apply [1/2]: " choice

case "$choice" in
    1) THEME="kyanite" ;;
    2) THEME="gruvbox" ;;
    *) echo "Invalid selection. Exiting."; exit 1 ;;
esac

echo ""
echo "-> Applying '$THEME' configs..."
mkdir -p ~/.config/sway ~/.config/foot ~/.config/fastfetch

rm -f ~/.config/sway/status.sh
cp -r "$REPO_DIR/$THEME/sway/"* ~/.config/sway/
cp "$REPO_DIR/$THEME/foot/foot.ini" ~/.config/foot/
cp "$REPO_DIR/$THEME/fastfetch/config.jsonc" ~/.config/fastfetch/

if [ "$THEME" = "kyanite" ]; then
    chmod +x ~/.config/sway/status.sh
elif [ "$THEME" = "gruvbox" ]; then
    echo "-> Copying Waybar and Fuzzel configs..."
    mkdir -p ~/.config/waybar ~/.config/fuzzel
    cp -r "$REPO_DIR/gruvbox/waybar/"* ~/.config/waybar/
    cp "$REPO_DIR/gruvbox/fuzzel/fuzzel.ini" ~/.config/fuzzel/
fi

# VSCodium
echo ""
read -rp "Apply VSCodium theme? [y/N]: " vsc_choice
if [[ "$vsc_choice" =~ ^[Yy]$ ]]; then
    mkdir -p ~/.config/VSCodium/User
    cp "$REPO_DIR/$THEME/vsc/settings.json" ~/.config/VSCodium/User/settings.json
    echo "-> VSCodium settings updated in ~/.config/VSCodium/User/settings.json"
fi

# LibreWolf (Saves path after first run)
echo ""
read -rp "Apply LibreWolf & Sidebery CSS themes? [y/N]: " lw_choice
if [[ "$lw_choice" =~ ^[Yy]$ ]]; then
    SAVED_PROF=""
    if [ -f "$SAVED_LW_PATH_FILE" ]; then
        read -r SAVED_PROF < "$SAVED_LW_PATH_FILE"
    fi

    if [ -n "$SAVED_PROF" ] && [ -d "$SAVED_PROF" ]; then
        echo "Saved LibreWolf profile: $SAVED_PROF"
        read -rp "Press Enter to use saved path, or enter a new path: " input_prof
        PROF_PATH="${input_prof:-$SAVED_PROF}"
    else
        read -rp "Enter full path to your LibreWolf profile folder (e.g. ~/.librewolf/xxxx.default-release): " PROF_PATH
    fi

    if [ -d "$PROF_PATH" ]; then
        mkdir -p ~/.config
        echo "$PROF_PATH" > "$SAVED_LW_PATH_FILE"

        mkdir -p "$PROF_PATH/chrome"
        for dir in librewolf browser; do
            if [ -d "$REPO_DIR/$THEME/$dir" ]; then
                cp -f "$REPO_DIR/$THEME/$dir/"*.css "$PROF_PATH/chrome/" 2>/dev/null || true
            fi
        done

        touch "$PROF_PATH/user.js"
        for pref in \
            'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' \
            'user_pref("svg.context-properties.content.enabled", true);' \
            'user_pref("extensions.webextensions.RestrictedDomains", "");' \
            'user_pref("privacy.resistFingerprinting.block_mozAddonManager", true);'
        do
            pref_name=$(echo "$pref" | cut -d'"' -f2)
            if ! grep -q "$pref_name" "$PROF_PATH/user.js" 2>/dev/null; then
                echo "$pref" >> "$PROF_PATH/user.js"
            fi
        done
        echo "-> Installed CSS & preferences to: $PROF_PATH/chrome/ (Path saved for next time)"
    else
        echo "-> Error: Directory '$PROF_PATH' not found. Skipping browser theme."
    fi
fi

# Cleanly swap bar processes and reload Sway
if pgrep -x "sway" >/dev/null; then
    echo ""
    echo "-> Reloading Sway and restarting status bar..."
    if [ "$THEME" = "kyanite" ]; then
        pkill -x waybar 2>/dev/null || true
        pkill -x swaybar 2>/dev/null || true
        pkill -f "sway/status.sh" 2>/dev/null || true
        swaymsg reload >/dev/null 2>&1 || true
    elif [ "$THEME" = "gruvbox" ]; then
        pkill -x swaybar 2>/dev/null || true
        pkill -f "sway/status.sh" 2>/dev/null || true
        pkill -x waybar 2>/dev/null || true
        swaymsg reload >/dev/null 2>&1 || true
        sleep 2
        if ! pgrep -x "waybar" >/dev/null; then
            nohup waybar >/dev/null 2>&1 &
        fi
    fi
fi

echo ""
echo "Done! '$THEME' is now active. (Librewolf will need to be restarted)"