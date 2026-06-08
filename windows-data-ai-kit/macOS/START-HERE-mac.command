#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec /bin/zsh "$SCRIPT_DIR/scripts/install-mac-data-lab.sh"

