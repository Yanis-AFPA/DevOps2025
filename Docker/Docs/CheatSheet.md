# 🐳 Docker Cheat Sheet – Version Intermédiaire

## 🆘 Aide & Infos

```
docker help
docker <commande> --help

docker --version
docker version
docker info
```

---

## 📦 Images Docker

### Lister / Rechercher / Télécharger

```
docker images
docker image ls

docker search ubuntu --filter "is-official=true"
docker pull <IMAGE>
docker pull ubuntu:16.04
```

### Supprimer

```
docker rmi <IMAGE_ID|NAME>
docker rmi -f <IMAGE>
docker rmi -f $(docker images -q)
```

### Exemple pratique

```
docker pull nginx:latest
docker images | grep nginx
```

---

## 🚀 Conteneurs Docker

### Exécuter une image

```
docker run <IMAGE>
docker run -it <IMAGE>
docker run -d <IMAGE>
docker run --name <NAME> <IMAGE>
docker run -p 8080:80 <IMAGE>
docker run --rm <IMAGE>
```

### Lister conteneurs

```
docker ps
docker ps -a
docker container ls
```

### Supprimer conteneurs

```
docker rm <ID|NAME>
docker rm -f <ID>
docker rm -f $(docker ps -aq)
docker rm -v <CONTAINER>
```

### Logs

```
docker logs <CONTAINER>
docker logs -f <CONTAINER>
docker logs -t <CONTAINER>
docker logs --tail 100 <CONTAINER>
```

### Exécuter une commande dans un conteneur

```
docker exec -it <CONTAINER> bash
docker exec -it <CONTAINER> <COMMAND>
```

### Transformer un conteneur en image

```
docker commit -a "Auteur" -m "Message" <CONTAINER> <NEW_IMAGE>
```

### Exemple pratique

```
docker run -it --name myubuntu ubuntu:20.04 bash
# ensuite installer un paquet et créer une nouvelle image
apt update && apt install -y curl
docker commit myubuntu myubuntu:custom
```

---

## 🗄️ Volumes Docker

```
docker volume create <VOLUME>
docker volume ls
docker volume inspect <VOLUME>
docker volume rm <VOLUME>
docker volume prune
docker rm -v <CONTAINER>
```

### Exemple pratique

```
docker run -d -v mydata:/data --name mycontainer nginx
docker volume ls
```

---

## 🌐 Réseaux Docker

```
docker network ls
docker network create --driver bridge mynet
docker network inspect mynet
docker network connect mynet mycontainer
docker network disconnect mynet mycontainer
docker network rm mynet
docker network prune
```

### Exemple pratique

```
docker run -d --network mynet --name web nginx
docker run -d --network mynet --name db mysql
```

---

## 🧩 Docker Compose

### Démarrer / arrêter

```
docker compose up -d
docker compose down
docker compose start
docker compose stop
docker compose kill
docker compose rm -f
```

### Logs

```
docker compose logs
docker compose logs -f
docker compose logs --tail=50
```

### Informations

```
docker compose ps
docker compose images
docker compose ls
```

### Exemple pratique

```
docker compose up -d
docker compose logs -f web
docker compose down
```
