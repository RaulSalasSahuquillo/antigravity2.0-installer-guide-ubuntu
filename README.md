# Google Antigravity 2.0 & IDE: Installation Guide for Ubuntu (Bash/Zsh)

Welcome! This repository provides step-by-step installation guides and automated installer scripts to set up **Google Antigravity 2.0 (Standalone)** and **Google Antigravity 2.0 IDE** on Ubuntu (compatible with both `bash` and `zsh`). 

It also covers troubleshooting for common Linux desktop integration issues: the SUID sandbox error, Ubuntu 24.04 AppArmor space restrictions (the SIGTRAP trap), launcher creation, custom brand logo installation, and fixing the generic "gear icon" in the Ubuntu Dock.

---

## ⚠️ Prerequisite: Removing Antigravity 1.0

Before installing Antigravity 2.0 or the IDE, you **must completely remove any existing Antigravity 1.0 installation** to avoid system conflicts, mixed binary files, and desktop shortcut duplication.

We provide a cleanup script (`remove-antigravity-1.sh`) at the root of the project to automate this process.

### Automatically Remove Antigravity 1.0
Run the removal tool:
```bash
./remove-antigravity-1.sh
```

### Options:
*   `-d, --dir <path>`: Specify a custom installation directory to clean instead of the default `/opt/antigravity`.
*   `-p, --purge`: In addition to deleting the application, purge all user configurations, profiles, and settings located in `~/.config/Antigravity` and `~/.antigravity`. *(Note: Do NOT purge if you plan to use the `--migrate` option in the IDE installer, as it needs these files to import your settings).*

---

## 🚀 Quick Automated Installation

We provide pre-packaged scripts in the root directory to automate the extraction, permission fixes, custom logos, desktop launcher configuration, and Dock integration.

### Install Antigravity 2.0 (Standalone Utility)
Run the standalone installer, pointing to your downloaded archive:
```bash
./install-antigravity.sh ~/Downloads/google-antigravity-linux-x64.tar.gz
```

### Install Antigravity 2.0 IDE
Run the IDE installer, pointing to your downloaded archive. If you are running **Ubuntu 24.04 Noble Numbat**, remember to pass the `--no-sandbox` flag to prevent AppArmor crashes:
```bash
./install-ide.sh --no-sandbox ~/Downloads/AntigravityIDE.tar.gz
```

### Script Arguments & Customization

Both scripts support the following parameters:
*   `-d, --dir <path>`: Install to a custom directory instead of defaults (`/opt/antigravity` or `/opt/antigravity-ide`).
*   `-n, --no-sandbox`: Force the `--no-sandbox` parameter in the desktop shortcut `Exec` line (highly recommended for Ubuntu 24.04).
*   `-m, --migrate` *(IDE only)*: Automatically migrates your existing settings and extensions from your standard Antigravity installation to the IDE.

---

## 🛠️ Detailed Manual Installation & Troubleshooting Guide

If you prefer to install the applications manually, follow this breakdown of the steps and critical settings.

### 1. Extraction and Directory Placement

For a standard multi-user setup, we place manually installed packages in the `/opt/` system directory.

```bash
# Navigate to downloads and extract
cd ~/Downloads
tar -xzf google-antigravity-linux-x64.tar.gz

# Move the extracted files to their permanent locations
sudo mv google-antigravity /opt/antigravity

# For the IDE:
tar -xzf AntigravityIDE.tar.gz
sudo mv "Antigravity IDE" /opt/antigravity-ide
```

---

### 2. Fixing the SUID Sandbox Permission Error

Electron and Chromium-based applications use a security sandbox. By default, Linux requires the `chrome-sandbox` helper binary to be owned by `root` and have setuid permissions (`4755`). If you see a `FATAL:setuid_sandbox_host.cc` crash on startup:

```bash
# Navigate to your installation directory
cd /opt/antigravity   # or /opt/antigravity-ide

# Set root ownership and setuid permissions
sudo chown root:root chrome-sandbox
sudo chmod 4755 chrome-sandbox
```

---

### 3. Fixing the Ubuntu 24.04 AppArmor Crash (`SIGTRAP`)

> [!IMPORTANT]
> Ubuntu 24.04 introduced restricted user namespace usage via AppArmor. This causes many Chromium/Electron apps using `chrome-sandbox` to abort immediately with a `SIGTRAP (core dumped)` error.
> 
> **The Solution:** Append the `--no-sandbox` flag to the application's executable path in your terminal execution or your desktop launcher shortcut.

```bash
# To run from terminal:
/opt/antigravity/antigravity --no-sandbox
```

---

### 4. Creating the Desktop Shortcut (`.desktop` file)

To make the application searchable in the Ubuntu menu and show up in the Application Drawer, you must create a `.desktop` file under `~/.local/share/applications/`.

Create a file named `~/.local/share/applications/antigravityide.desktop`:

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity IDE
Comment=Agentic Development Platform
Exec=/opt/antigravity-ide/antigravity-ide --no-sandbox
Icon=/opt/antigravity-ide/antigravity-ide-logo.svg
Terminal=false
Categories=Development;IDE;
StartupWMClass=Antigravity IDE
```

> [!TIP]
> Make sure the desktop file is executable by running:
> ```bash
> chmod +x ~/.local/share/applications/antigravityide.desktop
> ```
> Then update the desktop registry database to force Ubuntu to load it:
> ```bash
> update-desktop-database ~/.local/share/applications/
> ```

---

### 5. Fixing the Dock "Gear Icon" (WM_CLASS Binding)

If your app is running but shows a generic grey cogwheel/gear icon in the Dock and doesn't let you right-click to add it to your "Favorites", the GNOME Shell doesn't know how to link the open window with your `.desktop` configuration.

To fix this, we map the window's internal identification class to the launcher.

1. Run the application.
2. In terminal, run: `xprop WM_CLASS`
3. Click on the open application window.
4. You will see an output like: `WM_CLASS(STRING) = "antigravity-ide", "Antigravity IDE"`
5. Copy the exact second class string (case sensitive) and append it to your `.desktop` file under the key `StartupWMClass`:
   ```ini
   StartupWMClass=Antigravity IDE
   ```
6. Restart the application. The correct icon will show on the Dock, allowing you to add it to Favorites.

---

### 6. Migrating Settings & Extensions

If you are upgrading from the standard Antigravity utility to the Antigravity IDE and want to carry over your workspace settings and extensions, copy these configuration files:

```bash
# 1. Copy user extensions
mkdir -p ~/.antigravity-ide/
cp -r ~/.antigravity/extensions ~/.antigravity-ide/

# 2. Copy user settings (e.g., keybinds, profiles, AI endpoints)
mkdir -p "$HOME/.config/Antigravity IDE/User"
cp "$HOME/.config/Antigravity/User/settings.json" "$HOME/.config/Antigravity IDE/User/"
```

---

## 🎨 Asset Management

This repository contains custom vector and raster icons inside the `assets/` folder:
*   `assets/antigravity-2.0-logo.png` - Standard high-resolution icon for Antigravity 2.0.
*   `assets/antigravity-ide-logo.svg` - Scalable Vector Graphics (SVG) icon for Antigravity IDE, which renders crisp and sharp at all sizes inside the GNOME Shell and Dock.

To use the SVG icon manually:
```bash
sudo cp assets/antigravity-ide-logo.svg /opt/antigravity-ide/
```
Then point `Icon=/opt/antigravity-ide/antigravity-ide-logo.svg` in your `.desktop` file.

---

## 🔍 Troubleshooting Audit Utility

You can verify the status of your shortcuts and installation directories at any time by running our audit utility:
```bash
./scripts/shortcut-updater.sh
```

This script will verify your installation directories, check whether the binaries exist, check permissions, validate image formats, and force-reload your desktop launcher database.
