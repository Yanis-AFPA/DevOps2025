🐳 FICHE DE RÉVISION – DOCKER
 
1️⃣ Docker – Principe général
 
Docker permet d’exécuter des applications dans des conteneurs :
 
Léger (partage le kernel de l’OS)
 
Isolé
 
Reproductible
 
Portable
 
 
Concepts clés
 
Terme Rôle
 
Image Modèle immuable (template)
Conteneur Image en cours d’exécution
Volume Stockage persistant
Network Communication entre conteneurs
Registry Stockage d’images (Docker Hub)
 
 
 
---
 
2️⃣ Dockerfile – Construire une image
 
Un Dockerfile décrit comment créer une image Docker.
 
Ordre d’exécution
 
Les instructions sont exécutées de haut en bas.
 
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]
 
Instructions essentielles
 
Instruction Rôle
 
FROM Image de base
RUN Commande exécutée à la build
COPY / ADD Copier des fichiers
CMD Commande par défaut au runtime
ENTRYPOINT Commande obligatoire
ENV Variables d’environnement
 
 
📌 RUN est exécuté à la build, CMD au lancement du conteneur.
 
 
---
 
3️⃣ Docker Compose – Orchestration locale
 
Docker Compose permet de gérer plusieurs conteneurs avec un seul fichier docker-compose.yml.
 
Ordre d’exécution de docker compose up
 
1. Lecture du fichier docker-compose.yml
 
 
2. Création des networks (s’ils n’existent pas)
 
 
3. Création des volumes (s’ils n’existent pas)
 
 
4. Build des images (build:)
 
 
5. Création des conteneurs
 
 
6. Démarrage des conteneurs
 
 
7. Application des depends_on
 
 
 
⚠️ depends_on ne garantit pas que le service est prêt, seulement qu’il est lancé.
 
 
---
 
4️⃣ Gestion des volumes
 
Volume nommé
 
volumes:
  - db_data:/var/lib/mysql
 
✔ Persistant
✔ Géré par Docker
✔ Partageable
 
Bind mount
 
volumes:
  - ./src:/app
 
✔ Accès direct au filesystem hôte
❌ Moins portable
 
📌 Les volumes sont créés avant les conteneurs.
📌 Les données persistent après docker compose down.
 
 
---
 
5️⃣ Gestion des networks
 
Network par défaut
 
Docker Compose crée un bridge network
 
Les services communiquent par nom de service
 
 
Exemple :
 
app -> db:3306
 
Network personnalisé
 
networks:
  backend:
    driver: bridge
 
✔ DNS automatique
✔ Isolation réseau
 
 
---
 
6️⃣ Exemple de docker-compose.yml
 
version: "3.9"
 
services:
  app:
    build: .
    container_name: app_node
    ports:
      - "3000:3000"
    volumes:
      - ./src:/app
    depends_on:
      - db
    networks:
      - backend
 
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: test
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - backend
 
volumes:
  db_data:
 
networks:
  backend:
 
 
---
 
7️⃣ Docker Swarm – Orchestration distribuée
 
Docker Swarm permet de gérer Docker sur plusieurs machines.
 
Concepts Swarm
 
Élément Rôle
 
Node Machine du cluster
Manager Orchestration
Worker Exécution des conteneurs
Service Déploiement scalable
Stack Ensemble de services
 
 
Déploiement
 
docker swarm init
docker stack deploy -c docker-compose.yml my_stack
 
Différences Compose / Swarm
 
Docker Compose Docker Swarm
 
Local Cluster
Simple Haute disponibilité
Non scalable Réplicas
Développement Production
 
 
 
---
 
8️⃣ Résumé rapide
 
Dockerfile → construit une image
 
Image → modèle
 
Conteneur → instance
 
Compose → orchestration locale
 
Swarm → orchestration distribuée
 
Ordre docker compose up : networks → volumes → build → conteneurs → start
 
Communication par nom de service
 
Les volumes persistent