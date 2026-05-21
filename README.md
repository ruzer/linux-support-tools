# Linux Support Tools

Herramientas utiles para preparar y mantener laptops Linux basadas en Debian.

## Instalador general

Para instalar la base de trabajo en una laptop nueva:

```bash
sudo bash Scripts/install-linux-lab.sh
```

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
