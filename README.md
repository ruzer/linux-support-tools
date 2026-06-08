# Linux Support Tools

Version: `0.2.0`

Herramientas utiles para preparar y mantener laptops Linux basadas en Debian.

> Nota de alcance: el repositorio ya incluye un kit Windows/macOS en
> `windows-data-ai-kit/`. Si este repo se convierte formalmente en multi-OS,
> el nombre recomendado es `lab-bootstrap-tools`.

## Instalador general

Para instalar la base de trabajo en una laptop nueva:

```bash
sudo bash Scripts/install-linux-lab.sh
```

## Kit Windows/macOS

Para preparar una laptop Windows 10/11 para datos, IA, R/RStudio, video,
Markdown y herramientas academicas:

```text
windows-data-ai-kit/START-HERE.cmd
```

Lanzadores rapidos:

```text
windows-data-ai-kit/START-RECOMMENDED.cmd
windows-data-ai-kit/START-MAESTRIA.cmd
windows-data-ai-kit/START-BASE-ONLY.cmd
windows-data-ai-kit/START-ALL-EXTRAS.cmd
```

Para macOS:

```zsh
cd windows-data-ai-kit/macOS
chmod +x START-HERE-mac.command
./START-HERE-mac.command
```

La opcion recomendada para otra laptop nueva es `START-RECOMMENDED.cmd`.

Opciones frecuentes:

```bash
sudo bash Scripts/install-linux-lab.sh --with-containers
sudo bash Scripts/install-linux-lab.sh --with-video-runtime
sudo bash Scripts/install-linux-lab.sh --with-dev-toolchains --with-docker
```

## Comandos incluidos

- `lab-tool-check`: verifica herramientas, CLI y modulos Python.
- `laptop-audit`: diagnostico rapido de sistema.
- `mdread`: visor de Markdown con `glow`, `batcat`, `bat` o `less`.
- `new-data-project`: crea estructura reproducible para proyectos de datos.
- `dl`: descargas divididas con `aria2c`.
- `vt`: descarga/transcripcion de video.
- `transcribir-video`: acceso directo a transcripcion.

El instalador crea enlaces en `~/bin` cuando encuentra estos comandos.

## Estructura

```text
Scripts/
  install-linux-lab.sh
  lab-tool-check
  laptop-audit
  mdread
  new-data-project
  ai_context/linux_lab_context.md
download-tools/
  bin/dl
video-tools/
  bin/vt
  bin/transcribir-video
```

## Paquetes por proyecto

No se instalan globalmente paquetes Python que cambian mucho. Para datos por proyecto:

```bash
python3 -m venv .venv
. .venv/bin/activate
python -m pip install duckdb pyarrow polars jupyterlab
```

## Verificacion

Despues de instalar:

```bash
lab-tool-check
```
