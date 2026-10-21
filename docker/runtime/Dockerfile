# syntax=docker/dockerfile:1.7
# BigData-Lab conservative multi-stage runtime images.
# No framework JAR is deleted: the goal is size reduction without dependency surgery.

ARG TEMURIN11=eclipse-temurin:11-jre-jammy
ARG TEMURIN17=eclipse-temurin:17-jre-jammy

# ---------- Hadoop fetch/verify stage ----------
FROM ${TEMURIN11} AS hadoop-fetch
ARG HADOOP_VERSION=3.4.2
RUN apt-get update  && apt-get install -y --no-install-recommends ca-certificates curl tar gzip  && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
RUN set -eux;     base="https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}";     curl -fL --retry 3 "${base}/hadoop-${HADOOP_VERSION}-lean.tar.gz" -o hadoop.tgz;     curl -fL --retry 3 "${base}/hadoop-${HADOOP_VERSION}-lean.tar.gz.sha512" -o hadoop.tgz.sha512;     expected="$(grep -oE '[a-fA-F0-9]{128}' hadoop.tgz.sha512 | head -n 1)";     test -n "$expected";     echo "$expected  hadoop.tgz" | sha512sum -c -;     mkdir -p /out/hadoop;     tar -xzf hadoop.tgz -C /out/hadoop --strip-components=1

# Reusable Java 11 runtime layer for Hadoop-family services.
FROM ${TEMURIN11} AS java11-runtime
RUN apt-get update  && apt-get install -y --no-install-recommends bash procps tini  && rm -rf /var/lib/apt/lists/*  && groupadd -g 10001 bigdata  && useradd -m -u 10001 -g bigdata -s /bin/bash bigdata

FROM java11-runtime AS hadoop
ARG HADOOP_VERSION=3.4.2
COPY --from=hadoop-fetch /out/hadoop /opt/hadoop
COPY hadoop/config/ /opt/hadoop/etc/hadoop/
COPY hadoop/entrypoint.sh /usr/local/bin/bigdata-entrypoint
RUN set -eux;     chmod +x /usr/local/bin/bigdata-entrypoint;     mkdir -p /data/namenode /data/datanode /opt/hadoop/logs /workspace;     chown -R bigdata:bigdata /data /workspace /opt/hadoop
ENV HADOOP_HOME=/opt/hadoop     HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop     HADOOP_LOG_DIR=/opt/hadoop/logs     JAVA_HOME=/opt/java/openjdk     PATH=/opt/hadoop/bin:/opt/hadoop/sbin:$PATH
USER bigdata
WORKDIR /workspace
EXPOSE 9870 8088 9000 9864 8042
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/bigdata-entrypoint"]
CMD ["master"]

# ---------- Spark fetch/verify stage ----------
FROM ${TEMURIN17} AS spark-fetch
ARG SPARK_VERSION=3.5.7
ARG SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-hadoop3
RUN apt-get update  && apt-get install -y --no-install-recommends ca-certificates curl tar gzip  && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
RUN set -eux;     base="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}";     curl -fL --retry 3 "${base}/${SPARK_PACKAGE}.tgz" -o spark.tgz;     curl -fL --retry 3 "${base}/${SPARK_PACKAGE}.tgz.sha512" -o spark.tgz.sha512;     expected="$(grep -oE '[a-fA-F0-9]{128}' spark.tgz.sha512 | head -n 1)";     test -n "$expected";     echo "$expected  spark.tgz" | sha512sum -c -;     mkdir -p /out/spark;     tar -xzf spark.tgz -C /out/spark --strip-components=1

# Java 17 + Python runtime. This is deliberately separate from Java 11 because
# forcing one JVM version across Hadoop/Spark/Hive would increase compatibility risk.
FROM ${TEMURIN17} AS java17-python-runtime
RUN apt-get update  && apt-get install -y --no-install-recommends python3 python3-minimal procps tini bash  && rm -rf /var/lib/apt/lists/*  && groupadd -g 10001 bigdata  && useradd -m -u 10001 -g bigdata -s /bin/bash bigdata

FROM java17-python-runtime AS spark
ARG SPARK_VERSION=3.5.7
COPY --from=spark-fetch /out/spark /opt/spark
RUN set -eux;     mkdir -p /workspace/output;     chown -R bigdata:bigdata /workspace /opt/spark
ENV SPARK_HOME=/opt/spark     JAVA_HOME=/opt/java/openjdk     PYSPARK_PYTHON=python3     PYSPARK_DRIVER_PYTHON=python3     SPARK_LOCAL_IP=127.0.0.1     PATH=/opt/spark/bin:/opt/spark/sbin:$PATH
USER bigdata
WORKDIR /workspace
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sleep", "infinity"]
