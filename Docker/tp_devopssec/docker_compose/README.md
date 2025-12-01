# Guide Docker Compose pour une stack LAMP

Ce guide explique comment créer et utiliser un environnement Docker avec Docker Compose pour une application web **LAMP** (Linux, Apache, MySQL, PHP).

---

## 📂 1. Structure du projet

Votre projet doit ressembler à ceci :

```
project-root/
├── app/
│   ├── db-config.php
│   ├── index.php
│   └── validation.php
├── articles.sql
├── docker-compose.yml
└── Dockerfile
```

---

## ⚡ 2. Construire l'image de l'application

Si votre service `app` utilise un Dockerfile local, vous devez construire l'image avant de lancer les conteneurs.

### Option 1 : Construire manuellement

```bash
docker build -t myapp ./app
```

* `-t myapp` : nomme l'image `myapp`
* `./app` : chemin du Dockerfile

### Option 2 : Laisser Docker Compose construire automatiquement

Dans votre `docker-compose.yml`, ajoutez :

```yaml
app:
    build: ./app
    container_name: myapp_c
    restart: always
    volumes:
        - ./app:/var/www/html
    ports:
        - 8080:80
    depends_on:
        - db
```

Puis lancez :

```bash
docker compose up -d --build
```

* `--build` force la reconstruction de l'image.

---

## ⚡ 3. Lancer l’application

Placez-vous dans le dossier contenant `docker-compose.yml` et lancez :

```bash
docker compose up -d
```

* `-d` : exécute les conteneurs en arrière-plan.

### Vérification des conteneurs

```bash
docker ps
```

Pour lister uniquement les conteneurs du projet :

```bash
docker compose ps
```

Afficher les logs :

```bash
docker compose logs
```

---

## 🧪 4. Tester l’application

Accédez à l’application via : [http://localhost:8080/](http://localhost:8080/)

* Remplissez le formulaire de l’application.
* Pour arrêter les conteneurs :

```bash
docker compose kill
```

* Relancez les services pour vérifier que les données sont **persistantes** :

```bash
docker compose start
```

---

## 🌐 5. Communication inter-conteneurs

Docker crée un **réseau bridge** (`docker0`) pour permettre aux conteneurs de communiquer entre eux.

| Option           | Exemple      |
| ---------------- | ------------ |
| IP du conteneur  | `172.18.0.3` |
| Nom du conteneur | `mysql_c`    |
| Nom du service   | `db`         |

Exemple dans `db-config.php` :

```php
const DB_DSN = 'mysql:host=mysql_c;dbname=test';
```

---

## 🛠️ 6. Commandes Docker Compose utiles

| Action                                                       | Commande                        |
| ------------------------------------------------------------ | ------------------------------- |
| Démarrer les services                                        | `docker compose up -d`          |
| Lister tous les conteneurs                                   | `docker compose ls`             |
| Lister les conteneurs du projet                              | `docker compose ps`             |
| Afficher les logs                                            | `docker compose logs`           |
| Suivre les logs en temps réel                                | `docker compose logs -f`        |
| Afficher les 50 dernières lignes de logs                     | `docker compose logs --tail=50` |
| Arrêter les conteneurs                                       | `docker compose stop`           |
| Redémarrer les conteneurs                                    | `docker compose start`          |
| Tuer les conteneurs                                          | `docker compose kill`           |
| Arrêter et supprimer tous les conteneurs, volumes et réseaux | `docker compose down`           |
| Supprimer les conteneurs stoppés                             | `docker compose rm -f`          |
| Lister les images utilisées                                  | `docker compose images`         |

> 💡 Astuce : utilisez toujours le **nom du service** (`db` ou `app`) pour simplifier la communication entre conteneurs.

---

## ✅ 7. Conclusion

Docker Compose simplifie la gestion des applications multi-conteneurs en permettant de :

* Démarrer, arrêter et reconstruire des services
* Visualiser les logs
* Exécuter des commandes sur des services spécifiques

Avec cette configuration, vous disposez d’une **stack LAMP fonctionnelle et prête à l’usage**.
