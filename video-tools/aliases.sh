# shellcheck shell=bash
# Carga este archivo con:
#   source "video-tools/aliases.sh"

VIDEO_TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$VIDEO_TOOLS_DIR/bin:$PATH"
vt() {
  "$VIDEO_TOOLS_DIR/bin/vt" "$@"
}
