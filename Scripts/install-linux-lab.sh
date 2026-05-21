#!/usr/bin/env bash
set -euo pipefail

export PATH="$PATH:/sbin:/usr/sbin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
USER_BIN="$TARGET_HOME/bin"

WITH_CONTAINERS=0
WITH_DOCKER=0
WITH_DEV_TOOLCHAINS=0
WITH_VIDEO_RUNTIME=0
WITH_OLD_LAPTOP_TUNE=0
ASSUME_YES=1

usage() {
  cat <<EOF
Uso:
  sudo bash "$SCRIPT_DIR/install-linux-lab.sh" [opciones]

Instala la base reproducible del laboratorio Linux:
  - Python/R/datos/notebooks
  - herramientas CLI de sistema y terminal
  - red/pentest ligero
  - monitoreo/auditoria
  - scripts locales: lab-tool-check, laptop-audit, mdread, new-data-project
  - CLIs locales si existen: vt/transcribir-video y dl

Opciones:
  --with-containers       Instala podman.
  --with-docker           Instala docker.io y docker-compose; habilita docker.
  --with-dev-toolchains   Instala clang, cmake, gdb, Go, Rust, Java, etc.
  --with-video-runtime    Prepara el venv de video-tools para transcripcion.
  --old-laptop-tune       Aplica tuning conservador para laptop vieja/Xfce.
  --no-assume-yes         No fuerza -y en apt.
  -h, --help              Muestra esta ayuda.

Ejemplos:
  sudo bash "$SCRIPT_DIR/install-linux-lab.sh"
  sudo bash "$SCRIPT_DIR/install-linux-lab.sh" --with-containers --with-video-runtime
  sudo bash "$SCRIPT_DIR/install-linux-lab.sh" --with-dev-toolchains --with-docker
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-containers)
      WITH_CONTAINERS=1
      ;;
    --with-docker)
      WITH_DOCKER=1
      ;;
    --with-dev-toolchains)
      WITH_DEV_TOOLCHAINS=1
      ;;
    --with-video-runtime)
      WITH_VIDEO_RUNTIME=1
      ;;
    --old-laptop-tune)
      WITH_OLD_LAPTOP_TUNE=1
      ;;
    --no-assume-yes)
      ASSUME_YES=0
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Opcion desconocida: $1"
      usage
      exit 2
      ;;
  esac
  shift
done

if [[ ${EUID} -ne 0 ]]; then
  echo "Ejecuta este script con sudo:"
  echo "  sudo bash \"$SCRIPT_DIR/install-linux-lab.sh\""
  exit 1
fi

apt_install() {
  local apt_yes=()
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    apt_yes=(-y)
  fi
  apt-get install "${apt_yes[@]}" "$@"
}

install_supported_packages() {
  local base_packages=(
    aria2
    aircrack-ng
    bat
    bettercap
    btop
    build-essential
    ca-certificates
    curl
    fail2ban
    fd-find
    ffmpeg
    ffuf
    fzf
    git
    glow
    gobuster
    htop
    inetutils-ping
    iperf3
    john
    jq
    jupyterlab
    lm-sensors
    mtr-tiny
    ncdu
    net-tools
    netcat-openbsd
    nikto
    nmap
    openssh-client
    openssh-server
    pipx
    pkg-config
    python3-dev
    python3-matplotlib
    python3-numpy
    python3-openpyxl
    python3-pandas
    python3-pip
    python3-scipy
    python3-seaborn
    python3-sklearn
    python3-statsmodels
    python3-venv
    python3-xlsxwriter
    r-base
    ripgrep
    shellcheck
    shfmt
    smartmontools
    sqlite3
    sqlmap
    tcpdump
    tealdeer
    tmux
    tree
    tshark
    ufw
    unzip
    wavemon
    wget
    wireshark
    yq
    zip
  )

  local dev_packages=(
    cargo
    clang
    clang-format
    cmake
    default-jdk
    direnv
    g++
    gdb
    gh
    golang-go
    make
    neovim
    postgresql-client
    rustc
    valgrind
  )

  echo "Actualizando indices apt..."
  apt-get update

  echo "Instalando base Linux Lab..."
  apt_install "${base_packages[@]}"

  if [[ "$WITH_DEV_TOOLCHAINS" -eq 1 ]]; then
    echo "Instalando toolchains de desarrollo..."
    apt_install "${dev_packages[@]}"
  fi

  if [[ "$WITH_CONTAINERS" -eq 1 ]]; then
    echo "Instalando podman..."
    apt_install podman
  fi

  if [[ "$WITH_DOCKER" -eq 1 ]]; then
    echo "Instalando docker.io..."
    apt_install docker.io docker-compose
    systemctl enable --now docker || true
    usermod -aG docker "$TARGET_USER" || true
  fi
}

link_if_exists() {
  local source_path="$1"
  local command_name="$2"

  if [[ -e "$source_path" ]]; then
    ln -sfn "$source_path" "$USER_BIN/$command_name"
    chown -h "$TARGET_USER:$TARGET_USER" "$USER_BIN/$command_name"
    echo "OK: $command_name -> $source_path"
  else
    echo "Aviso: no existe $source_path; se omite $command_name."
  fi
}

install_local_clis() {
  echo "Instalando comandos locales en $USER_BIN..."
  install -d -m 0755 -o "$TARGET_USER" -g "$TARGET_USER" "$USER_BIN"

  link_if_exists "$SCRIPT_DIR/lab-tool-check" "lab-tool-check"
  link_if_exists "$SCRIPT_DIR/laptop-audit" "laptop-audit"
  link_if_exists "$SCRIPT_DIR/mdread" "mdread"
  link_if_exists "$SCRIPT_DIR/new-data-project" "new-data-project"

  link_if_exists "$WORKSPACE_DIR/video-tools/bin/vt" "vt"
  link_if_exists "$WORKSPACE_DIR/video-tools/bin/transcribir-video" "transcribir-video"
  link_if_exists "$WORKSPACE_DIR/download-tools/bin/dl" "dl"

  local user_path_line="export PATH=\"\$HOME/bin:\$PATH\""
  if ! grep -F "$user_path_line" "$TARGET_HOME/.bashrc" >/dev/null 2>&1; then
    printf '\n# Local user commands\n%s\n' "$user_path_line" >> "$TARGET_HOME/.bashrc"
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"
  fi
}

configure_user_defaults() {
  echo "Configurando defaults de usuario..."
  sudo -u "$TARGET_USER" git config --global init.defaultBranch main || true
  sudo -u "$TARGET_USER" git config --global pull.ff only || true

  if command -v nvim >/dev/null 2>&1; then
    sudo -u "$TARGET_USER" git config --global core.editor nvim || true
  fi

  sudo -u "$TARGET_USER" python3 -m pipx ensurepath || true
}

install_video_runtime() {
  local vt_bin="$WORKSPACE_DIR/video-tools/bin/vt"

  if [[ ! -x "$vt_bin" ]]; then
    echo "Aviso: no existe $vt_bin; se omite runtime de video."
    return 0
  fi

  if command -v uv >/dev/null 2>&1; then
    sudo -u "$TARGET_USER" "$vt_bin" install
    return 0
  fi

  echo "uv no esta instalado; preparando runtime de video con venv + pip."
  local root="$WORKSPACE_DIR/video-tools"
  local venv="$root/runtime/venv"
  install -d -m 0755 -o "$TARGET_USER" -g "$TARGET_USER" "$root/runtime"
  sudo -u "$TARGET_USER" python3 -m venv "$venv"
  sudo -u "$TARGET_USER" "$venv/bin/python" -m pip install --upgrade pip
  sudo -u "$TARGET_USER" "$venv/bin/python" -m pip install yt-dlp faster-whisper "numpy<2.3"
}

apply_old_laptop_tune() {
  if [[ -f "$SCRIPT_DIR/old-laptop-tune-debian.sh" ]]; then
    bash "$SCRIPT_DIR/old-laptop-tune-debian.sh"
  else
    echo "Aviso: falta old-laptop-tune-debian.sh; se omite tuning."
  fi
}

print_summary() {
  cat <<EOF

Instalacion terminada.

Comandos principales:
  lab-tool-check
  laptop-audit
  mdread README.md
  new-data-project mi_proyecto
  dl "URL"
  vt transcribe "URL" es

Notas:
  - pyarrow, duckdb y polars se mantienen por proyecto en .venv.
  - SSH, UFW y fail2ban quedan instalados, pero no se habilitan reglas entrantes aqui.
  - Si instalaste Docker, cierra sesion y vuelve a entrar para aplicar el grupo docker.

Verifica el entorno con:
  lab-tool-check
EOF
}

install_supported_packages
install_local_clis
configure_user_defaults

if [[ "$WITH_VIDEO_RUNTIME" -eq 1 ]]; then
  install_video_runtime
fi

if [[ "$WITH_OLD_LAPTOP_TUNE" -eq 1 ]]; then
  apply_old_laptop_tune
fi

print_summary
