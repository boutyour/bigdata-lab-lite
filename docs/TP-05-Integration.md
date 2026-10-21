# TP05 — Intégration Spark + HDFS

**Profil recommandé : 16 Go ou plus.**

## Objectifs

- Stocker un jeu de données dans HDFS.
- Lire HDFS depuis Spark.
- Exécuter une agrégation avec Spark SQL.

## Démarrage

```bash
make PROFILE=16 integration-up
make PROFILE=16 test-integration
```

Le script charge `sales.csv` dans HDFS puis le lit avec Spark.

## Analyse

Comparer ce scénario avec le TP04 où Spark lit directement un fichier monté depuis le système hôte. Discuter les avantages du découplage stockage/calcul.
