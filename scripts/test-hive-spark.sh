#!/usr/bin/env bash
set -Eeuo pipefail
COMPOSE=${1:?compose command required}
SERVICE=${2:-hive-full}

bash scripts/test-hive.sh "$COMPOSE" "$SERVICE"
$COMPOSE exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/07-hive-spark/read_hive_parquet.py
