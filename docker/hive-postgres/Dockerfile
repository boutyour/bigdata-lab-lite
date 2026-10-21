# syntax=docker/dockerfile:1.7
# Only the full Hive profile needs the PostgreSQL JDBC driver.
FROM alpine:3.22 AS jdbc-fetch
ARG POSTGRES_JDBC_VERSION=42.7.8
RUN apk add --no-cache ca-certificates curl
RUN set -eux; \
    curl -fL --retry 3 \
      "https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSTGRES_JDBC_VERSION}/postgresql-${POSTGRES_JDBC_VERSION}.jar" \
      -o /postgresql.jar; \
    test -s /postgresql.jar

FROM apache/hive:4.2.1
USER root
COPY --from=jdbc-fetch --chmod=0644 /postgresql.jar /opt/hive/lib/postgres.jar
USER hive
