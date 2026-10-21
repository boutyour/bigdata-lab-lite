# TP06 — Hive + HDFS

## Objectifs

- Comprendre le rôle de HiveServer2.
- Créer une base et des tables Hive.
- Interroger des données CSV stockées dans HDFS.
- Convertir une table en Parquet.

## Profil 8 Go

```bash
make PROFILE=8 down
make PROFILE=8 hive-up
make PROFILE=8 hive-test
make PROFILE=8 hive-shell
```

Le profil 8 Go utilise Derby embarqué et n'exécute pas Spark simultanément.

## Requêtes

```sql
SHOW DATABASES;
USE tp_bigdata;
SHOW TABLES;
SELECT * FROM sales_csv LIMIT 10;
SELECT category, SUM(amount)
FROM sales_csv
GROUP BY category;
```

Le fichier `tp/06-hive/tp06.sql` crée également `sales_parquet`.

## Profil 16 Go

```bash
make PROFILE=16 hive-up
make PROFILE=16 hive-test
```

Le métastore est alors séparé et persiste dans PostgreSQL.
