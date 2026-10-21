# TP01 — HDFS

## Objectifs

- Comprendre l'organisation logique de HDFS.
- Manipuler fichiers et répertoires.
- Observer le NameNode et le DataNode.

## Démarrage

```bash
make PROFILE=8 hadoop-up
```

## Manipulations

```bash
docker compose -f compose.yaml -f profiles/8gb.yaml exec hadoop hdfs dfs -mkdir -p /tp01
docker compose -f compose.yaml -f profiles/8gb.yaml exec hadoop hdfs dfs -put -f /workspace/datasets/words.txt /tp01/
docker compose -f compose.yaml -f profiles/8gb.yaml exec hadoop hdfs dfs -ls /tp01
docker compose -f compose.yaml -f profiles/8gb.yaml exec hadoop hdfs dfs -cat /tp01/words.txt
```

Consulter ensuite l'interface NameNode sur http://localhost:9870.

## Validation

```bash
make PROFILE=8 test-hdfs
```
