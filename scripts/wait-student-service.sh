#!/usr/bin/env bash
set -Eeuo pipefail
COMPOSE=${1:?compose command required}
SERVICE=${2:?service required}
TIMEOUT=${3:-120}

id=$($COMPOSE ps -q "$SERVICE")
if [ -z "$id" ]; then
  echo "ERROR: service $SERVICE has no container" >&2
  exit 1
fi

start=$(date +%s)
while true; do
  running=$(docker inspect -f '{{.State.Running}}' "$id")
  health=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$id")
  if [ "$running" != "true" ]; then
    echo "ERROR: service $SERVICE stopped while waiting" >&2
    $COMPOSE logs --tail=100 "$SERVICE" || true
    exit 1
  fi
  if [ "$health" = "healthy" ] || [ "$health" = "none" ]; then
    echo "Service $SERVICE ready (health=$health)"
    exit 0
  fi
  now=$(date +%s)
  if [ $((now-start)) -ge "$TIMEOUT" ]; then
    echo "ERROR: timeout waiting for $SERVICE (health=$health)" >&2
    $COMPOSE logs --tail=100 "$SERVICE" || true
    exit 1
  fi
  sleep 3
done
