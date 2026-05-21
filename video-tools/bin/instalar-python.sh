#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$ROOT/runtime/venv"
CACHE="$ROOT/cache/uv"

UV_CACHE_DIR="$CACHE" uv venv "$VENV"
UV_CACHE_DIR="$CACHE" uv pip install --python "$VENV/bin/python" yt-dlp faster-whisper "numpy<2.3"

echo "Listo. Ahora puedes usar:"
echo "  $ROOT/bin/vt transcribe URL es"
