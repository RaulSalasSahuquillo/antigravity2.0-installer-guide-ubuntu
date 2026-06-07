# Guía de Instalación de Google Antigravity 2.0 y IDE para Ubuntu (Bash/Zsh)

¡Te damos la bienvenida! Esta guía contiene instrucciones detalladas paso a paso y scripts automatizados para instalar y configurar **Google Antigravity 2.0 (Versión Estándar)** y **Google Antigravity 2.0 IDE** en Ubuntu, siendo compatible tanto con terminales `bash` como `zsh`.

Esta documentación resuelve de forma definitiva los problemas de integración más comunes en Linux: el error de permisos del sandbox SUID, las restricciones de espacio de nombres de usuario de AppArmor en Ubuntu 24.04 (el bloqueo por excepción `SIGTRAP`), la creación de accesos directos `.desktop`, la configuración de logotipos personalizados y la solución al icono del engranaje genérico en el Dock de Ubuntu.

---

## ⚠️ Requisito Previo: Eliminar Antigravity 1.0

Antes de instalar Antigravity 2.0 o el IDE, **debes eliminar por completo cualquier instalación anterior de Antigravity 1.0** para evitar conflictos en el sistema, mezcla de archivos binarios y duplicación de accesos directos.

Hemos incluido una herramienta de limpieza (`remove-antigravity-1.sh`) en la raíz del proyecto para automatizar este proceso.

### Eliminar Antigravity 1.0 Automáticamente
Ejecuta la herramienta de eliminación:
```bash
./remove-antigravity-1.sh
```

### Opciones Disponibles:
*   `-d, --dir <ruta>`: Especifica un directorio de instalación personalizado en lugar de la ruta por defecto `/opt/antigravity`.
*   `-p, --purge`: Además de eliminar la aplicación, borra las carpetas de configuración del usuario, atajos y preferencias ubicadas en `~/.config/Antigravity` y `~/.antigravity`. *(Nota: NO uses esta opción si planeas migrar tus configuraciones al IDE mediante el parámetro `--migrate`, ya que el instalador requiere estos archivos para realizar la migración).*

---

## 🚀 Instalación Rápida Automatizada

Hemos creado scripts en la carpeta raíz del proyecto para automatizar todo el proceso: extracción de archivos, corrección de permisos del sandbox, configuración de logotipos y accesos directos, e integración limpia en el Dock de Ubuntu.

### Instalar Antigravity 2.0 (Versión Estándar / Utilidad)
Ejecuta el script del instalador indicando la ruta del archivo tarball que descargaste:
```bash
./install-antigravity.sh ~/Descargas/google-antigravity-linux-x64.tar.gz
```

### Instalar Antigravity 2.0 IDE (Entorno de Desarrollo)
Ejecuta el instalador del IDE indicando la ruta de su archivo comprimido. Si utilizas **Ubuntu 24.04 Noble Numbat**, te sugerimos añadir el parámetro `--no-sandbox` para evitar el bloqueo del sistema por AppArmor:
```bash
./install-ide.sh --no-sandbox ~/Descargas/AntigravityIDE.tar.gz
```

### Parámetros y Personalización de los Scripts

Ambos scripts soportan las siguientes opciones:
*   `-d, --dir <ruta>`: Especifica un directorio de instalación personalizado en lugar de las rutas por defecto (`/opt/antigravity` o `/opt/antigravity-ide`).
*   `-n, --no-sandbox`: Fuerza la inclusión del parámetro `--no-sandbox` en el comando `Exec` del acceso directo (altamente recomendado para Ubuntu 24.04).
*   `-m, --migrate` *(Solo disponible en el IDE)*: Migra automáticamente tus extensiones y configuraciones guardadas de la versión estándar al IDE.

---

## 🛠️ Guía de Instalación Manual y Resolución de Problemas

Si prefieres realizar la instalación de forma manual y paso a paso para comprender el proceso interno de Linux, aquí tienes la guía completa.

### 1. Extracción y Ubicación de Archivos

Por convención en Linux, los programas de terceros que se instalan de forma manual y global para todos los usuarios se guardan en el directorio `/opt/`.

```bash
# Navega a la carpeta de descargas y extrae el contenido
cd ~/Descargas
tar -xzf google-antigravity-linux-x64.tar.gz

# Mueve la carpeta a una ubicación permanente
sudo mv google-antigravity /opt/antigravity

# Para la versión del IDE:
tar -xzf AntigravityIDE.tar.gz
sudo mv "Antigravity IDE" /opt/antigravity-ide
```

---

### 2. Corregir el Error de Permisos de chrome-sandbox (SUID)

Las aplicaciones basadas en Electron y Chromium requieren una herramienta interna de aislamiento o sandbox para ejecutarse de forma segura. Por seguridad de Linux, el archivo `chrome-sandbox` debe ser propiedad del usuario `root` y contar con permisos setuid (`4755`).

Si al arrancar la aplicación en la terminal ves el error:  
`FATAL:setuid_sandbox_host.cc: The SUID sandbox helper binary was found, but is not configured correctly.`

Debes ejecutar lo siguiente en la terminal para arreglarlo:

```bash
# Entra al directorio donde instalaste la aplicación
cd /opt/antigravity   # o cd /opt/antigravity-ide

# Cambia el propietario a root y otorga los permisos correctos
sudo chown root:root chrome-sandbox
sudo chmod 4755 chrome-sandbox
```

---

### 3. Solucionar el Cierre Inmediato (`SIGTRAP`) en Ubuntu 24.04

> [!IMPORTANT]
> A partir de la versión 24.04, Ubuntu introdujo políticas de seguridad muy estrictas con AppArmor que restringen el uso de namespaces no privilegiados. Como resultado, las aplicaciones Electron que intentan usar `chrome-sandbox` sufren un bloqueo de seguridad, lanzando una señal `SIGTRAP (core dumped)` y cerrándose inmediatamente.
> 
> **La Solución:** Debemos indicarle al programa ejecutable que no intente crear este sandbox añadiendo el parámetro `--no-sandbox` al final de la ruta del ejecutable en el acceso directo.

```bash
# Comando para iniciar la aplicación directamente desde la terminal de forma manual:
/opt/antigravity/antigravity --no-sandbox
```

---

### 4. Crear el Acceso Directo de Escritorio (Archivo `.desktop`)

Para que la aplicación aparezca en tu cajón de aplicaciones de Ubuntu, puedas buscarla por su nombre y anclarla a tus favoritos, necesitas crear un archivo `.desktop` en la carpeta de configuraciones de usuario.

Crea un archivo llamado `~/.local/share/applications/antigravityide.desktop` (usando un editor como Nano):

```bash
nano ~/.local/share/applications/antigravityide.desktop
```

Pega el siguiente contenido (puedes ajustar las rutas si usas directorios personalizados):

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

> [!TIP]
> Una vez guardados los cambios (en Nano: Ctrl + O, Enter para confirmar, y Ctrl + X para salir), haz que el acceso directo sea ejecutable y actualiza la base de datos de lanzadores del sistema:
> ```bash
> chmod +x ~/.local/share/applications/antigravityide.desktop
> update-desktop-database ~/.local/share/applications/
> ```

---

### 5. Solución al Icono del Engranaje Genérico en el Dock (WM_CLASS)

Si al abrir la aplicación, Ubuntu muestra un icono gris de engranaje genérico en el Dock y no te permite fijarla en "Favoritos" o la agrupa en una ventana separada del lanzador, es porque el entorno de escritorio no sabe asociar la ventana activa del programa con tu archivo `.desktop`.

Para resolver esto, debemos vincular el identificador interno de la ventana (llamado `WM_CLASS`) al acceso directo:

1. Mantén la aplicación Antigravity abierta de modo que veas su ventana.
2. Abre la terminal y ejecuta: `xprop WM_CLASS`
3. Tu cursor cambiará a una cruz (+). Haz clic en cualquier zona de la ventana abierta de Antigravity.
4. En la terminal verás una salida similar a esta: `WM_CLASS(STRING) = "antigravity-ide", "Antigravity IDE"`
5. Copia el segundo valor de la salida (el que está con mayúsculas y espacios en este caso: `Antigravity IDE`) y añádelo como una línea nueva en tu archivo `.desktop`:
   ```ini
   StartupWMClass=Antigravity IDE
   ```
6. Cierra por completo la aplicación y vuelve a abrirla desde el buscador de aplicaciones. Ahora el icono aparecerá de forma correcta y te dejará añadirla a favoritos.

---

### 6. Migrar Configuraciones y Extensiones entre Versiones

Si has estado usando la versión de utilidad estándar de Antigravity y ahora quieres migrar todas tus preferencias, atajos y extensiones instaladas hacia el nuevo Antigravity IDE, ejecuta los siguientes comandos en tu terminal para copiar los datos de un entorno al otro:

```bash
# 1. Copiar las extensiones del agente
mkdir -p ~/.antigravity-ide/
cp -r ~/.antigravity/extensions ~/.antigravity-ide/

# 2. Copiar los archivos de configuración de usuario (settings.json, perfiles de IA)
mkdir -p "$HOME/.config/Antigravity IDE/User"
cp "$HOME/.config/Antigravity/User/settings.json" "$HOME/.config/Antigravity IDE/User/"
```

---

## 🎨 Gestión de Logotipos e Iconos

Este repositorio cuenta con logotipos diseñados a medida dentro de la carpeta `assets/` para dar un aspecto profesional y limpio al dock de tu sistema:
*   `assets/antigravity-2.0-logo.png` - Icono en resolución nativa para Antigravity 2.0 estándar.
*   `assets/antigravity-ide-logo.svg` - Logotipo en formato vectorial (SVG) para Antigravity IDE. El uso de archivos `.svg` es la mejor opción para iconos en Ubuntu ya que el sistema operativo puede escalarlos a cualquier tamaño en búsquedas o en el Dock manteniéndose siempre nítido y sin pixelar.

Para copiar e instalar manualmente la versión SVG del logotipo del IDE:
```bash
sudo cp assets/antigravity-ide-logo.svg /opt/antigravity-ide/
```
Luego asegúrate de que la propiedad `Icon` de tu archivo `.desktop` apunte exactamente a esa ubicación: `Icon=/opt/antigravity-ide/antigravity-ide-logo.svg`.

---

## 🔍 Herramienta de Auditoría y Diagnóstico

Puedes comprobar en cualquier momento la integridad de tus accesos directos, directorios y configuraciones ejecutando nuestra herramienta de auditoría de escritorio en la terminal:
```bash
./scripts/shortcut-updater.sh
```

Esta herramienta comprobará que los archivos ejecutables existan, validará que las rutas de los iconos sean correctas, buscará errores comunes de sandbox y forzará la actualización del menú de aplicaciones del sistema.
