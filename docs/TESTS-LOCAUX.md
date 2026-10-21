# Validation locale des profils étudiants

Cette procédure teste les images préconstruites publiées sur Docker Hub, sans reconstruire les Dockerfiles localement.

## Préparation

```bash
git pull
cp -n .env.example .env
```

Dans `.env` :

```text
DOCKERHUB_NAMESPACE=boutyour
```

Vérifier Docker :

```bash
make PROFILE=8 check
```

## Test complet 8 Go

```bash
make PROFILE=8 student-test-all
```

Le scénario est volontairement séquentiel :

1. Hadoop + HDFS + MapReduce ;
2. arrêt Hadoop ;
3. Spark RDD + Spark SQL ;
4. arrêt Spark ;
5. Hadoop + Hive Lite ;
6. contrôle OOM/ressources ;
7. arrêt des conteneurs.

## Test complet 16 Go

```bash
make PROFILE=16 student-test-all
```

Le scénario lance l'architecture intégrée Hadoop + Spark + HiveServer2 + Metastore + PostgreSQL, puis valide HDFS, MapReduce, Spark, Hive/Parquet et l'absence d'OOM kill.

## Test complet >16 Go

```bash
make PROFILE=plus student-test-all
```

En plus des tests du profil 16 Go, le script démarre `worker2` et vérifie avec `hdfs dfsadmin -report` qu'au moins deux DataNodes sont vivants.

## Tests unitaires

```bash
make PROFILE=8 student-test-hdfs
make PROFILE=8 student-test-mapreduce
make PROFILE=8 student-test-spark
make PROFILE=8 student-test-hive
make PROFILE=8 student-test-resources

make PROFILE=16 student-test-integration
make PROFILE=plus student-test-cluster
```

Les cibles unitaires supposent que les services correspondants sont déjà démarrés.

## Diagnostic

```bash
make PROFILE=8 student-status
docker stats --no-stream
free -h
```

Le contrôle de ressources échoue si un conteneur a été marqué `OOMKilled=true` ou s'il s'est terminé de manière inattendue avec un code non nul.
