# Quick Start étudiant — préparation en 10 minutes

Ce guide résume uniquement les étapes indispensables pour préparer votre machine avant le premier TP.

Pour les détails d'installation et le dépannage, voir [le guide complet](GUIDE-ETUDIANT-PREPARATION.md).

## 1. Vérifier votre profil matériel

```bash
free -h
```

Utilisez :

- `PROFILE=8` pour une machine avec 8 Go de RAM ;
- `PROFILE=16` pour une machine avec 16 Go ;
- `PROFILE=plus` pour une machine avec plus de 16 Go.

## 2. Vérifier les outils

```bash
git --version
docker --version
docker compose version
make --version
```

Toutes les commandes doivent fonctionner.

Vérifier également Docker :

```bash
docker ps
```

Si cette commande échoue, corrigez Docker avant de continuer.

## 3. Récupérer le dépôt

```bash
git clone https://github.com/boutyour/bigdata-lab-lite.git
cd bigdata-lab-lite
```

Si le dépôt existe déjà :

```bash
git pull
```

## 4. Configurer Docker Hub

```bash
cp -n .env.example .env
```

Vérifier que `.env` contient :

```text
DOCKERHUB_NAMESPACE=boutyour
```

## 5. Vérifier la machine

Pour 8 Go :

```bash
make PROFILE=8 check
```

Pour 16 Go :

```bash
make PROFILE=16 check
```

Pour plus de 16 Go :

```bash
make PROFILE=plus check
```

## 6. Télécharger les images

Exemple pour 8 Go :

```bash
make PROFILE=8 student-pull
```

Adaptez simplement le profil si nécessaire.

## 7. Lancer le test complet

### 8 Go

```bash
make PROFILE=8 student-test-all
```

### 16 Go

```bash
make PROFILE=16 student-test-all
```

### Plus de 16 Go

```bash
make PROFILE=plus student-test-all
```

Le test doit finir par un message similaire à :

```text
PASS: all student tests completed successfully for PROFILE=8
```

ou le profil correspondant.

## 8. Avant de venir en TP

Votre machine est prête si :

- Docker fonctionne sans erreur ;
- les images Docker sont téléchargées ;
- `student-test-all` termine avec `PASS` ;
- aucun conteneur n'est marqué `OOMKilled=true`.

Pour vérifier rapidement :

```bash
docker ps -a
docker stats --no-stream
```

## Commandes utiles pendant les TP

### Hadoop

```bash
make PROFILE=8 student-hadoop-up
```

### Spark

```bash
make PROFILE=8 student-spark-up
```

### Hive

```bash
make PROFILE=8 student-hive-up
```

### Arrêter les services

```bash
make PROFILE=8 student-down
```

Adaptez `PROFILE=8` en `16` ou `plus` selon votre machine.

---

En cas de problème, consultez [GUIDE-ETUDIANT-PREPARATION.md](GUIDE-ETUDIANT-PREPARATION.md) et conservez le message d'erreur complet.
