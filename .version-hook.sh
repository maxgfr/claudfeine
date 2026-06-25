#!/usr/bin/env bash
# .version-hook.sh — called by semantic-release (@semantic-release/exec prepareCmd)
# to stamp the released version into the scripts before the GitHub release is cut.
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Error: version number required" >&2
  exit 1
fi
NEW="$1"

sed -i.bak "s/^FEINE_VERSION=\".*\"/FEINE_VERSION=\"${NEW}\"/" claudfeine && rm -f claudfeine.bak
sed -i.bak "s/\$script:FeineVersion = '.*'/\$script:FeineVersion = '${NEW}'/" windows/_feine.ps1 && rm -f windows/_feine.ps1.bak

echo "Injected version ${NEW} into claudfeine and windows/_feine.ps1"
