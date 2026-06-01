#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  glances \
  mosh \
  autossh \
  monitoring-plugins-basic \
  monitoring-plugins-standard \
  iftop \
  nethogs \
  vnstat \
  sysstat \
  nmon \
  screen \
  prometheus-node-exporter

echo
echo "Herramientas de monitoreo instaladas."
echo "Comandos utiles:"
echo "  remote-monitor"
echo "  glances"
echo "  ssh usuario@servidor"
echo "  mosh usuario@servidor"
