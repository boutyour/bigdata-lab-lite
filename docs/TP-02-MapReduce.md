# TP02 — MapReduce / YARN

## Objectifs

- Exécuter un traitement MapReduce.
- Observer une application YARN.
- Relier entrée HDFS, calcul et sortie HDFS.

## Démarrage

```bash
make PROFILE=8 hadoop-up
make PROFILE=8 test-mapreduce
```

Le script de test exécute l'exemple WordCount fourni avec Hadoop. Pendant l'exécution, consulter http://localhost:8088 pour observer ResourceManager et les applications YARN.

## Questions

1. Quel est le rôle du ResourceManager ?
2. Quelle différence entre un map task et un reduce task ?
3. Pourquoi le facteur de réplication vaut-il 1 dans ce laboratoire ?
