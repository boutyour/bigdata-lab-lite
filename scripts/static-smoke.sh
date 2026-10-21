#!/usr/bin/env bash
set -Eeuo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
required=(
  docker/runtime/Dockerfile
  docker/runtime/hadoop/entrypoint.sh
  docker/hive-postgres/Dockerfile
  compose.yaml
  profiles/8gb.yaml
  profiles/16gb.yaml
  profiles/plus.yaml
)
for f in "${required[@]}"; do test -s "$f" || { echo "missing: $f" >&2; exit 1; }; done
bash -n docker/runtime/hadoop/entrypoint.sh
bash -n scripts/check-host.sh
bash -n scripts/test-hdfs.sh
bash -n scripts/test-mapreduce.sh
bash -n scripts/test-hive.sh
bash -n scripts/test-hive-spark.sh
bash -n scripts/benchmark-images.sh
python3 - <<'PY'
from pathlib import Path
s=Path('compose.yaml').read_text()
checks={
 'hadoop target': 'target: hadoop',
 'spark target': 'target: spark',
 'official hive lite': 'image: apache/hive:4.2.1',
 'postgres hive image': 'image: bigdata-lab/hive-postgres:4.2.1',
}
for name, needle in checks.items():
    assert needle in s, f'{name} missing'
print('compose structural checks: OK')
PY
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  docker compose -f compose.yaml -f profiles/8gb.yaml config >/dev/null
  docker compose -f compose.yaml -f profiles/16gb.yaml config >/dev/null
  docker compose -f compose.yaml -f profiles/plus.yaml config >/dev/null
  echo 'docker compose config: OK'
else
  echo 'docker compose unavailable: static checks only'
fi
echo 'static smoke: OK'
