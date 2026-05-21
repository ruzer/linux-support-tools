#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script with sudo:"
  echo "  sudo bash $0"
  exit 1
fi

DEV_USER="${SUDO_USER:-$USER}"

BASE_PACKAGES=(
  build-essential
  ca-certificates
  clang
  clang-format
  cmake
  curl
  direnv
  fd-find
  fzf
  gdb
  gh
  git
  gnupg
  golang-go
  jq
  lsb-release
  make
  neovim
  pipx
  pkg-config
  postgresql-client
  python3-dev
  python3-pip
  python3-venv
  ripgrep
  shellcheck
  shfmt
  sqlite3
  tmux
  tree
  unzip
  valgrind
  wget
  yq
  zip
  default-jdk
  rustc
  cargo
)

DOCKER_PACKAGES=(
  docker.io
  docker-compose
)

echo "Updating package indexes..."
apt update

echo "Installing developer baseline..."
apt install -y "${BASE_PACKAGES[@]}"

echo "Installing Docker and Compose..."
apt install -y "${DOCKER_PACKAGES[@]}"
systemctl enable --now docker || true
usermod -aG docker "${DEV_USER}" || true

echo "Applying Git defaults for ${DEV_USER}..."
sudo -u "${DEV_USER}" git config --global init.defaultBranch main
sudo -u "${DEV_USER}" git config --global pull.ff only
sudo -u "${DEV_USER}" git config --global core.editor nvim

echo "Ensuring pipx user path is configured..."
sudo -u "${DEV_USER}" python3 -m pipx ensurepath || true

echo
echo "Done."
echo
echo "Next manual steps:"
echo "1. Log out and back in so Docker group membership takes effect."
echo "2. Set your Git identity if needed:"
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"you@example.com\""
echo "3. Authenticate GitHub CLI if you use GitHub:"
echo "   gh auth login"
echo "4. Optional modern Python package manager:"
echo "   pipx install uv"
echo "5. Optional VS Code: download the Debian .deb from https://code.visualstudio.com/Download"
