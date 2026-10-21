#!/usr/bin/env bash
set -Eeuo pipefail
COMPOSE=${1:?compose command required}
SERVICE=${2:-hive-lite}

echo '[1/3] Preparing HDFS directories for Hive'
$COMPOSE exec -T hadoop hdfs dfs -mkdir -p /user/hive/warehouse /tp/hive/sales
$COMPOSE exec -T hadoop hdfs dfs -put -f /workspace/datasets/sales.csv /tp/hive/sales/sales.csv

echo '[2/3] Waiting for HiveServer2'
for i in $(seq 1 30); do
  if $COMPOSE exec -T "$SERVICE" beeline -u 'jdbc:hive2://localhost:10000/default' -e 'SHOW DATABASES;' >/dev/null 2>&1; then
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo 'HiveServer2 did not become ready' >&2
    exit 1
  fi
  sleep 3
done

echo '[3/3] Running TP06 SQL smoke test'
$COMPOSE exec -T "$SERVICE" beeline -u 'jdbc:hive2://localhost:10000/default' -f /workspace/tp/06-hive/tp06.sql
