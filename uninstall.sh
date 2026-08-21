#!/usr/bin/env bash
set -Eeuo pipefail
INSTALL_DIR="${BLUEGATE_THEME_DIR:-/etc/3x-ui/sub_templates/bluegate}"
DB_PATH="${XUI_DB_FOLDER:-/etc/x-ui}/x-ui.db"
[[ "${EUID}" -eq 0 ]] || { echo "Run as root"; exit 1; }

if [[ -d "${INSTALL_DIR}" ]]; then
  BACKUP="${INSTALL_DIR}.removed.$(date +%Y%m%d-%H%M%S)"
  mv "${INSTALL_DIR}" "${BACKUP}"
  echo "Theme moved to: ${BACKUP}"
fi

if [[ -f "${DB_PATH}" ]] && command -v sqlite3 >/dev/null 2>&1; then
  cp -a "${DB_PATH}" "${DB_PATH}.before-bluegate-uninstall.$(date +%Y%m%d-%H%M%S)"
  sqlite3 "${DB_PATH}" "UPDATE settings SET value='' WHERE key='subThemeDir' AND value='${INSTALL_DIR//\'/\'\'}';"
fi

if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files 2>/dev/null | grep -q '^x-ui\.service'; then
  systemctl restart x-ui
fi
echo "BlueGate theme disabled."
