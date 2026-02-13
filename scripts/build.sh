#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-}"
if [[ -z "$PROFILE" ]]; then
  echo "Usage: $0 <profile>"
  echo
  echo "Main profiles: base controller app turnpike dispatcher docker"
  echo "Layout profiles: base-root-home base-root-var"
  exit 2
fi

echo "[+] Building profile: $PROFILE"
mkosi build --profile "$PROFILE"
echo "[+] Done. See ./mkosi.output/"
