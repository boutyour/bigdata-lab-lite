# Stratégie d'optimisation conservatrice

L'objectif de BigData-Lab Lite est de réduire l'espace disque et la consommation des environnements de TP sans pratiquer de « dependency surgery » risquée.

## Principes retenus

### 1. Multi-stage builds

Les outils de téléchargement et d'extraction sont placés dans des stages temporaires. Les images finales ne conservent que le runtime Java/Python et les distributions Hadoop ou Spark.

### 2. Hadoop Lean

Le Dockerfile utilise la distribution Hadoop 3.4.2 `lean`. Aucun JAR Hadoop n'est retiré manuellement.

### 3. Runtime Java adapté

Hadoop est exécuté sur Temurin JRE 11. Spark 3.5.7 est exécuté sur Temurin JRE 17. Une JVM unique n'est pas imposée entre Hadoop, Spark et Hive afin d'éviter des incompatibilités.

### 4. Spark complet mais sans duplication PySpark

La distribution officielle `spark-3.5.7-bin-hadoop3` est conservée. PySpark n'est pas installé une seconde fois avec `pip`. Les TP utilisent `spark-submit`.

### 5. Hive

Le profil 8 Go utilise directement l'image Apache Hive officielle. Les profils 16 Go et plus ajoutent uniquement le pilote JDBC PostgreSQL dans une image dérivée.

### 6. Aucun jlink agressif

`jlink` peut produire un runtime Java plus petit, mais une mauvaise sélection de modules peut casser des chemins d'exécution moins fréquents. Cette optimisation n'est donc pas appliquée dans l'édition destinée aux étudiants.

### 7. Contextes de build réduits

Les fichiers `.dockerignore` empêchent d'envoyer au daemon Docker des caches, logs et fichiers de développement inutiles.

## Mesure des images

```bash
make PROFILE=8 build
make benchmark-images

docker history bigdata-lab/hadoop-lite:3.4.2
docker history bigdata-lab/spark-lite:3.5.7
docker system df -v
```

## Pourquoi ne pas supprimer des JARs ?

Les dépendances Java de Hadoop, Spark et Hive sont nombreuses et certaines ne sont chargées que pour des fonctionnalités spécifiques. Une image peut donc sembler fonctionner au démarrage puis échouer dans un TP particulier. BigData-Lab Lite privilégie la reproductibilité au gain marginal obtenu par suppression manuelle de bibliothèques.

## RAM et taille d'image

La taille d'une image Docker et la RAM utilisée par un conteneur sont deux problèmes différents. Les multi-stage builds réduisent principalement le stockage et le transfert. Les profils Compose, tailles de heap JVM et services activés déterminent surtout la consommation RAM.
