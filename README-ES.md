# /usr/bin/antigravity-installer

> *"Cargando scripts de instalación..."*
> `[OK] Entorno del sistema: Ubuntu / Debian`
> `[OK] Shells soportadas: Bash y Zsh`
> `[OK] Listo para desplegar.`

Bienvenido a la guía de integración y herramienta de instalación automatizada para Google Antigravity 2.0 (Versión Estándar) y Google Antigravity 2.0 IDE en Ubuntu. Si quieres evitar configurar directorios manualmente, corregir errores de permisos del sandbox SUID o solucionar restricciones de seguridad de AppArmor en terminales Linux, estás en el lugar correcto.

---

### /etc/prereqs

**Desinstalar la versión heredada Antigravity 1.0**

Antes de proceder a desplegar la versión 2.0, es obligatorio desinstalar y limpiar la versión 1.0. Esto evita que ocurran conflictos entre versiones de archivos, duplicados de accesos directos o fallos en el Dock del entorno de escritorio.

Para hacerlo, ejecuta la herramienta de desinstalación disponible en la raíz del proyecto:
```bash
./remove-antigravity-1.sh
```

Parámetros disponibles:
*   `-d, --dir <ruta>`: Especifica la ruta del directorio que deseas eliminar en caso de que no se encuentre en `/opt/antigravity`.
*   `-p, --purge`: Elimina también los directorios de usuario, configuraciones y extensiones guardadas en `~/.config/Antigravity` y `~/.antigravity`. (No utilices esta opción si deseas trasladar tus extensiones y perfiles al nuevo IDE mediante la opción `--migrate` del instalador).

---

### /usr/bin/install

Hemos creado scripts automatizados en la carpeta raíz del proyecto para realizar la extracción de archivos, otorgar los permisos necesarios de SUID al sandbox, añadir los logotipos del proyecto y registrar la aplicación.

**Instalar Antigravity 2.0 (Versión Estándar)**
```bash
./install-antigravity.sh ~/Descargas/google-antigravity-linux-x64.tar.gz
```

**Instalar Antigravity 2.0 IDE**
Si tu sistema operativo es Ubuntu 24.04, añade la bandera `--no-sandbox` para eludir las restricciones de espacio de nombres impuestas por AppArmor:
```bash
./install-ide.sh --no-sandbox ~/Descargas/AntigravityIDE.tar.gz
```

**Parámetros soportados**
*   `-d, --dir <ruta>`: Reemplaza la ruta destino de la instalación (rutas por defecto: `/opt/antigravity` o `/opt/antigravity-ide`).
*   `-n, --no-sandbox`: Fuerza la inclusión del argumento `--no-sandbox` dentro de la línea `Exec` del acceso directo de la aplicación (altamente recomendado en Ubuntu 24.04).
*   `-m, --migrate` (Solo disponible en el instalador del IDE): Copia y migra de forma automática la configuración, perfiles y extensiones guardados en la versión estándar hacia el entorno de desarrollo IDE.

---

### /usr/share/man/manual-troubleshooting

Si decides realizar el despliegue de los paquetes de forma manual y paso a paso, sigue las instrucciones listadas a continuación:

**1. Extracción de Archivos y Ubicación**
Por convención, guardamos los paquetes de terceros instalados de forma manual en el directorio del sistema `/opt/`.
```bash
cd ~/Descargas
tar -xzf google-antigravity-linux-x64.tar.gz
sudo mv google-antigravity /opt/antigravity

# Para la versión del IDE:
tar -xzf AntigravityIDE.tar.gz
sudo mv "Antigravity IDE" /opt/antigravity-ide
```

**2. Error de Permisos SUID en chrome-sandbox**
Las aplicaciones basadas en Electron o Chromium requieren que el archivo auxiliar `chrome-sandbox` pertenezca al usuario root y cuente con permisos setuid 4755:
```bash
cd /opt/antigravity
sudo chown root:root chrome-sandbox
sudo chmod 4755 chrome-sandbox
```

**3. Restricción de Namespace de AppArmor en Ubuntu 24.04 (Bloqueo SIGTRAP)**
Ubuntu 24.04 restringe la creación de namespaces de usuario no privilegiados. Si la aplicación finaliza abruptamente con el error SIGTRAP (core dumped), ejecútala con la bandera `--no-sandbox`:
```bash
/opt/antigravity/antigravity --no-sandbox
```

**4. Crear el Acceso Directo de Escritorio**
Genera el archivo del lanzador en la ruta `~/.local/share/applications/antigravityide.desktop`:
```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=Antigravity IDE
Comment=Entorno de Desarrollo Agentic
Exec=/opt/antigravity-ide/antigravity-ide --no-sandbox
Icon=/opt/antigravity-ide/antigravity-ide-logo.svg
Terminal=false
Categories=Development;IDE;
StartupWMClass=Antigravity IDE
```
Dale permisos de ejecución y refresca la base de datos de lanzadores del sistema:
```bash
chmod +x ~/.local/share/applications/antigravityide.desktop
update-desktop-database ~/.local/share/applications/
```

**5. Icono del Engranaje Genérico en el Dock (Solución WM_CLASS)**
Si la ventana activa del programa se abre por separado o muestra un icono genérico de engranaje en el Dock de Ubuntu sin permitir fijarla a favoritos:
1. Abre la aplicación.
2. Abre la terminal y ejecuta el comando: `xprop WM_CLASS`
3. Haz clic con el cursor en cualquier parte de la ventana abierta de Antigravity.
4. Toma el segundo elemento de texto de la salida de terminal (por ejemplo, "Antigravity IDE").
5. Agrégalo en tu archivo `.desktop` utilizando el parámetro `StartupWMClass`:
   ```ini
   StartupWMClass=Antigravity IDE
   ```

**6. Migración de Configuraciones e Extensiones**
Para trasladar manualmente tus configuraciones y complementos, copia los directorios correspondientes:
```bash
mkdir -p ~/.antigravity-ide/
cp -r ~/.antigravity/extensions ~/.antigravity-ide/

mkdir -p "$HOME/.config/Antigravity IDE/User"
cp "$HOME/.config/Antigravity/User/settings.json" "$HOME/.config/Antigravity IDE/User/"
```

---

### /usr/share/assets

Las imágenes e iconos se almacenan en el directorio `assets/`:
*   `assets/antigravity-2.0-logo.png` - Icono rasterizado de alta definición.
*   `assets/antigravity-ide-logo.svg` - Icono vectorial SVG, ideal para una visualización sin distorsiones en las barras de tareas, búsquedas y el Dock de Ubuntu.

---

### /usr/sbin/audit

Puedes analizar de forma interactiva la integridad de los accesos directos, permisos de archivos, rutas de iconos y la sincronización con el sistema mediante la herramienta de auditoría:
```bash
./scripts/shortcut-updater.sh
```

---
*"In a world full of GUIs, be a command line."*
