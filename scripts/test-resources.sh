#!/usr/bin/env bash
set -Eeuo pipefail
COMPOSE=${1:?compose command required}

echo '=== Container status ==='
$COMPOSE ps -a

echo
echo '=== Resource snapshot ==='
ids=$($COMPOSE ps -q)
if [ -n "$ids" ]; then
  docker stats --no-stream $ids
fi

echo
echo '=== OOM / exit-state checks ==='
failed=0
for id in $ids; do
  name=$(docker inspect -f '{{.Name}}' "$id" | sed 's#^/##')
  running=$(docker inspect -f '{{.State.Running}}' "$id")
  oom=$(docker inspect -f '{{.State.OOMKilled}}' "$id")
  exit_code=$(docker inspect -f '{{.State.ExitCode}}' "$id")
  printf '%-30s running=%-5s oom=%-5s exit=%s
' "$name" "$running" "$oom" "$exit_code"
  if [ "$oom" = "true" ]; then
    echo "ERROR: $name was OOM-killed" >&2
    failed=1
  fi
  if [ "$running" != "true" ] && [ "$exit_code" != "0" ]; then
    echo "ERROR: $name exited unexpectedly with code $exit_code" >&2
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo 'PASS: no OOM kills or unexpected non-zero exits detected'
