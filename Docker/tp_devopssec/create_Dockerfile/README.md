# Projet LAMP avec Volumes Docker

Ce projet illustre l'utilisation des **volumes Docker** pour assurer la persistance des données dans une stack LAMP (Linux, Apache, MySQL, PHP).

---

## Problèmes rencontrés sans volumes

Lors d'un redémarrage d'un conteneur sans volumes :
- Les données de la base de données **ne sont pas sauvegardées**.
- Les modifications des sources de l'application **ne sont pas appliquées**.

Pour résoudre ces problèmes, nous utilisons les **volumes Docker**.

---

## 1. Préparation du projet

1. Téléchargez et décompressez le projet. 
2. Buildez l'image Docker :

```bash
docker build -t my_lamp .
```

---

## 2. Création d'un volume pour MySQL

Pour la base de données, créez un volume nommé `mysqldata` :

```bash
docker volume create --name mysqldata
```

---

## 3. Lancement du conteneur avec volumes

Pour les sources de l'application et la base de données :

```bash
docker run -d --name my_lamp_c   -v $PWD/app:/var/www/html   -v mysqldata:/var/lib/mysql   -p 8080:80 my_lamp
```

> `$PWD` prend automatiquement le chemin absolu du dossier courant. Si vous lancez la commande depuis un autre répertoire, utilisez le chemin complet.

---

## 4. Résultat attendu

- Les **modifications des sources** sont immédiatement prises en compte par PHP.
- Les **données MySQL** sont sauvegardées dans le volume `mysqldata`.

Bravo, votre stack LAMP est maintenant **stable et exploitable** 🏆!

---

## 5. Commandes utiles pour les volumes

### Créer un volume

```bash
docker volume create <VOLUME_NAME>
```

### Lister les volumes

```bash
docker volume ls
```

### Supprimer un ou plusieurs volumes

```bash
docker volume rm <VOLUME_NAME>
# avec force : docker volume rm -f <VOLUME_NAME>
```

### Inspecter un volume

```bash
docker volume inspect <VOLUME_NAME>
```

### Supprimer tous les volumes locaux inutilisés

```bash
docker volume prune
# avec force : docker volume prune -f
```

### Supprimer un conteneur avec les volumes associés

```bash
docker rm -v <CONTAINER_ID ou CONTAINER_NAME>
# options : -f pour forcer, -v pour supprimer les volumes associés
```

---

## Conclusion

Avec les volumes Docker :
- Les données de la base de données sont persistantes.
- Les sources de l'application peuvent être modifiées en temps réel.
