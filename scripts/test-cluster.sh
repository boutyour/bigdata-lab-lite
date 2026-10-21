#!/usr/bin/env bash
set -Eeuo pipefail
COMPOSE=${1:?compose command required}

echo '=== HDFS DataNode report ==='
report=$($COMPOSE exec -T hadoop hdfs dfsadmin -report)
printf '%s
' "$report"

live=$(printf '%s
' "$report" | awk -F': ' '/Live datanodes \(/ {gsub(/\).*/, "", $2); print $2; exit}')
if [ -z "$live" ]; then
  echo 'ERROR: unable to determine number of live DataNodes' >&2
  exit 1
fi
if [ "$live" -lt 2 ]; then
  echo "ERROR: expected at least 2 live DataNodes, found $live" >&2
  exit 1
fi

echo "PASS: $live live DataNodes detected"
