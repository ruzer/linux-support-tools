#!/usr/bin/env bash
set -euo pipefail

export PATH="$PATH:/sbin:/usr/sbin"

sudo apt-get update
sudo apt-get install -y \
  python3-venv \
  python3-pip \
  pipx \
  python3-numpy \
  python3-pandas \
  python3-sklearn \
  python3-matplotlib \
  python3-seaborn \
  python3-openpyxl \
  python3-xlsxwriter \
  python3-statsmodels \
  jupyterlab \
  r-base \
  sqlite3 \
  nmap \
  ffuf \
  gobuster \
  nikto \
  sqlmap \
  tcpdump \
  tshark \
  wireshark \
  aircrack-ng \
  bettercap \
  john \
  fail2ban \
  openssh-server \
  net-tools \
  iperf3 \
  mtr-tiny \
  netcat-openbsd \
  wavemon \
  inetutils-ping \
  htop \
  btop \
  ncdu \
  smartmontools \
  lm-sensors \
  ufw

echo
echo "Instalacion terminada."
echo "Base: Python/R, datos medianos, notebooks, SQLite, red/pentest ligero y monitoreo."
echo
echo "Notas:"
echo "  - john, smartctl y ufw viven en /usr/sbin en Debian."
echo "  - duckdb, pyarrow y polars conviene instalarlos por proyecto en un venv."
echo
echo "Opcional si realmente necesitas SSH entrante:"
echo "  sudo systemctl enable --now ssh"
echo "  sudo ufw allow OpenSSH"
echo "  sudo ufw enable"
