# Scripts de laboratorio Linux

Ubicacion dentro del repositorio:

```bash
./Scripts
```

Los comandos principales tambien estan disponibles desde `~/bin`, asi que pueden ejecutarse desde cualquier terminal.

## Verificar la laptop

```bash
lab-tool-check
```

Muestra:

- sistema, disco y RAM disponible;
- herramientas instaladas;
- modulos Python disponibles para datos.

## Auditoria rapida del equipo

```bash
laptop-audit
```

Sirve para revisar CPU, memoria, disco, temperatura, SMART si hay permisos, procesos principales y herramientas clave.

## Leer Markdown

```bash
mdread README.md
```

Abre archivos `.md` en terminal. Usa `glow` si esta instalado; si no, usa `batcat`.

Instalar `glow`:

```bash
sudo apt install -y glow
glow --version
```

## Crear un proyecto de datos

Desde la carpeta donde quieras crear el proyecto:

```bash
new-data-project mi_proyecto
cd mi_proyecto
./scripts/create-venv.sh
```

Esto crea:

```text
mi_proyecto/
  data/
    raw/
    processed/
  notebooks/
  src/
  models/
  reports/
  scripts/
  requirements.txt
  analysis.R
  README.md
```

Uso recomendado:

- guarda datos originales en `data/raw`;
- guarda datos limpios o convertidos en `data/processed`;
- usa `notebooks` para exploracion;
- pasa codigo reutilizable a `src`;
- guarda tablas, graficas y salidas en `reports`.

## Abrir JupyterLab en un proyecto

Dentro del proyecto:

```bash
./scripts/start-jupyter.sh
```

Si ya existe `.venv`, el script lo activa antes de abrir JupyterLab.

## Descargar y transcribir videos

Herramienta fuera de `Dev Projects`, porque no es un proyecto de desarrollo:

```bash
~/Linux-Tools/video-tools
```

Comandos disponibles:

```bash
vt transcribe "URL_DEL_VIDEO" es
transcribir-video "URL_DEL_VIDEO" es
```

Guarda audios, transcripciones `.txt` y subtitulos `.srt` en:

```bash
~/Linux-Tools/video-tools/output
```

Dependencias verificadas en esta maquina:

- `yt-dlp`
- `ffmpeg`
- `faster-whisper`

## Descargas divididas

Herramienta fuera de `Dev Projects`, porque es utileria de sistema:

```bash
~/Linux-Tools/download-tools
```

Comando principal:

```bash
dl "URL_DEL_ARCHIVO"
```

Usar mas conexiones:

```bash
dl -x 16 "URL_DEL_ARCHIVO"
```

Descargar lista de URLs:

```bash
dl list "$HOME/Linux-Tools/download-tools/lists/urls.txt"
```

Guarda descargas por defecto en:

```bash
~/Linux-Tools/download-tools/downloads
```

Dependencia verificada en esta maquina:

- `aria2c`

## Instalar herramientas faltantes

Instalador general recomendado para una laptop Debian nueva:

```bash
sudo bash "./Scripts/install-linux-lab.sh"
```

## Instalar herramientas de desarrollo y bases de datos

```bash
sudo bash "./Scripts/install-dev-db-tools.sh"
```

Instala editores ligeros, clientes de bases de datos y Adminer.

Con contenedores ligeros y runtime de transcripcion:

```bash
sudo bash "./Scripts/install-linux-lab.sh" --with-containers --with-video-runtime
```

Con toolchains de desarrollo y Docker clasico:

```bash
sudo bash "./Scripts/install-linux-lab.sh" --with-dev-toolchains --with-docker
```

Para completar paquetes Debian de datos/notebooks:

```bash
sudo bash "./Scripts/install-missing-data-tools.sh"
```

Para instalar o reinstalar toda la base del laboratorio:

```bash
sudo bash "./Scripts/install-lab-tools.sh"
```

Los scripts anteriores se mantienen por compatibilidad, pero el punto unico recomendado es `install-linux-lab.sh`.

## Herramientas de soporte, rescate y forense

Menu local para tareas comunes:

```bash
./Scripts/rescue-toolbox
```

Incluye accesos a inventario del equipo, discos, SMART, GParted, TestDisk,
PhotoRec, ddrescue, imagenes de USB, hashes, YARA, binwalk, Wireshark,
firewall, auditoria y herramientas de red.

Instalador del paquete extra:

```bash
sudo bash "./Scripts/install-swiss-tools.sh"
```

Instala herramientas para recuperacion, forense basico/intermedio, backups,
antivirus, auditoria de seguridad y manejo de imagenes.

## Monitoreo remoto

Menu local para revisar servidores por SSH:

```bash
./Scripts/remote-monitor
```

Incluye accesos para SSH, Mosh, Glances remoto, btop/htop remoto, discos,
servicios, Nmap, SSHFS, checks estilo Nagios y notas de Node Exporter.

Instalador del paquete de monitoreo:

```bash
sudo bash "./Scripts/install-monitoring-tools.sh"
```

## Paquetes por proyecto

No instalar globalmente paquetes Python que cambian mucho. El template ya los incluye en `requirements.txt`:

```text
duckdb
pyarrow
polars
jupyterlab
```

Si necesitas agregarlos manualmente:

```bash
python3 -m venv .venv
. .venv/bin/activate
python -m pip install duckdb pyarrow polars jupyterlab
```

## Contexto para IA

El contexto de esta laptop vive en:

```bash
./Scripts/ai_context/linux_lab_context.md
```

Incluye el estado de la instalacion, reglas de trabajo y decisiones tomadas para mantener la laptop ligera.
