# TP07 — Hive + Parquet + Spark SQL

**Profil requis : 16 Go ou plus.**

## Objectif

Illustrer l'interopérabilité entre Hive et Spark via un format de stockage commun, sans dépendre de Hive-on-Spark.

## Démarrage

```bash
make PROFILE=16 hive-spark-up
make PROFILE=16 hive-spark-test
```

Le test :

1. charge `sales.csv` dans HDFS ;
2. crée une table Hive externe ;
3. crée une table Parquet avec Hive ;
4. lit les fichiers Parquet depuis Spark ;
5. exécute une agrégation avec Spark SQL.

## Discussion

- Pourquoi Parquet convient-il à l'analytique ?
- Quelle différence entre partager des fichiers et partager un catalogue ?
- Quels avantages offre un métastore externe dans une architecture multi-outils ?
