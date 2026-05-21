# Linux Lab Context

Fecha de contexto: 2026-05-21

## Equipo

- Sistema: Debian GNU/Linux 13 trixie.
- Kernel observado: 6.12.63+deb13-amd64.
- Disco raiz: 456 GB aprox.; 413 GB libres al revisar.
- Memoria: 7.7 GiB RAM y swap configurado.
- Uso previsto: laptop ligera para datos medianos, notebooks, scripting, red/pentest ligero y auditoria basica del sistema.

## Herramientas verificadas

- Base instalada: Python 3.13, pip, venv, R/Rscript, Node/npm, Git, SQLite.
- Python sistema con librerias de datos: numpy, pandas, matplotlib, seaborn, scipy, scikit-learn, openpyxl, xlsxwriter, statsmodels y jupyterlab.
- Herramientas de red/pentest presentes: nmap, ffuf, gobuster, nikto, sqlmap, tshark, tcpdump, aircrack-ng, bettercap.
- Herramientas de red/sistema adicionales presentes: openssh-server/sshd, fail2ban, iperf3, mtr, netcat, net-tools, wavemon.
- Monitoreo presente: htop, btop, ncdu, lm-sensors.
- Utilidades de terminal presentes: pipx, curl, wget, zip, unzip, jq, fzf, tree, rg/ripgrep, fdfind/fd-find, neovim, tmux, tldr/tealdeer.
- Markdown presente: `glow` y `batcat` instalados; `mdread` creado como wrapper para leer `.md` desde terminal.
- Video/transcripcion presente: `yt-dlp`, `ffmpeg` y `faster-whisper` dentro de `./video-tools/runtime/venv`.
- Descargas divididas presente: `aria2c` version 1.37.0.
- `john`, `smartctl` y `ufw` estan instalados por apt, pero en Debian viven bajo `/usr/sbin`; los scripts deben extender PATH con `/sbin:/usr/sbin`.
- `sshd` tambien vive bajo `/usr/sbin` o `/sbin` segun PATH; verificar con `PATH="$PATH:/sbin:/usr/sbin" command -v sshd`.

## Estandar de scripts

Directorio canonico para scripts nuevos dentro del repositorio:

```text
./Scripts
```

Scripts principales:

- `install-linux-lab.sh`: instalador general y reproducible para una laptop Debian nueva. Instala base Linux Lab, CLIs locales en `~/bin` y permite flags opcionales: `--with-containers`, `--with-docker`, `--with-dev-toolchains`, `--with-video-runtime`, `--old-laptop-tune`.
- `install-lab-tools.sh`: instala base de datos, notebooks, red/pentest ligero y monitoreo.
- `lab-tool-check`: verifica comandos y modulos Python relevantes.
- `laptop-audit`: imprime diagnostico rapido de sistema, disco, memoria, temperatura, SMART y herramientas.
- `mdread`: lee archivos Markdown con `glow` si esta instalado o `batcat` como fallback. Visor preferido verificado con `glow --version`.
- `new-data-project`: crea estructura reproducible para proyectos de datos.

Herramientas externas organizadas:

- `./video-tools`: CLI para descargar audio/video y transcribir.
  - Comandos: `vt transcribe "URL" es` y `transcribir-video "URL" es`.
  - Salida: `./video-tools/output`.
  - Usa `yt-dlp`, `ffmpeg`, `faster-whisper` y `numpy<2.3` por compatibilidad con esta CPU.
- `./download-tools`: CLI para descargas divididas con `aria2c`.
  - Comando: `dl "URL"` o `dl -x 16 "URL"`.
  - Listas: `dl list "./download-tools/lists/urls.txt"`.
  - Salida: `./download-tools/downloads`.
  - Usa `aria2c`.

Aliases persistentes en `~/.bashrc`:

- `video-tools/aliases.sh` para `vt` y `transcribir-video`.
- `download-tools/aliases.sh` para `dl`.

## Criterio de instalacion

- Preferir paquetes Debian con `apt` para herramientas de sistema y librerias estables.
- Usar entornos virtuales por proyecto para paquetes Python que Debian no provea bien, especialmente `duckdb`, `pyarrow` y `polars`.
- Evitar instalar paquetes globales con `pip` en el Python del sistema.
- No habilitar servicios entrantes por defecto. SSH y UFW se dejan instalados, pero su activacion debe ser una decision explicita.

## Reglas de trabajo tipo Karpathy

Resumen operativo inspirado en `multica-ai/andrej-karpathy-skills`:

Fuente revisada: https://github.com/multica-ai/andrej-karpathy-skills/blob/main/CLAUDE.md

- Mantener las soluciones simples y legibles.
- Preferir cambios pequenos y verificables.
- Leer el estado real antes de asumir.
- Crear artefactos reproducibles: scripts, comandos y contexto versionable.
- Verificar con comandos concretos y reportar lo observado.
- No ocultar incertidumbre: distinguir lo verificado de lo recomendado.
- Evitar complejidad prematura; instalar o abstraer solo si reduce friccion real.

## Estado despues de instalacion

- Verificacion reportada por usuario: `jupyter-lab`, `openpyxl`, `xlsxwriter`, `statsmodels` y `jupyterlab` aparecen OK en `lab-tool-check`.
- `pyarrow`, `duckdb` y `polars` no estan instalados globalmente. Mantenerlos como dependencias por proyecto en `.venv`.
- Paquetes soportados por apt que aun pueden agregarse si se necesita compilar librerias Python/C: `pkg-config`.
- Contenedores no instalados: `podman` y `docker.io`. Preferir `podman` si se necesita una opcion soportada por Debian y mas ligera.
- `yt-dlp`, `ffmpeg`, `faster-whisper` y `aria2c` estan listos para uso desde sus CLIs locales.
- Usar `lab-tool-check` despues de instalar.
- En una laptop nueva, usar primero `sudo bash "./Scripts/install-linux-lab.sh"` desde la raiz del repositorio. Agregar `--with-containers` si se necesita Podman, `--with-docker` si se requiere Docker clasico, y `--with-video-runtime` si se usara transcripcion local.
- Crear proyectos con `new-data-project <nombre>` y trabajar en `.venv`.
