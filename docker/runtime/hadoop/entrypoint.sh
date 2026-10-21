#!/usr/bin/env bash
set -Eeuo pipefail
mode="${1:-master}"
mkdir -p "$HADOOP_LOG_DIR" /data/namenode /data/datanode
shutdown() {
  if [[ "$mode" == master ]]; then
    yarn --daemon stop nodemanager || true
    yarn --daemon stop resourcemanager || true
    hdfs --daemon stop datanode || true
    hdfs --daemon stop namenode || true
  elif [[ "$mode" == worker ]]; then
    yarn --daemon stop nodemanager || true
    hdfs --daemon stop datanode || true
  fi
}
trap 'shutdown; exit 0' TERM INT
if [[ "$mode" == master ]]; then
  if [[ ! -f /data/namenode/current/VERSION ]]; then
    echo 'Initializing an empty HDFS NameNode volume'
    hdfs namenode -format -nonInteractive -force
  fi
  hdfs --daemon start namenode
  hdfs --daemon start datanode
  yarn --daemon start resourcemanager
  yarn --daemon start nodemanager
elif [[ "$mode" == worker ]]; then
  hdfs --daemon start datanode
  yarn --daemon start nodemanager
else
  echo "Unknown mode: $mode" >&2
  exit 2
fi
# Keep PID 1 alive and detect unexpected JVM exits.
while true; do
  if [[ "$mode" == master ]]; then
    ps -ef | grep '[o]rg.apache.hadoop.hdfs.server.namenode.NameNode' >/dev/null || { echo 'NameNode stopped' >&2; exit 1; }
    ps -ef | grep '[o]rg.apache.hadoop.yarn.server.resourcemanager.ResourceManager' >/dev/null || { echo 'ResourceManager stopped' >&2; exit 1; }
  else
    ps -ef | grep '[o]rg.apache.hadoop.hdfs.server.datanode.DataNode' >/dev/null || { echo 'DataNode stopped' >&2; exit 1; }
  fi
  sleep 8 & wait $!
done
