#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Uso: $0 URL [idioma]"
  echo "Ejemplo: $0 https://www.youtube.com/watch?v=... es"
  exit 0
fi

URL="$1"
LANGUAGE="${2:-es}"
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
ROOT_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
OUT_DIR="$ROOT_DIR/output"
VENV_PY="$ROOT_DIR/runtime/venv/bin/python"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Falta '$1'. Instala dependencias con:"
    echo "  sudo apt install -y yt-dlp ffmpeg"
    exit 1
  fi
}

require_cmd yt-dlp
require_cmd ffmpeg

mkdir -p "$OUT_DIR"

echo "Descargando audio..."
yt-dlp \
  --restrict-filenames \
  --no-playlist \
  -x \
  --audio-format mp3 \
  -o "$OUT_DIR/%(title).120s-%(id)s.%(ext)s" \
  "$URL"

AUDIO_FILE="$(find "$OUT_DIR" -maxdepth 1 -type f -name '*.mp3' -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d' ' -f2-)"

if [[ -z "${AUDIO_FILE:-}" ]]; then
  echo "No se encontro el audio descargado."
  exit 1
fi

if [[ ! -x "$VENV_PY" ]]; then
  echo "No existe el entorno Python: $VENV_PY"
  echo "Crealo con: $ROOT_DIR/bin/instalar-python.sh"
  exit 1
fi

if ! "$VENV_PY" -c "import faster_whisper" >/dev/null 2>&1; then
  echo "Falta faster-whisper en el entorno local."
  echo "Cuando haya red, ejecuta:"
  echo "  $ROOT_DIR/bin/instalar-python.sh"
  exit 1
fi

echo "Transcribiendo: $AUDIO_FILE"
"$VENV_PY" "$ROOT_DIR/bin/transcribir_audio.py" "$AUDIO_FILE" --language "$LANGUAGE"
