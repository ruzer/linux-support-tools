# Video Tools

Herramienta local para descargar audio de videos y transcribirlo.

## Estado actual

En esta maquina ya estan disponibles:

- `yt-dlp`
- `ffmpeg`
- `faster-whisper`

No hace falta correr ningun comando con `sudo` ahora.

## Estructura

- `bin/`: comandos.
- `runtime/venv/`: entorno Python local.
- `cache/uv/`: cache de `uv`.
- `output/`: audios, textos y subtitulos generados.

## Uso rapido

```bash
vt transcribe "URL_DEL_VIDEO" es
```

Tambien puedes usar el comando directo:

```bash
transcribir-video "URL_DEL_VIDEO" es
```

Los resultados se guardan en:

```bash
/home/Ruzer/Dev Projects/video-tools/output
```

## Activar comandos

El archivo `~/.bashrc` ya carga `video-tools/aliases.sh`, asi que en una terminal nueva puedes usar `vt` y `transcribir-video`.

En la terminal actual, si todavia no los reconoce:

```bash
source "/home/Ruzer/Dev Projects/video-tools/aliases.sh"
```

## Reinstalar o reparar

Si alguna vez se borra el entorno Python local:

```bash
"/home/Ruzer/Dev Projects/video-tools/bin/vt" install
```

Si `yt-dlp` o `ffmpeg` faltan en otra maquina:

```bash
sudo apt install -y yt-dlp ffmpeg
```

## Notas

- La primera transcripcion puede tardar porque `faster-whisper` descarga el modelo Whisper.
- Se usa `numpy<2.3` por compatibilidad con esta CPU.
