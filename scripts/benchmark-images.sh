#!/usr/bin/env bash
set -Eeuo pipefail
images=(
  "bigdata-lab/hadoop-lite:3.4.2"
  "bigdata-lab/spark-lite:3.5.7"
  "apache/hive:4.2.1"
  "bigdata-lab/hive-postgres:4.2.1"
)
printf '%-38s %12s %12s
' IMAGE SIZE_BYTES SIZE_HUMAN
printf '%-38s %12s %12s
' '--------------------------------------' '------------' '------------'
for img in "${images[@]}"; do
  if docker image inspect "$img" >/dev/null 2>&1; then
    bytes=$(docker image inspect "$img" --format '{{.Size}}')
    human=$(numfmt --to=iec-i --suffix=B "$bytes" 2>/dev/null || echo "$bytes")
    printf '%-38s %12s %12s
' "$img" "$bytes" "$human"
  else
    printf '%-38s %12s %12s
' "$img" '-' 'not-built'
  fi
done
printf '
Shared/local Docker storage:
'
docker system df 2>/dev/null || true
