#!/usr/bin/env bash
set -Eeuo pipefail

THEME_NAME="bluegate"
INSTALL_DIR="${BLUEGATE_THEME_DIR:-/etc/3x-ui/sub_templates/${THEME_NAME}}"
REPO="${BGT_REPO:-}"
BRANCH="${BGT_BRANCH:-main}"
DB_PATH="${XUI_DB_FOLDER:-/etc/x-ui}/x-ui.db"
SELF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd || true)"
TMP_DIR=""
BACKUP_DIR=""

c_blue='\033[1;36m'; c_green='\033[1;32m'; c_yellow='\033[1;33m'; c_red='\033[1;31m'; c_reset='\033[0m'
info(){ echo -e "${c_blue}➜${c_reset} $*"; }
ok(){ echo -e "${c_green}✓${c_reset} $*"; }
warn(){ echo -e "${c_yellow}!${c_reset} $*"; }
die(){ echo -e "${c_red}✗${c_reset} $*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "Installer را با root اجرا کن: sudo bash install.sh"

cleanup(){ [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]] && rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

SOURCE_THEME=""
if [[ -f "${SELF_DIR}/theme/index.html" ]]; then
  SOURCE_THEME="${SELF_DIR}/theme"
  info "نصب از فایل‌های محلی repository"
else
  [[ -n "${REPO}" ]] || die "Repository مشخص نیست. مثال: BGT_REPO='USERNAME/bluegate-3xui-sub-theme' bash <(curl -fsSL https://raw.githubusercontent.com/USERNAME/bluegate-3xui-sub-theme/main/install.sh)"
  command -v curl >/dev/null 2>&1 || die "curl نصب نیست."
  command -v tar >/dev/null 2>&1 || die "tar نصب نیست."
  TMP_DIR="$(mktemp -d)"
  info "دریافت آخرین نسخه از GitHub: ${REPO}@${BRANCH}"
  curl -fL --retry 3 --connect-timeout 10 "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" -o "${TMP_DIR}/repo.tar.gz"
  tar -xzf "${TMP_DIR}/repo.tar.gz" -C "${TMP_DIR}"
  SOURCE_THEME="$(find "${TMP_DIR}" -maxdepth 3 -type f -path '*/theme/index.html' -printf '%h\n' | head -n1)"
  [[ -n "${SOURCE_THEME}" && -f "${SOURCE_THEME}/index.html" ]] || die "theme/index.html داخل repository پیدا نشد."
fi

mkdir -p "$(dirname "${INSTALL_DIR}")"
if [[ -d "${INSTALL_DIR}" ]]; then
  BACKUP_DIR="${INSTALL_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
  cp -a "${INSTALL_DIR}" "${BACKUP_DIR}"
  ok "بکاپ تم قبلی: ${BACKUP_DIR}"
fi

mkdir -p "${INSTALL_DIR}"
install -m 0644 "${SOURCE_THEME}/index.html" "${INSTALL_DIR}/index.html"
ok "تم نصب شد: ${INSTALL_DIR}"

# Optional safe auto-configuration for the default SQLite installation.
AUTO_SET="${BGT_AUTO_SET:-1}"
if [[ "${AUTO_SET}" == "1" && -f "${DB_PATH}" ]]; then
  if command -v sqlite3 >/dev/null 2>&1; then
    DB_BACKUP="${DB_PATH}.bluegate-theme-backup.$(date +%Y%m%d-%H%M%S)"
    cp -a "${DB_PATH}" "${DB_BACKUP}"
    info "بکاپ دیتابیس قبل از تغییر: ${DB_BACKUP}"

    # 3x-ui stores settings in settings(key,value). Update existing row, otherwise insert it.
    if sqlite3 "${DB_PATH}" "SELECT 1 FROM sqlite_master WHERE type='table' AND name='settings';" | grep -q 1; then
      ESCAPED_DIR="${INSTALL_DIR//\'/\'\'}"
      sqlite3 "${DB_PATH}" "BEGIN; UPDATE settings SET value='${ESCAPED_DIR}' WHERE key='subThemeDir'; INSERT INTO settings(key,value) SELECT 'subThemeDir','${ESCAPED_DIR}' WHERE NOT EXISTS (SELECT 1 FROM settings WHERE key='subThemeDir'); COMMIT;"
      ok "subThemeDir در دیتابیس روی ${INSTALL_DIR} تنظیم شد."
    else
      warn "جدول settings پیدا نشد؛ فقط فایل تم نصب شد."
    fi
  else
    warn "sqlite3 روی سرور نصب نیست؛ فایل تم نصب شد ولی تنظیم خودکار انجام نشد."
  fi
else
  warn "دیتابیس SQLite پیش‌فرض پیدا نشد یا BGT_AUTO_SET=0 است؛ تنظیم Sub Theme Directory را دستی انجام بده."
fi

if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files 2>/dev/null | grep -q '^x-ui\.service'; then
  systemctl restart x-ui
  sleep 1
  if systemctl is-active --quiet x-ui; then ok "سرویس x-ui ری‌استارت شد."; else warn "x-ui بعد از restart active گزارش نشد؛ systemctl status x-ui را بررسی کن."; fi
else
  warn "systemd service با نام x-ui پیدا نشد. اگر Docker استفاده می‌کنی container را restart کن."
fi

echo
ok "BlueGate Subscription Theme آماده است."
echo "Sub Theme Directory: ${INSTALL_DIR}"
echo "برای تست صفحه HTML لینک ساب را با ?html=1 باز کن."
echo
echo "اگر تم نمایش داده نشد:"
echo "  Settings → Subscription → Information → Sub Theme Directory"
echo "  ${INSTALL_DIR}"
