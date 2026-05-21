#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  jupyterlab \
  python3-openpyxl \
  python3-xlsxwriter \
  python3-statsmodels

echo
echo "Paquetes Debian de datos instalados."
echo "Para DuckDB, PyArrow y Polars usa un venv de proyecto:"
echo "  python3 -m venv .venv"
echo "  . .venv/bin/activate"
echo "  python -m pip install duckdb pyarrow polars"
