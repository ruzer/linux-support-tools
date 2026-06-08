#!/bin/zsh
set -euo pipefail

INSTALL_ACADEMIC=0
INSTALL_LOCAL_AI=0
INSTALL_AUTOMATION=0
INSTALL_GEO=0
INSTALL_SUPPORT=0
INSTALL_ALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --academic) INSTALL_ACADEMIC=1 ;;
    --local-ai) INSTALL_LOCAL_AI=1 ;;
    --automation) INSTALL_AUTOMATION=1 ;;
    --geo) INSTALL_GEO=1 ;;
    --support) INSTALL_SUPPORT=1 ;;
    --masters|--maestria) INSTALL_ACADEMIC=1; INSTALL_LOCAL_AI=1; INSTALL_SUPPORT=1 ;;
    --all) INSTALL_ALL=1; INSTALL_ACADEMIC=1; INSTALL_LOCAL_AI=1; INSTALL_AUTOMATION=1; INSTALL_GEO=1; INSTALL_SUPPORT=1 ;;
    --no-menu) ;;
    *) echo "Opcion desconocida: $1"; exit 2 ;;
  esac
  shift
done

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-mac-$(date +%Y%m%d-%H%M%S).log"

log() {
  echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"
}

ask_menu() {
  echo
  echo "Extras opcionales macOS"
  echo "1) Recomendado: academico/datos + IA local"
  echo "2) Todo: recomendado + automatizacion/geodatos"
  echo "3) Solo base"
  echo "4) Personalizado"
  echo "5) Maestria: IA + programacion + mineria de datos + soporte"
  echo
  read "choice?Elige 1, 2, 3 o 4: "
  case "$choice" in
    1) INSTALL_ACADEMIC=1; INSTALL_LOCAL_AI=1; INSTALL_SUPPORT=1 ;;
    2) INSTALL_ALL=1; INSTALL_ACADEMIC=1; INSTALL_LOCAL_AI=1; INSTALL_AUTOMATION=1; INSTALL_GEO=1; INSTALL_SUPPORT=1 ;;
    3) ;;
    4)
      read "ans?Academico/datos open source? [s/N]: "; [[ "$ans" =~ ^[sSyY] ]] && INSTALL_ACADEMIC=1
      read "ans?Apps IA locales? [s/N]: "; [[ "$ans" =~ ^[sSyY] ]] && INSTALL_LOCAL_AI=1
      read "ans?Soporte tecnico/utilidades? [s/N]: "; [[ "$ans" =~ ^[sSyY] ]] && INSTALL_SUPPORT=1
      read "ans?Geodatos? [s/N]: "; [[ "$ans" =~ ^[sSyY] ]] && INSTALL_GEO=1
      read "ans?Automatizacion/Docker? [s/N]: "; [[ "$ans" =~ ^[sSyY] ]] && INSTALL_AUTOMATION=1
      ;;
    5) INSTALL_ACADEMIC=1; INSTALL_LOCAL_AI=1; INSTALL_SUPPORT=1 ;;
    *) echo "Opcion no reconocida; se instalara solo base." ;;
  esac
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

brew_install() {
  for pkg in "$@"; do
    if brew list --formula "$pkg" >/dev/null 2>&1; then
      log "Already installed formula: $pkg"
    else
      log "Installing formula: $pkg"
      brew install "$pkg" | tee -a "$LOG_FILE"
    fi
  done
}

brew_cask_install() {
  for pkg in "$@"; do
    if brew list --cask "$pkg" >/dev/null 2>&1; then
      log "Already installed cask: $pkg"
    else
      log "Installing cask: $pkg"
      brew install --cask "$pkg" | tee -a "$LOG_FILE"
    fi
  done
}

setup_python_env() {
  log "Creating/updating conda env: data"
  if ! command -v conda >/dev/null 2>&1; then
    eval "$(/opt/homebrew/bin/conda shell.zsh hook 2>/dev/null || /usr/local/bin/conda shell.zsh hook 2>/dev/null || "$HOME/miniforge3/bin/conda" shell.zsh hook 2>/dev/null || true)"
  fi
  conda config --add channels conda-forge || true
  conda config --set channel_priority strict || true
  if conda env list | awk '{print $1}' | grep -qx data; then
    conda install -y -n data python=3.12 pandas numpy scipy matplotlib seaborn scikit-learn jupyterlab ipykernel statsmodels plotly openpyxl xlrd sqlalchemy requests beautifulsoup4 lxml ffmpeg
  else
    conda create -y -n data python=3.12 pandas numpy scipy matplotlib seaborn scikit-learn jupyterlab ipykernel statsmodels plotly openpyxl xlrd sqlalchemy requests beautifulsoup4 lxml ffmpeg
  fi
  conda run -n data python -m pip install --upgrade pip openai anthropic langchain llama-index notebook yt-dlp faster-whisper "numpy<2.3" markitdown openai-whisper
  conda run -n data python -m ipykernel install --user --name data --display-name "Python (data)"
}

install_media_tools() {
  log "Installing local media tools"
  mkdir -p "$HOME/Tools"
  if [[ -d "$ROOT/../tools/media-tools" ]]; then
    rm -rf "$HOME/Tools/media-tools"
    cp -R "$ROOT/../tools/media-tools" "$HOME/Tools/media-tools"
  fi
  mkdir -p "$HOME/bin"
  cat > "$HOME/bin/transcribir-video" <<'EOF'
#!/bin/zsh
set -euo pipefail
ROOT="$HOME/Tools/media-tools"
OUT="$ROOT/output"
mkdir -p "$OUT"
URL="${1:-}"
LANG="${2:-es}"
MODEL="${3:-small}"
if [[ -z "$URL" || "$URL" == "-h" || "$URL" == "--help" ]]; then
  echo 'Uso: transcribir-video URL [idioma] [modelo]'
  exit 0
fi
yt-dlp --restrict-filenames --no-playlist -x --audio-format mp3 -o "$OUT/%(title).120s-%(id)s.%(ext)s" "$URL"
AUDIO="$(ls -t "$OUT"/*.mp3 2>/dev/null | head -n 1)"
if [[ -z "$AUDIO" ]]; then
  echo "No se encontro audio descargado."
  exit 1
fi
conda run -n data python "$ROOT/transcribir_audio.py" "$AUDIO" --language "$LANG" --model "$MODEL"
EOF
  cat > "$HOME/bin/vt" <<'EOF'
#!/bin/zsh
set -euo pipefail
case "${1:-}" in
  transcribe|transcribir)
    shift
    exec "$HOME/bin/transcribir-video" "$@"
    ;;
  where|donde)
    echo "$HOME/Tools/media-tools"
    echo "$HOME/Tools/media-tools/output"
    ;;
  ""|help|-h|--help)
    echo 'Uso: vt transcribe URL [idioma] [modelo]'
    ;;
  *)
    echo "Comando desconocido: ${1:-}"
    exit 2
    ;;
esac
EOF
  cat > "$HOME/bin/dl" <<'EOF'
#!/bin/zsh
set -euo pipefail
OUT="$HOME/Tools/media-tools/downloads"
mkdir -p "$OUT"
if [[ "${1:-}" == "where" ]]; then
  echo "$OUT"
  exit 0
fi
aria2c --dir="$OUT" --continue=true --max-connection-per-server=8 --split=8 --min-split-size=1M "$@"
EOF
  cat > "$HOME/bin/to-markdown" <<'EOF'
#!/bin/zsh
set -euo pipefail
ROOT="$HOME/Tools/media-tools"
INPUT="${1:-}"
OUTPUT="${2:-}"
if [[ -z "$INPUT" || "$INPUT" == "-h" || "$INPUT" == "--help" ]]; then
  echo 'Uso: to-markdown ARCHIVO [SALIDA.md]'
  exit 0
fi
if [[ -n "$OUTPUT" ]]; then
  conda run -n data python "$ROOT/convert_to_markdown.py" "$INPUT" -o "$OUTPUT"
else
  conda run -n data python "$ROOT/convert_to_markdown.py" "$INPUT"
fi
EOF
  chmod +x "$HOME/bin/vt" "$HOME/bin/transcribir-video" "$HOME/bin/dl" "$HOME/bin/to-markdown"
  if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
    printf '\n# Local user commands\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.zshrc"
  fi
}

ask_menu
ensure_homebrew
brew update

brew_install git curl wget aria2 ffmpeg yt-dlp pandoc jq ripgrep fzf bat tree tmux gh node python@3.12 r quarto ollama
brew_cask_install miniforge
brew_cask_install google-chrome visual-studio-code pycharm-ce rstudio libreoffice zotero obsidian rectangle iterm2 stats

if [[ "$INSTALL_ACADEMIC" == "1" ]]; then
  brew_cask_install knime orange calibre joplin panwriter inkscape gephi jasp jamovi
  brew_install dvc mlflow
fi

if [[ "$INSTALL_LOCAL_AI" == "1" ]]; then
  brew_cask_install anythingllm jan lm-studio
  brew_install open-webui
fi

if [[ "$INSTALL_GEO" == "1" ]]; then
  brew_cask_install qgis
fi

if [[ "$INSTALL_AUTOMATION" == "1" ]]; then
  brew_cask_install docker
  npm install -g n8n node-red
fi

if [[ "$INSTALL_SUPPORT" == "1" ]]; then
  brew_install smartmontools nmap
  brew_cask_install stats appcleaner rustdesk tailscale wireguard viscosity vlc obs handbrake audacity gimp balenaetcher syncthing localsend keka
fi

setup_python_env
install_media_tools

log "Done. Restart terminal, then test: conda activate data; jupyter lab"
