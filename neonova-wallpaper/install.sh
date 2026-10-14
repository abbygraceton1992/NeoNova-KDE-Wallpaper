#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
DEST="${HOME}/.local/share/plasma/wallpapers/com.local.neonova"

chmod +x "${ROOT}/contents/code/wallpaper_animation.sh"
mkdir -p "${HOME}/.local/share/plasma/wallpapers"
rm -rf "${DEST}"
cp -a "${ROOT}" "${DEST}"

echo "Installed to ${DEST}"
echo "Select wallpaper type: Neonova"
echo "If it does not appear: kbuildsycoca6 --noincremental && systemctl --user restart plasma-plasmashell.service"
echo "Log: journalctl --user -f -t plasmashell | grep neonova"
