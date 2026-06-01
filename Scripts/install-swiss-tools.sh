#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y \
  gsmartcontrol \
  gnome-disk-utility \
  f3 \
  clonezilla \
  partclone \
  fsarchiver \
  borgbackup \
  restic \
  rclone \
  clamav \
  clamtk \
  rkhunter \
  chkrootkit \
  lynis \
  keepassxc

sudo apt-get install -y \
  sleuthkit \
  autopsy \
  ewf-tools \
  afflib-tools \
  dc3dd \
  dcfldd \
  dislocker \
  libbde-utils \
  libvshadow-utils \
  xmount \
  guymager \
  hashdeep \
  ssdeep \
  yara \
  binwalk \
  foremost \
  scalpel \
  chntpw \
  safecopy \
  plaso

echo
echo "Herramientas extra instaladas."
echo "Recomendado despues:"
echo "  sudo freshclam"
echo "  rescue-toolbox"
