#!/usr/bin/env bash
set -Eeuo pipefail

PROFILE=${1:?profile required: 8, 16 or plus}
COMPOSE=${2:?compose command required}

case "$PROFILE" in
  8|16|plus) ;;
  *) echo "Invalid profile: $PROFILE" >&2; exit 2 ;;
esac

down_all() {
  $COMPOSE --profile hadoop --profile spark --profile hive-lite --profile hive-full --profile cluster down || true
}

trap down_all EXIT

echo "============================================================"
echo " BigData-Lab student validation — PROFILE=$PROFILE"
echo "============================================================"

echo '[0] Pulling prebuilt images'
$COMPOSE --profile hadoop --profile spark --profile hive-lite --profile hive-full --profile cluster pull

if [ "$PROFILE" = "8" ]; then
  echo
  echo '[1/3] Hadoop/HDFS/MapReduce — sequential 8 GB mode'
  down_all
  $COMPOSE --profile hadoop up -d hadoop
  bash scripts/wait-student-service.sh "$COMPOSE" hadoop 180
  bash scripts/test-hdfs.sh "$COMPOSE"
  bash scripts/test-mapreduce.sh "$COMPOSE"
  bash scripts/test-resources.sh "$COMPOSE"

  echo
  echo '[2/3] Spark — sequential 8 GB mode'
  down_all
  $COMPOSE --profile spark up -d spark
  bash scripts/wait-student-service.sh "$COMPOSE" spark 90
  $COMPOSE exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/03-spark-rdd/wordcount.py
  $COMPOSE exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/04-spark-sql/analytics.py
  bash scripts/test-resources.sh "$COMPOSE"

  echo
  echo '[3/3] Hive Lite + Hadoop — sequential 8 GB mode'
  down_all
  $COMPOSE --profile hadoop --profile hive-lite up -d hadoop hive-lite
  bash scripts/test-hive.sh "$COMPOSE" hive-lite
  bash scripts/test-resources.sh "$COMPOSE"

else
  echo
  echo '[1/2] Integrated Hadoop + Spark + Hive stack'
  down_all
  $COMPOSE --profile hadoop --profile spark --profile hive-full up -d hadoop spark postgres metastore hive-full
  bash scripts/wait-student-service.sh "$COMPOSE" hadoop 180
  bash scripts/test-hdfs.sh "$COMPOSE"
  bash scripts/test-mapreduce.sh "$COMPOSE"
  $COMPOSE exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/03-spark-rdd/wordcount.py
  $COMPOSE exec -T spark spark-submit --master 'local[2]' --driver-memory 1g /workspace/tp/04-spark-sql/analytics.py
  bash scripts/test-hive-spark.sh "$COMPOSE" hive-full
  bash scripts/test-resources.sh "$COMPOSE"

  if [ "$PROFILE" = "plus" ]; then
    echo
    echo '[2/2] Multi-DataNode cluster validation'
    $COMPOSE --profile hadoop --profile cluster up -d hadoop worker2
    sleep 12
    bash scripts/test-cluster.sh "$COMPOSE"
    bash scripts/test-resources.sh "$COMPOSE"
  else
    echo '[2/2] Cluster extension skipped for 16 GB profile'
  fi
fi

echo
echo "PASS: all student tests completed successfully for PROFILE=$PROFILE"
trap - EXIT
down_all
