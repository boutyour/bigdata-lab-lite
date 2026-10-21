# Publication Docker Hub et utilisation étudiante

## Configuration GitHub

Dans **Settings → Secrets and variables → Actions** du dépôt GitHub :

- Variable : `DOCKERHUB_USERNAME`
- Secret : `DOCKERHUB_TOKEN`

Le workflow `.github/workflows/docker-publish.yml` ne publie les images que lorsqu'un tag Git commençant par `v` est poussé.

Exemple :

```bash
git tag v2.0.0
git push origin v2.0.0
```

Les images publiées sont :

```text
<namespace>/hadoop-lite:3.4.2
<namespace>/spark-lite:3.5.7
<namespace>/hive-postgres:4.2.1
```

Une seconde étiquette associe la version du framework à la release du laboratoire, par exemple `3.4.2-v2.0.0`.

## Mode étudiant

Après la première publication Docker Hub :

```bash
cp .env.example .env
```

Modifier `.env` :

```text
DOCKERHUB_NAMESPACE=votre_namespace_dockerhub
```

Puis :

```bash
make PROFILE=8 student-pull
make PROFILE=8 student-hadoop-up
```

Ce mode utilise `compose.student.yaml` et **ne construit aucune image localement**.

Pour Spark :

```bash
make PROFILE=8 student-down
make PROFILE=8 student-spark-up
```

Pour Hive sur 8 Go :

```bash
make PROFILE=8 student-down
make PROFILE=8 student-hive-up
```

Pour l'intégration Hive + Spark sur 16 Go :

```bash
make PROFILE=16 student-hive-spark-up
```

Le fichier `compose.yaml` historique reste le mode enseignant/développeur et conserve les sections `build:` afin de permettre de reconstruire les images localement.
