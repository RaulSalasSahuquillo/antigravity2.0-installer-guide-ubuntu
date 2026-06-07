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
echo -e "         Antigravity 2.0 IDE Installer         "
echo -e "${BLUE}===============================================${NC}"

# Function to show usage
usage() {
    echo "Usage: $0 [options] <path_to_tarball>"
    echo "Options:"
    echo "  -d, --dir <path>       Specify installation directory (default: /opt/antigravity-ide)"
    echo "  -n, --no-sandbox       Enable --no-sandbox flag in desktop shortcut (required for Ubuntu 24.04+)"
    echo "  -m, --migrate          Migrate settings and extensions from standard Antigravity"
    echo "  -h, --help             Show this help message"
    exit 1
}

# Parse options
INSTALL_DIR="/opt/antigravity-ide"
NO_SANDBOX=false
MIGRATE=false
TARBALL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -n|--no-sandbox)
            NO_SANDBOX=true
            shift
            ;;
        -m|--migrate)
            MIGRATE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$TARBALL" ]]; then
                TARBALL="$1"
                shift
            else
                echo -e "${RED}Error: Multiple arguments provided.${NC}"
                usage
            fi
            ;;
    esac
done

# Check if tarball path is provided
if [[ -z "$TARBALL" ]]; then
    echo -e "${RED}Error: Tarball path is required.${NC}"
    usage
fi

# Check if tarball file exists
if [[ ! -f "$TARBALL" ]]; then
    echo -e "${RED}Error: File '$TARBALL' does not exist.${NC}"
    exit 1
fi

echo -e "${GREEN}[*] Preparing to install Antigravity 2.0 IDE...${NC}"
echo -e "    Tarball:       $TARBALL"
echo -e "    Target Dir:    $INSTALL_DIR"
echo -e "    No-Sandbox:    $NO_SANDBOX"
echo -e "    Migrate Config:$MIGRATE"

# Create extraction workspace
TMP_DIR=$(mktemp -d -t antigravity-ide-install-XXXXXXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

echo -e "${GREEN}[*] Extracting archive...${NC}"
tar -xf "$TARBALL" -C "$TMP_DIR"

# Find extracted folder and check for executable
# The tarball might contain a directory (like AntigravityIDE or Antigravity IDE) or files directly
EXTRACTED_CONTENT=("$TMP_DIR"/*)
if [[ ${#EXTRACTED_CONTENT[@]} -eq 1 && -d "${EXTRACTED_CONTENT[0]}" ]]; then
    SOURCE_DIR="${EXTRACTED_CONTENT[0]}"
else
    SOURCE_DIR="$TMP_DIR"
fi

# Find the binary
BINARY_PATH=""
if [[ -f "$SOURCE_DIR/antigravity-ide" ]]; then
    BINARY_PATH="$SOURCE_DIR/antigravity-ide"
elif [[ -f "$SOURCE_DIR/Antigravity-ide" ]]; then
    BINARY_PATH="$SOURCE_DIR/Antigravity-ide"
elif [[ -f "$SOURCE_DIR/antigravity" ]]; then
    BINARY_PATH="$SOURCE_DIR/antigravity"
fi

if [[ -z "$BINARY_PATH" ]]; then
    echo -e "${RED}Error: Could not find 'antigravity-ide' binary in the archive.${NC}"
    echo -e "Files found in archive:"
    ls -la "$SOURCE_DIR"
    exit 1
fi

# Check if legacy Antigravity (1.0 or standard) is installed
LEGACY_DIR="/opt/antigravity"
LEGACY_SHORTCUT="$HOME/.local/share/applications/antigravity.desktop"
if [[ -d "$LEGACY_DIR" || -f "$LEGACY_SHORTCUT" ]]; then
    echo -e "${YELLOW}[!] Warning: Legacy or Standard Antigravity installation detected.${NC}"
    echo -e "${YELLOW}[!] To prevent desktop launcher conflicts, it is recommended to remove it before installing the IDE.${NC}"
    echo -e "${YELLOW}[!] You can use the './remove-antigravity-1.sh' script to remove it cleanly.${NC}"
    read -p "Would you like to run the removal script now? (y/N): " run_remove
    if [[ "$run_remove" =~ ^[yY]$ ]]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if [[ -f "$SCRIPT_DIR/remove-antigravity-1.sh" ]]; then
            bash "$SCRIPT_DIR/remove-antigravity-1.sh"
        elif [[ -f "./remove-antigravity-1.sh" ]]; then
            bash "./remove-antigravity-1.sh"
        else
            echo -e "${RED}Error: remove-antigravity-1.sh script not found! Please run it manually.${NC}"
        fi
    fi
fi

# Check if target directory already exists and clean it up to prevent conflicts
if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}[!] Target IDE installation directory '$INSTALL_DIR' already exists.${NC}"
    read -p "Do you want to clean/remove the existing directory '$INSTALL_DIR' before installing? (y/N): " clean_confirm
    if [[ "$clean_confirm" =~ ^[yY]$ ]]; then
        echo -e "${GREEN}[*] Cleaning target directory: $INSTALL_DIR...${NC}"
        if [[ "$INSTALL_DIR" == /opt/* ]]; then
            sudo rm -rf "$INSTALL_DIR"
        else
            rm -rf "$INSTALL_DIR"
        fi
        echo -e "${GREEN}[+] Target directory cleaned.${NC}"
    else
        echo -e "${YELLOW}[!] Continuing installation without cleaning. Mixed files might cause errors.${NC}"
    fi
fi

# Create target directory (requires sudo if installing to /opt)
echo -e "${GREEN}[*] Creating installation directory: $INSTALL_DIR${NC}"
if [[ "$INSTALL_DIR" == /opt/* ]]; then
    sudo mkdir -p "$INSTALL_DIR"
    echo -e "${GREEN}[*] Copying IDE application files (requires sudo)...${NC}"
    sudo cp -r "$SOURCE_DIR"/* "$INSTALL_DIR/"
else
    mkdir -p "$INSTALL_DIR"
    echo -e "${GREEN}[*] Copying IDE application files...${NC}"
    cp -r "$SOURCE_DIR"/* "$INSTALL_DIR/"
fi

# Apply chrome-sandbox permission fix
SANDBOX_FILE="$INSTALL_DIR/chrome-sandbox"
if [[ -f "$SANDBOX_FILE" ]]; then
    echo -e "${GREEN}[*] Applying SUID sandbox permissions (requires sudo)...${NC}"
    sudo chown root:root "$SANDBOX_FILE"
    sudo chmod 4755 "$SANDBOX_FILE"
else
    echo -e "${YELLOW}[!] Warning: chrome-sandbox not found. Skipping permissions fix.${NC}"
fi

# Handle logo/icon copy (SVG support!)
# Check if script directory contains assets/antigravity-ide-logo.svg
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_SOURCE="$SCRIPT_DIR/assets/antigravity-ide-logo.svg"
ICON_DEST="$INSTALL_DIR/antigravity-ide-logo.svg"

if [[ -f "$ICON_SOURCE" ]]; then
    echo -e "${GREEN}[*] Installing custom SVG icon...${NC}"
    if [[ "$INSTALL_DIR" == /opt/* ]]; then
        sudo cp "$ICON_SOURCE" "$ICON_DEST"
    else
        cp "$ICON_SOURCE" "$ICON_DEST"
    fi
else
    # Fallback to PNG icon if SVG is missing
    ICON_SOURCE_PNG="$SCRIPT_DIR/assets/antigravity-2.0-logo.png"
    ICON_DEST_PNG="$INSTALL_DIR/antigravity-ide-logo.png"
    if [[ -f "$ICON_SOURCE_PNG" ]]; then
        echo -e "${YELLOW}[!] SVG icon not found, using PNG icon...${NC}"
        ICON_DEST="$ICON_DEST_PNG"
        if [[ "$INSTALL_DIR" == /opt/* ]]; then
            sudo cp "$ICON_SOURCE_PNG" "$ICON_DEST"
        else
            cp "$ICON_SOURCE_PNG" "$ICON_DEST"
        fi
    else
        APP_ICON_PATH="$INSTALL_DIR/resources/app/icon.png"
        if [[ -f "$APP_ICON_PATH" ]]; then
            ICON_DEST="$INSTALL_DIR/icon.png"
            if [[ "$INSTALL_DIR" == /opt/* ]]; then
                sudo cp "$APP_ICON_PATH" "$ICON_DEST"
            else
                cp "$APP_ICON_PATH" "$ICON_DEST"
            fi
        else
            echo -e "${YELLOW}[!] No icon file found. Using default system terminal icon in launcher.${NC}"
            ICON_DEST="utilities-terminal"
        fi
    fi
fi

# Setup desktop application launcher (.desktop file)
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"
DESKTOP_FILE="$DESKTOP_DIR/antigravityide.desktop"

# Set executable name and sandbox arguments
EXEC_BIN="$INSTALL_DIR/$(basename "$BINARY_PATH")"
if [[ "$NO_SANDBOX" == true ]]; then
    EXEC_COMMAND="$EXEC_BIN --no-sandbox"
else
    EXEC_COMMAND="$EXEC_BIN"
fi

echo -e "${GREEN}[*] Creating desktop launcher shortcut: $DESKTOP_FILE${NC}"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity IDE
Comment=Antigravity Agentic Development Platform
Exec=$EXEC_COMMAND
Icon=$ICON_DEST
Terminal=false
Categories=Development;IDE;
StartupWMClass=Antigravity IDE
EOF

# Make shortcut executable
chmod +x "$DESKTOP_FILE"

# Settings and Extensions Migration
if [[ "$MIGRATE" == true ]]; then
    echo -e "${GREEN}[*] Migrating configurations and extensions...${NC}"
    
    # Extensions Migration
    SRC_EXT="$HOME/.antigravity/extensions"
    DEST_EXT="$HOME/.antigravity-ide/extensions"
    if [[ -d "$SRC_EXT" ]]; then
        echo -e "    Migrating extensions from $SRC_EXT to $DEST_EXT"
        mkdir -p "$HOME/.antigravity-ide"
        cp -r "$SRC_EXT" "$HOME/.antigravity-ide/"
        echo -e "    ${GREEN}Extensions migrated successfully.${NC}"
    else
        echo -e "    ${YELLOW}[!] Source extensions directory $SRC_EXT does not exist. Skipping.${NC}"
    fi

    # Settings Migration
    SRC_SETTINGS="$HOME/.config/Antigravity/User/settings.json"
    DEST_SETTINGS_DIR="$HOME/.config/Antigravity IDE/User"
    if [[ -f "$SRC_SETTINGS" ]]; then
        echo -e "    Migrating settings.json to $DEST_SETTINGS_DIR/settings.json"
        mkdir -p "$DEST_SETTINGS_DIR"
        cp "$SRC_SETTINGS" "$DEST_SETTINGS_DIR/settings.json"
        echo -e "    ${GREEN}Settings migrated successfully.${NC}"
    else
        echo -e "    ${YELLOW}[!] Source settings file $SRC_SETTINGS does not exist. Skipping.${NC}"
    fi
fi

# Refresh desktop database
echo -e "${GREEN}[*] Refreshing desktop applications database...${NC}"
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR"
fi

echo -e "${BLUE}===============================================${NC}"
echo -e "${GREEN}  Antigravity 2.0 IDE Installed Successfully!   ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo -e "You can now launch it from your Applications menu or search for 'Antigravity IDE'."
echo -e "You can also pin it to your GNOME/Ubuntu Dock with the proper icon and no engranaje/gear icon issues."
