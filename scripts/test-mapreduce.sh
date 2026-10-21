#!/usr/bin/env bash
set -Eeuo pipefail
compose=$1
read -r -a cmd <<< "$compose"
"${cmd[@]}" exec -T hadoop hdfs dfs -mkdir -p /tp/mapreduce
"${cmd[@]}" exec -T hadoop hdfs dfs -put -f /workspace/datasets/words.txt /tp/mapreduce/input.txt
"${cmd[@]}" exec -T hadoop hdfs dfs -rm -r -f /tp/mapreduce/output >/dev/null 2>&1 || true
"${cmd[@]}" exec -T hadoop bash -lc 'hadoop jar "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount /tp/mapreduce/input.txt /tp/mapreduce/output'
"${cmd[@]}" exec -T hadoop hdfs dfs -cat /tp/mapreduce/output/part-r-00000
printf 'PASS: YARN MapReduce WordCount
'
