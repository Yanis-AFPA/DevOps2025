# Docker - Test des volumes

Ce projet permet de tester le fonctionnement des **volumes Docker** pour la persistance des données.

---

## 1. Création de l'image Docker

Créez un fichier `Dockerfile` avec le contenu suivant :

```dockerfile
FROM alpine:latest

RUN mkdir /data

WORKDIR /data
```

Ensuite, construisez l'image :

```bash
docker build -t vtest .
```

---

## 2. Démarrage d'un conteneur avec un volume

La commande suivante va créer et monter le volume `data-test` dans le dossier `/data` du conteneur :

```bash
docker run -ti --name vtest_c -v data-test:/data vtest
```

---

## 3. Inspection du volume

Ouvrez un autre terminal et inspectez le volume créé :

```bash
docker volume inspect data-test
```

Pour voir en temps réel le contenu du volume :

```bash
sudo watch -n 1 ls /var/lib/docker/volumes/data-test/_data
```

---

## 4. Création d'un fichier dans le conteneur

Dans le terminal du conteneur, créez un fichier de test :

```bash
echo "ceci est un test" > test.txt
```

Retournez sur le terminal qui observe le volume et vous devriez voir :

```
test.txt
```

---

## 5. Vérification de la persistance

Quittez et supprimez le conteneur :

```bash
docker rm -f vtest_c
```

Recréez un nouveau conteneur avec le même volume :

```bash
docker run -ti --name vtest_c -v data-test:/data vtest
```

Vérifiez que le fichier créé précédemment est toujours présent :

```bash
cat test.txt
```

Résultat attendu :

```
ceci est un test
```

---

## Conclusion

Les volumes Docker permettent de **sauvegarder les données** même après la suppression du conteneur.