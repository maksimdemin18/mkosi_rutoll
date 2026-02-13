#!/usr/bin/env bash
set -euo pipefail

echo "[+] Installing mkosi and base build dependencies on Ubuntu 24.04 (Noble)"
sudo apt-get update
sudo apt-get install -y mkosi systemd-container debootstrap ubuntu-keyring ubuntu-archive-keyring

echo "[+] Installing extra dependencies via 'mkosi dependencies' (recommended)"
sudo mkosi dependencies || true

echo "[+] Done. Now run: ./scripts/build.sh base"
