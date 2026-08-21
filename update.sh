#!/usr/bin/env bash
set -Eeuo pipefail
if [[ -z "${BGT_REPO:-}" ]]; then
  echo "Usage: sudo BGT_REPO='USERNAME/bluegate-3xui-sub-theme' bash update.sh"
  exit 1
fi
export BGT_AUTO_SET="${BGT_AUTO_SET:-1}"
exec bash <(curl -fsSL "https://raw.githubusercontent.com/${BGT_REPO}/${BGT_BRANCH:-main}/install.sh")
