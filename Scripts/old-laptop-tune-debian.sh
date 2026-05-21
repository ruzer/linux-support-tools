#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
AUTOSTART_DIR="$TARGET_HOME/.config/autostart"

disable_autostart() {
  local name="$1"
  install -d -m 0755 -o "$TARGET_USER" -g "$TARGET_USER" "$AUTOSTART_DIR"
  {
    printf '[Desktop Entry]\n'
    printf 'Hidden=true\n'
  } > "$AUTOSTART_DIR/$name"
  chown "$TARGET_USER:$TARGET_USER" "$AUTOSTART_DIR/$name"
}

echo "Applying user startup tuning for $TARGET_USER..."

# These are useful on newer hardware, but costly on this Core 2 Duo + Intel Mobile 4 GPU.
disable_autostart "conky.desktop"
disable_autostart "picom.desktop"

# Accessibility helpers are disabled only at autostart. You can still launch them manually.
disable_autostart "magnus-autostart.desktop"
disable_autostart "onboard-autostart.desktop"
disable_autostart "orca-autostart.desktop"

# VM guest helper; harmless to disable on a physical laptop.
disable_autostart "spice-vdagent.desktop"

if command -v xfconf-query >/dev/null 2>&1; then
  if sudo -u "$TARGET_USER" xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null; then
    echo "Disabled Xfce window-manager compositing."
  else
    echo "Could not reach Xfce settings bus; autostart compositor override was still written."
  fi
fi

if [[ ${EUID} -eq 0 ]]; then
  echo "Applying system tuning..."
  install -d -m 0755 /etc/sysctl.d
  cat > /etc/sysctl.d/99-old-laptop.conf <<'SYSCTL'
# Conservative settings for older laptops with HDD storage and enough RAM.
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_background_ratio=5
vm.dirty_ratio=15
SYSCTL
  sysctl --system >/dev/null || true

  if command -v update-initramfs >/dev/null 2>&1; then
    update-initramfs -u || true
  fi
else
  echo
  echo "Skipped system tuning because this script was not run with sudo."
  echo "To apply system tuning too, run:"
  echo "  sudo bash $0"
fi

echo
echo "Done. Log out and back in to feel the startup/compositor changes."
echo
echo "To re-enable visual effects later, remove:"
echo "  $AUTOSTART_DIR/picom.desktop"
echo "  $AUTOSTART_DIR/conky.desktop"
