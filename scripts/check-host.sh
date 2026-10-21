#!/usr/bin/env bash
set -euo pipefail
profile="${1:-8}"
case "$profile" in 8|16|plus) ;; *) echo 'Valid profiles: 8, 16, plus'; exit 2;; esac
command -v docker >/dev/null || { echo 'Docker not found'; exit 1; }
docker compose version >/dev/null || { echo 'Docker Compose plugin missing'; exit 1; }
docker info >/dev/null || { echo 'Docker daemon unavailable'; exit 1; }
echo "Docker OK; selected profile: $profile"
echo 'Host RAM:'
free -h 2>/dev/null || true
if [[ "$profile" == 8 ]]; then echo '8 Go: use only one stack at a time'; fi
