#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DESKTOP_DIR="$HOME/.local/share/applications"
APPS=("antigravity.desktop" "antigravityide.desktop")

echo -e "${BLUE}===============================================${NC}"
echo -e "       Antigravity Desktop Shortcut Auditor    "
echo -e "${BLUE}===============================================${NC}"

check_shortcut() {
    local file="$DESKTOP_DIR/$1"
    if [[ ! -f "$file" ]]; then
        echo -e "${YELLOW}[-] Shortcut not installed: $1${NC}"
        return
    fi

    echo -e "${GREEN}[+] Shortcut found: $file${NC}"
    
    # Parse desktop file keys
    local name=$(grep "^Name=" "$file" | cut -d'=' -f2-)
    local exec_val=$(grep "^Exec=" "$file" | cut -d'=' -f2-)
    local icon_val=$(grep "^Icon=" "$file" | cut -d'=' -f2-)
    local wm_class=$(grep "^StartupWMClass=" "$file" | cut -d'=' -f2-)

    echo "    Name:             $name"
    echo "    Exec command:     $exec_val"
    echo "    Icon path:        $icon_val"
    echo "    StartupWMClass:   $wm_class"

    # Extract binary path from Exec command (removing options like --no-sandbox)
    local bin_path=$(echo "$exec_val" | awk '{print $1}')
    if [[ -f "$bin_path" ]]; then
        echo -e "    Binary status:    ${GREEN}Valid${NC} ($bin_path)"
    else
        echo -e "    Binary status:    ${RED}Invalid / File not found!${NC} ($bin_path)"
    fi

    # Check Icon file
    if [[ "$icon_val" == /* ]]; then
        if [[ -f "$icon_val" ]]; then
            echo -e "    Icon status:      ${GREEN}Valid${NC} ($icon_val)"
        else
            echo -e "    Icon status:      ${RED}File not found!${NC} ($icon_val)"
        fi
    else
        echo -e "    Icon status:      System theme icon ($icon_val)"
    fi
}

for app in "${APPS[@]}"; do
    check_shortcut "$app"
    echo -e "-----------------------------------------------"
done

echo -e "${GREEN}[*] Updating desktop launcher database...${NC}"
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR"
    echo -e "${GREEN}[+] Desktop launcher database updated successfully.${NC}"
else
    echo -e "${YELLOW}[!] update-desktop-database not found. Skipping.${NC}"
fi

echo -e "${BLUE}===============================================${NC}"
