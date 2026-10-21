# TP03 — Spark RDD

## Objectifs

- Créer et transformer des RDD.
- Comprendre transformations et actions.
- Réaliser un WordCount local.

## Démarrage

Sur une machine 8 Go, arrêter d'abord Hadoop :

```bash
make PROFILE=8 down
make PROFILE=8 spark-up
```

Puis :

```bash
make PROFILE=8 test-spark
```

Le script `tp/03-spark-rdd/wordcount.py` fonctionne en `local[2]`.

## Travail demandé

Modifier le WordCount pour :
- ignorer la casse ;
- retirer la ponctuation ;
- afficher les mots triés par fréquence décroissante.
