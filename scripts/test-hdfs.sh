#!/usr/bin/env bash
set -Eeuo pipefail
compose=$1
# Build the command from the trusted Makefile (not user input).
read -r -a cmd <<< "$compose"
"${cmd[@]}" exec -T hadoop hdfs dfs -mkdir -p /tp/hdfs
"${cmd[@]}" exec -T hadoop hdfs dfs -put -f /workspace/datasets/words.txt /tp/hdfs/words.txt
"${cmd[@]}" exec -T hadoop hdfs dfs -cat /tp/hdfs/words.txt | grep -q 'hadoop'
"${cmd[@]}" exec -T hadoop hdfs dfs -ls /tp/hdfs
printf 'PASS: HDFS upload, read and listing
'
