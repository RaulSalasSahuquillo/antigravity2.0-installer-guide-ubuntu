# /usr/bin/antigravity-installer

> *"Loading installation scripts..."*
> `[OK] Host environment: Ubuntu / Debian`
> `[OK] Shells supported: Bash & Zsh`
> `[OK] Ready to deploy.`

Welcome to the automated installer and integration guide for Google Antigravity 2.0 (Standalone Utility) and Google Antigravity 2.0 IDE on Ubuntu. If you want to bypass manual folder placement, chrome-sandbox permission errors, and AppArmor security blocks, you are in the right terminal.

---

### /etc/prereqs

**Uninstall legacy Antigravity 1.0**

Before deploying 2.0, you must completely remove any existing Antigravity 1.0 installation to prevent file version conflicts, duplicated shortcut entries, or desktop launcher corruption.

Run the removal script at the root of this project:
```bash
./remove-antigravity-1.sh
```

Arguments:
*   `-d, --dir <path>`: Specify a custom installation directory to clean instead of the default `/opt/antigravity`.
*   `-p, --purge`: Remove all user configurations, profile variables, and extensions located in `~/.config/Antigravity` and `~/.antigravity`. (Do NOT purge if you intend to use the `--migrate` option in the IDE installer, as it needs those files to copy your preferences).

---

### /usr/bin/install

We provide pre-packaged scripts in the root directory to automate file extraction, sandbox ownership corrections, logo registration, and desktop shortcut generation.

**Install Antigravity 2.0 (Standalone Utility)**
```bash
./install-antigravity.sh ~/Downloads/google-antigravity-linux-x64.tar.gz
```

**Install Antigravity 2.0 IDE**
If you are running Ubuntu 24.04, make sure to add the `--no-sandbox` parameter to bypass the new AppArmor restrictions:
```bash
./install-ide.sh --no-sandbox ~/Downloads/AntigravityIDE.tar.gz
```

**Arguments**
*   `-d, --dir <path>`: Override the installation directory (defaults: `/opt/antigravity` or `/opt/antigravity-ide`).
*   `-n, --no-sandbox`: Force the `--no-sandbox` flag inside the shortcut desktop entry's Exec command (highly recommended for Ubuntu 24.04).
*   `-m, --migrate` (IDE installer only): Automatically copy over your settings and extensions from your standard Antigravity installation to the IDE.

---

### /usr/share/man/manual-troubleshooting

If you prefer to configure your application manually, run the following steps:

**1. Extraction and Folder Placement**
For global access, manual packages are stored under the `/opt/` system directory.
```bash
cd ~/Downloads
tar -xzf google-antigravity-linux-x64.tar.gz
sudo mv google-antigravity /opt/antigravity

# For the IDE:
tar -xzf AntigravityIDE.tar.gz
sudo mv "Antigravity IDE" /opt/antigravity-ide
```

**2. SUID Sandbox Permission Error**
Electron/Chromium apps require the helper executable `chrome-sandbox` to be owned by root and have setuid permissions set to 4755:
```bash
cd /opt/antigravity
sudo chown root:root chrome-sandbox
sudo chmod 4755 chrome-sandbox
```

**3. Ubuntu 24.04 AppArmor Namespace Restrictions (SIGTRAP Crash)**
Ubuntu 24.04 restricts unprivileged user namespaces. If the app aborts immediately with a SIGTRAP (core dumped), run it with the `--no-sandbox` flag:
```bash
/opt/antigravity/antigravity --no-sandbox
```

**4. Create Desktop Shortcut**
Create a launcher shortcut inside `~/.local/share/applications/antigravityide.desktop`:
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
Mark it executable and update desktop database to register it:
```bash
chmod +x ~/.local/share/applications/antigravityide.desktop
update-desktop-database ~/.local/share/applications/
```

**5. Fix Generic Gear Icon in Dock (WM_CLASS Binding)**
If GNOME Shell displays a generic gear icon and fails to associate your active window with the launcher shortcut:
1. Open the application.
2. In a terminal, run: `xprop WM_CLASS`
3. Click the open application window.
4. Copy the second string in the output (e.g. "Antigravity IDE").
5. Paste it under `StartupWMClass` key in the `.desktop` file:
   ```ini
   StartupWMClass=Antigravity IDE
   ```

**6. Settings & Extensions Migration**
Migrate your current standard configuration settings to the IDE environment using these folder paths:
```bash
mkdir -p ~/.antigravity-ide/
cp -r ~/.antigravity/extensions ~/.antigravity-ide/

mkdir -p "$HOME/.config/Antigravity IDE/User"
cp "$HOME/.config/Antigravity/User/settings.json" "$HOME/.config/Antigravity IDE/User/"
```

---

### /usr/share/assets

Custom graphics are placed inside the `assets/` directory:
*   `assets/antigravity-2.0-logo.png` - Standard raster icon.
*   `assets/antigravity-ide-logo.svg` - Scalable vector graphic icon, providing high resolution scaling for launcher shortcuts and Dock favorites.

---

### /usr/sbin/audit

Validate the status of your folders, launcher properties, permissions, and icons by running the diagnostic tool:
```bash
./scripts/shortcut-updater.sh
```

---
*"In a world full of GUIs, be a command line."*
