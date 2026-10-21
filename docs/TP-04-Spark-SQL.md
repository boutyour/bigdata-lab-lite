# TP04 — Spark SQL

## Objectifs

- Manipuler un DataFrame.
- Lire un CSV avec schéma inféré.
- Effectuer agrégations et tris.

## Exécution

```bash
make PROFILE=8 spark-up
make PROFILE=8 test-spark
```

Le script `tp/04-spark-sql/analytics.py` calcule le chiffre d'affaires par ville.

## Extensions

1. Calculer le chiffre d'affaires par catégorie.
2. Identifier la ville avec le chiffre d'affaires maximal.
3. Écrire le résultat en Parquet dans `/workspace/output`.
