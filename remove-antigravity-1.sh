#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}         Antigravity 1.0 Removal Tool          ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Function to show usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -d, --dir <path>       Specify the installation directory to remove (default: /opt/antigravity)"
    echo "  -p, --purge            Also remove user configuration and extensions (~/.config/Antigravity and ~/.antigravity)"
    echo "  -h, --help             Show this help message"
    exit ${1:-1}
}

# Parse options
INSTALL_DIR="/opt/antigravity"
PURGE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -p|--purge)
            PURGE=true
            shift
            ;;
        -h|--help)
            usage 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'.${NC}"
            usage
            ;;
    esac
done

# 1. Remove binary/installation directory
if [[ -d "$INSTALL_DIR" ]]; then
    # Verify if it looks like an Antigravity installation
    # (Checking for binary 'antigravity' or 'Antigravity' or folder structure)
    if [[ -f "$INSTALL_DIR/antigravity" || -f "$INSTALL_DIR/Antigravity" || -f "$INSTALL_DIR/chrome-sandbox" ]]; then
        echo -e "${GREEN}[*] Found Antigravity installation at: $INSTALL_DIR${NC}"
        echo -e "${GREEN}[*] Removing directory...${NC}"
        if [[ "$INSTALL_DIR" == /opt/* ]]; then
            echo -e "${YELLOW}[!] Directory is in /opt, requesting sudo privileges...${NC}"
            sudo rm -rf "$INSTALL_DIR"
        else
            rm -rf "$INSTALL_DIR"
        fi
        echo -e "${GREEN}[+] Successfully removed installation directory.${NC}"
    else
        echo -e "${YELLOW}[!] Warning: Directory '$INSTALL_DIR' exists but does not seem to contain an Antigravity installation.${NC}"
        read -p "Are you sure you want to delete it? (y/N): " confirm
        if [[ "$confirm" =~ ^[yY]$ ]]; then
            if [[ "$INSTALL_DIR" == /opt/* ]]; then
                sudo rm -rf "$INSTALL_DIR"
            else
                rm -rf "$INSTALL_DIR"
            fi
            echo -e "${GREEN}[+] Successfully removed directory.${NC}"
        else
            echo -e "${YELLOW}[-] Directory removal skipped.${NC}"
        fi
    fi
else
    echo -e "${YELLOW}[-] No installation directory found at '$INSTALL_DIR'. Skipping.${NC}"
fi

# 2. Remove standard desktop application launcher shortcut
DESKTOP_FILE="$HOME/.local/share/applications/antigravity.desktop"
if [[ -f "$DESKTOP_FILE" ]]; then
    echo -e "${GREEN}[*] Removing desktop launcher shortcut: $DESKTOP_FILE${NC}"
    rm -f "$DESKTOP_FILE"
    
    # Refresh desktop database
    echo -e "${GREEN}[*] Refreshing desktop applications database...${NC}"
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications"
    fi
    echo -e "${GREEN}[+] Desktop shortcut removed successfully.${NC}"
else
    echo -e "${YELLOW}[-] Desktop shortcut not found at '$DESKTOP_FILE'. Skipping.${NC}"
fi

# 3. Purge configuration and extensions if --purge is specified
if [[ "$PURGE" == true ]]; then
    echo -e "${RED}[*] Purging user configuration and extensions...${NC}"
    CONFIG_DIR="$HOME/.config/Antigravity"
    EXT_DIR="$HOME/.antigravity"
    
    if [[ -d "$CONFIG_DIR" ]]; then
        echo -e "    Removing settings folder: $CONFIG_DIR"
        rm -rf "$CONFIG_DIR"
    fi
    
    if [[ -d "$EXT_DIR" ]]; then
        echo -e "    Removing extensions folder: $EXT_DIR"
        rm -rf "$EXT_DIR"
    fi
    echo -e "${GREEN}[+] Successfully purged configurations and extensions.${NC}"
else
    echo -e "${BLUE}[*] Note: User configuration and extensions were NOT removed.${NC}"
    echo -e "    Your settings at ~/.config/Antigravity and extensions at ~/.antigravity are preserved."
    echo -e "    This allows you to migrate your settings to Antigravity 2.0 IDE using the --migrate option."
    echo -e "    To delete them, run this script again with the -p or --purge flag."
fi

echo -e "${BLUE}===============================================${NC}"
echo -e "${GREEN}      Antigravity 1.0 Cleaned Successfully!    ${NC}"
echo -e "${BLUE}===============================================${NC}"
