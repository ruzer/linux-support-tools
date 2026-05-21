# shellcheck shell=bash
# Carga este archivo con:
#   source "download-tools/aliases.sh"

DOWNLOAD_TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$DOWNLOAD_TOOLS_DIR/bin:$PATH"
dl() {
  "$DOWNLOAD_TOOLS_DIR/bin/dl" "$@"
}
