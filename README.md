# BigData-Lab Lite — Hadoop, Spark et Hive optimisés pour 8 Go, 16 Go et >16 Go

Dépôt pédagogique pour **Hadoop HDFS + YARN/MapReduce**, **Apache Spark/PySpark** et **Apache Hive**, avec des images construites de manière conservatrice en **multi-stage**. L'architecture est modulée selon la RAM disponible afin que les machines de 8 Go restent utilisables pendant les TP.

## Philosophie de dimensionnement

- **8 Go** : Hadoop ou Spark séparément ; Hive s'exécute avec Hadoop mais sans Spark. HiveServer2 utilise un métastore Derby embarqué.
- **16 Go** : Hadoop + Spark + Hive peuvent être combinés. Hive utilise un métastore séparé persisté dans PostgreSQL.
- **>16 Go** : même architecture que 16 Go avec davantage de marge et un second DataNode facultatif.

Les limites Docker sont des **plafonds**, pas de la mémoire réservée. La consommation réelle dépend des requêtes, de l'OS et des jeux de données.

## Prérequis

- Linux x86_64, Docker Engine + plugin Compose v2, GNU Make, Bash.
- Au moins 8 Go de RAM physique ; un environnement graphique léger est recommandé sur les postes 8 Go.
- Accès Internet lors de la première construction / récupération des images.
- Espace disque libre de plusieurs Go : Hadoop, Spark et Hive contiennent de nombreuses bibliothèques Java.

## Stratégie d’image

- Hadoop : distribution officielle **3.4.2 lean**, téléchargée et vérifiée en stage de build, puis copiée vers un JRE Temurin 11 minimal.
- Spark : distribution binaire officielle **3.5.7 / Hadoop 3**, téléchargée et vérifiée en stage de build, puis copiée vers un JRE Temurin 17 + Python minimal.
- Hive 8 Go : image Apache officielle utilisée directement, sans pilote PostgreSQL inutile.
- Hive 16 Go+ : image dérivée Apache Hive contenant uniquement le pilote JDBC PostgreSQL additionnel.
- Aucun retrait manuel de JARs framework ; aucun `jlink` agressif.

Voir [OPTIMISATION.md](docs/OPTIMISATION.md).

## Versions du dépôt

- Hadoop 3.4.2 (distribution lean)
- Spark / PySpark 3.5.7
- Hive 4.2.1
- PostgreSQL 17-alpine pour le métastore des profils 16 Go et plus

## Démarrage rapide — 8 Go

```bash
make PROFILE=8 check
make PROFILE=8 smoke
make PROFILE=8 build

# TP Hadoop
make PROFILE=8 hadoop-up
make PROFILE=8 test-hdfs
make PROFILE=8 test-mapreduce
make PROFILE=8 down

# TP Spark
make PROFILE=8 spark-up
make PROFILE=8 test-spark
make PROFILE=8 down

# TP Hive : Hadoop + Hive léger, sans Spark
make PROFILE=8 hive-up
make PROFILE=8 hive-test
make PROFILE=8 hive-shell
make PROFILE=8 down
```

## Démarrage — 16 Go

```bash
# Hadoop + Spark
make PROFILE=16 integration-up
make PROFILE=16 test-integration
make PROFILE=16 down

# Hadoop + Hive + PostgreSQL Metastore
make PROFILE=16 hive-up
make PROFILE=16 hive-test
make PROFILE=16 down

# Hadoop + Hive + Spark
make PROFILE=16 hive-spark-up
make PROFILE=16 hive-spark-test
make PROFILE=16 down
```

## Démarrage — plus de 16 Go

```bash
make PROFILE=plus hive-spark-up
make PROFILE=plus hive-spark-test

# Démonstration d'un second DataNode
make PROFILE=plus cluster-up

make PROFILE=plus down
```

## Interfaces locales

- HDFS NameNode : http://localhost:9870
- YARN ResourceManager : http://localhost:8088
- HiveServer2 Web UI : http://localhost:10002
- HiveServer2 JDBC : `jdbc:hive2://localhost:10000/default`

Les ports sont exposés uniquement sur `127.0.0.1`.

## Travaux pratiques

1. [TP01 — HDFS](docs/TP-01-HDFS.md)
2. [TP02 — MapReduce / YARN](docs/TP-02-MapReduce.md)
3. [TP03 — Spark RDD](docs/TP-03-Spark-RDD.md)
4. [TP04 — Spark SQL](docs/TP-04-Spark-SQL.md)
5. [TP05 — Spark + HDFS](docs/TP-05-Integration.md) — 16 Go et plus
6. [TP06 — Hive + HDFS](docs/TP-06-Hive.md)
7. [TP07 — Hive + Parquet + Spark SQL](docs/TP-07-Hive-Spark.md) — 16 Go et plus

## Architecture par profil

| Profil | Services simultanés recommandés | Plafonds principaux |
|---|---|---|
| 8 Go | Hadoop seul ; Spark seul ; ou Hadoop + Hive Lite | Hadoop 3 Go, Spark 2,8 Go, Hive Lite 1,2 Go |
| 16 Go | Hadoop + Spark + Hive + PostgreSQL Metastore | Hadoop 4 Go, Spark 4,2 Go, Hive 1,4 Go, Metastore 0,9 Go, PostgreSQL 0,5 Go |
| >16 Go | Idem + second DataNode facultatif | Hadoop 5,2 Go, Spark 6 Go, Hive 1,8 Go, Metastore 1,2 Go, PostgreSQL 0,75 Go |

### Profil Hive 8 Go

```text
HDFS/YARN (conteneur Hadoop)
          │
          └── HiveServer2
              └── Derby embarqué
```

Ce profil vise un poste étudiant local et mono-utilisateur. Spark doit être arrêté.

### Profil Hive 16 Go et plus

```text
HDFS/YARN
   │
   ├── HiveServer2 ── Hive Metastore ── PostgreSQL
   │
   └── Spark local ── lit les mêmes données HDFS/Parquet
```

Le TP07 met volontairement l'accent sur l'**interopérabilité du stockage HDFS/Parquet**. Il ne configure pas Hive-on-Spark comme moteur d'exécution.

## Commandes utiles

```bash
make PROFILE=8 help
make PROFILE=8 status
make PROFILE=8 stats
make PROFILE=8 images
make benchmark-images
make PROFILE=8 logs-hadoop
make PROFILE=8 logs-spark
make PROFILE=8 logs-hive
```

### Réinitialisation complète

```bash
make PROFILE=8 reset
```

**Attention :** `reset` supprime les volumes HDFS et les métadonnées Hive persistantes.

## Validation avant diffusion aux étudiants

Exécuter sur au moins une machine représentative de chaque profil :

```bash
make PROFILE=8 hive-up
make PROFILE=8 hive-test
make PROFILE=8 stats

make PROFILE=16 hive-spark-up
make PROFILE=16 hive-spark-test
make PROFILE=16 stats
```

Vérifier notamment :
- absence d'OOM kill ;
- temps de démarrage ;
- consommation RAM au repos et sous charge ;
- persistance des tables Hive après redémarrage ;
- accès HDFS depuis Hive et Spark.

## Limites connues

- `dfs.replication=1` est choisi pour économiser les ressources ; il ne fournit pas de tolérance aux pannes.
- Les services sont configurés sans authentification forte et sont destinés uniquement aux TP locaux.
- Le profil 8 Go n'est pas prévu pour exécuter Hadoop + Hive + Spark simultanément.
- Spark local n'est pas Spark-on-YARN.
- TP07 partage les fichiers Parquet/HDFS entre Hive et Spark, pas un métastore Hive 4 directement depuis Spark.
- Les builds Docker doivent être validés sur les postes du laboratoire avant diffusion massive.
- L’édition Lite n’utilise volontairement pas `jlink` et ne supprime pas de JARs Hadoop/Spark/Hive afin de minimiser le risque fonctionnel.

Voir également [le guide enseignant](docs/ENSEIGNANT.md).
