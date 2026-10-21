# Guide étudiant — Préparation de la machine

Ce guide doit être suivi **avant la première séance de TP Big Data**. L'objectif est de préparer une machine capable d'exécuter les environnements Hadoop, Spark et Hive du dépôt **BigData-Lab Lite** sans recompilation locale des images.

Le dépôt utilise des images Docker préconstruites publiées sur Docker Hub. Les étudiants n'ont donc normalement pas besoin de construire Hadoop, Spark ou Hive eux-mêmes.

---

## 1. Vérifier la configuration matérielle

Le laboratoire prend en charge trois profils.

| Mémoire RAM de la machine | Profil à utiliser | Mode d'exécution |
|---|---|---|
| 8 Go | `PROFILE=8` | Hadoop, Spark et Hive utilisés principalement de manière séquentielle |
| 16 Go | `PROFILE=16` | Hadoop + Spark + Hive peuvent être utilisés ensemble |
| Plus de 16 Go | `PROFILE=plus` | Même pile que 16 Go avec possibilité d'un second DataNode |

### Vérifier la RAM sous Linux

```bash
free -h
```

ou :

```bash
grep MemTotal /proc/meminfo
```

Choisir le profil à partir de la **RAM physique réellement disponible**, pas de la mémoire swap.

---

## 2. Système d'exploitation recommandé

Le dépôt est prévu en priorité pour Linux x86_64.

Distributions adaptées :

- Ubuntu 22.04 / 24.04 ;
- Debian 12 ou version récente ;
- Linux Mint récent ;
- Fedora récent ;
- Arch Linux / EndeavourOS.

Sur une machine 8 Go, un environnement graphique léger est préférable.

### Vérifier l'architecture

```bash
uname -m
```

Le résultat attendu est généralement :

```text
x86_64
```

---

## 3. Installer Git

### Ubuntu / Debian / Linux Mint

```bash
sudo apt update
sudo apt install -y git
```

### Fedora

```bash
sudo dnf install -y git
```

### Arch Linux / EndeavourOS

```bash
sudo pacman -S git
```

Vérifier :

```bash
git --version
```

---

## 4. Installer Docker Engine

Il est recommandé d'utiliser **Docker Engine** avec le plugin **Docker Compose v2**.

Après installation, vérifier :

```bash
docker --version
docker compose version
```

Les deux commandes doivent fonctionner.

### Vérifier le service Docker

```bash
sudo systemctl status docker
```

S'il n'est pas démarré :

```bash
sudo systemctl enable --now docker
```

---

## 5. Utiliser Docker sans `sudo` — option recommandée

Ajouter votre utilisateur au groupe Docker :

```bash
sudo usermod -aG docker "$USER"
```

Puis **fermer complètement la session utilisateur et se reconnecter**.

Vérifier ensuite :

```bash
docker ps
```

La commande doit fonctionner sans `sudo`.

> Attention : l'appartenance au groupe `docker` donne des privilèges élevés sur la machine. Sur une machine administrée par l'établissement, suivre la politique locale.

---

## 6. Installer GNU Make

Le dépôt utilise un `Makefile` pour simplifier les commandes Docker.

### Ubuntu / Debian

```bash
sudo apt install -y make
```

### Fedora

```bash
sudo dnf install -y make
```

### Arch Linux / EndeavourOS

```bash
sudo pacman -S make
```

Vérifier :

```bash
make --version
```

---

## 7. Récupérer le dépôt

Dans votre répertoire de travail :

```bash
git clone https://github.com/boutyour/bigdata-lab-lite.git
cd bigdata-lab-lite
```

Si le dépôt existe déjà :

```bash
cd bigdata-lab-lite
git pull
```

---

## 8. Configurer Docker Hub

Créer le fichier local de configuration :

```bash
cp .env.example .env
```

Ouvrir `.env` et utiliser :

```text
DOCKERHUB_NAMESPACE=boutyour
```

Le fichier `.env` est local à votre machine et n'a pas besoin d'être envoyé sur GitHub.

---

## 9. Vérifier l'environnement

Pour une machine 8 Go :

```bash
make PROFILE=8 check
```

Pour une machine 16 Go :

```bash
make PROFILE=16 check
```

Pour une machine de plus de 16 Go :

```bash
make PROFILE=plus check
```

Cette vérification contrôle notamment la présence de Docker, Docker Compose et l'accès au daemon Docker.

---

## 10. Télécharger les images Docker

### Profil 8 Go

```bash
make PROFILE=8 student-pull
```

### Profil 16 Go

```bash
make PROFILE=16 student-pull
```

### Profil >16 Go

```bash
make PROFILE=plus student-pull
```

Le premier téléchargement peut prendre plusieurs minutes selon la connexion Internet.

Aucune compilation locale n'est nécessaire.

---

## 11. Test complet recommandé avant le premier TP

C'est la vérification la plus importante.

### Machine 8 Go

```bash
make PROFILE=8 student-test-all
```

Le test exécute successivement :

1. Hadoop / HDFS ;
2. MapReduce / YARN ;
3. arrêt de Hadoop ;
4. Spark RDD ;
5. Spark SQL ;
6. arrêt de Spark ;
7. Hadoop + Hive Lite ;
8. contrôle de la mémoire et des erreurs OOM.

Les piles sont testées séquentiellement afin de respecter la contrainte de 8 Go.

### Machine 16 Go

```bash
make PROFILE=16 student-test-all
```

Le test vérifie notamment :

- HDFS ;
- MapReduce ;
- Spark RDD ;
- Spark SQL ;
- Hive ;
- Hive → Parquet → Spark ;
- PostgreSQL Metastore ;
- absence de `OOMKilled`.

### Machine >16 Go

```bash
make PROFILE=plus student-test-all
```

En plus des tests précédents, le profil `plus` vérifie un second DataNode.

---

## 12. Vérifier l'utilisation des ressources

Pendant un TP :

```bash
docker stats
```

Pour un instantané :

```bash
docker stats --no-stream
```

Mémoire de la machine :

```bash
free -h
```

État des conteneurs :

```bash
make PROFILE=8 student-status
```

Adapter `8` en `16` ou `plus` selon votre machine.

---

## 13. Commandes courantes

### Hadoop

```bash
make PROFILE=8 student-hadoop-up
```

Arrêt :

```bash
make PROFILE=8 student-down
```

### Spark

```bash
make PROFILE=8 student-spark-up
```

### Hive

```bash
make PROFILE=8 student-hive-up
```

### Hive + Spark — 16 Go minimum

```bash
make PROFILE=16 student-hive-spark-up
```

---

## 14. Interfaces Web utiles

Lorsque les services correspondants sont démarrés :

| Service | Adresse |
|---|---|
| HDFS NameNode | http://localhost:9870 |
| YARN ResourceManager | http://localhost:8088 |
| HiveServer2 Web UI | http://localhost:10002 |

Hive JDBC :

```text
jdbc:hive2://localhost:10000/default
```

Ces ports sont exposés uniquement sur la machine locale.

---

## 15. Arrêter proprement l'environnement

À la fin d'un TP :

```bash
make PROFILE=8 student-down
```

ou :

```bash
make PROFILE=16 student-down
```

ou :

```bash
make PROFILE=plus student-down
```

Ne pas laisser les services Big Data tourner inutilement en arrière-plan, en particulier sur une machine 8 Go.

---

## 16. Vérifier l'espace disque Docker

```bash
docker system df
```

Détail :

```bash
docker system df -v
```

Ne pas supprimer les images du laboratoire juste avant une séance de TP.

---

## 17. Dépannage rapide

### `docker: command not found`

Docker n'est pas installé ou n'est pas présent dans le `PATH`.

### `Cannot connect to the Docker daemon`

Vérifier :

```bash
sudo systemctl status docker
sudo systemctl start docker
```

### `permission denied while trying to connect to Docker`

Votre utilisateur n'a probablement pas encore accès au groupe Docker.

Vérifier :

```bash
groups
```

Puis, si nécessaire :

```bash
sudo usermod -aG docker "$USER"
```

et se déconnecter/reconnecter.

### Une image ne se télécharge pas

Tester :

```bash
docker pull boutyour/hadoop-lite:3.4.2
```

Puis :

```bash
docker pull boutyour/spark-lite:3.5.7
```

### Un conteneur s'arrête

Afficher son état :

```bash
docker ps -a
```

Afficher les logs via le dépôt :

```bash
make PROFILE=8 student-status
```

ou directement :

```bash
docker compose -f compose.student.yaml -f profiles/8gb.yaml logs --tail=100
```

### Vérifier un éventuel manque de mémoire

```bash
docker inspect   --format='{{.Name}} OOMKilled={{.State.OOMKilled}} ExitCode={{.State.ExitCode}}'   $(docker ps -aq)
```

Si `OOMKilled=true`, arrêter les autres applications lourdes et vérifier que le bon profil est utilisé.

---

## 18. Conditions minimales avant de venir en TP

Avant la première séance, chaque étudiant doit avoir :

- Git installé ;
- Docker Engine fonctionnel ;
- Docker Compose v2 fonctionnel ;
- GNU Make installé ;
- le dépôt cloné ;
- le fichier `.env` configuré avec `DOCKERHUB_NAMESPACE=boutyour` ;
- les images Docker téléchargées ;
- le test `student-test-all` correspondant à sa machine exécuté avec succès.

Exemple pour un PC 8 Go :

```bash
make PROFILE=8 student-test-all
```

Le test doit se terminer par un message similaire à :

```text
PASS: all student tests completed successfully for PROFILE=8
```

---

## 19. En cas de problème avant la séance

Conserver les sorties des commandes suivantes :

```bash
free -h
docker --version
docker compose version
docker ps -a
docker images
```

Puis exécuter :

```bash
make PROFILE=8 student-test-all
```

ou le profil correspondant à votre machine, et transmettre **le message d'erreur complet**, sans le tronquer.
