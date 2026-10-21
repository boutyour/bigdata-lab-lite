# Guide enseignant

## Objectif

BigData-Lab Lite fournit un environnement reproductible pour les TP Hadoop, Spark et Hive sur des postes étudiants disposant de 8 Go, 16 Go ou plus de RAM.

## Politique de déploiement

- Profil 8 Go : exécuter une pile à la fois. Hadoop et Spark ne doivent pas être lancés simultanément. Hive Lite s'exécute avec Hadoop.
- Profil 16 Go : Hadoop, Spark et Hive peuvent être combinés pour les exercices d'intégration.
- Profil >16 Go : permet en plus un second DataNode pour illustrer le fonctionnement distribué.

## Avant une séance

1. Vérifier Docker et Compose : `make PROFILE=8 check`.
2. Exécuter les tests statiques : `make PROFILE=8 smoke`.
3. Construire les images sur une machine de référence.
4. Mesurer la consommation : `make PROFILE=8 stats`.
5. Exécuter les tests correspondants au TP.

## Validation minimale

### Hadoop

```bash
make PROFILE=8 hadoop-up
make PROFILE=8 test-hdfs
make PROFILE=8 test-mapreduce
```

### Spark

```bash
make PROFILE=8 spark-up
make PROFILE=8 test-spark
```

### Hive

```bash
make PROFILE=8 hive-up
make PROFILE=8 hive-test
```

### Intégration

```bash
make PROFILE=16 hive-spark-up
make PROFILE=16 hive-spark-test
```

## Recommandations

Les jeux de données fournis sont volontairement petits. Pour les évaluations, augmenter progressivement leur taille en surveillant la RAM et les temps d'exécution. Ne pas transformer les profils de TP en architecture de production : l'objectif est pédagogique et local.
