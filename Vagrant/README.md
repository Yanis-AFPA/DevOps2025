#  Projet Vagrant – TP DevOps 2025

Ce projet regroupe **3 travaux pratiques** utilisant **Vagrant + VirtualBox** pour créer des infrastructures virtuelles et automatisées.

Les objectifs principaux :

* Comprendre la notion de **box**
* Créer des **VM automatisées**
* Automatiser le **provisionnement**
* Configurer des **dossiers partagés**
* Modéliser une infrastructure **multi-VM** (web / base de données)

---

##  Structure générale du projet

```
tp-vagrant/
│
├─ tp-vagrant-debian/      # Étape 1 : Debian base
│   ├─ Vagrantfile
│
├─ tp-vagrant-lamp/        # Étape 2 : VM LAMP + dossier partagé
│   ├─ Vagrantfile
│   ├─ shared/             # Dossier monté dans /var/www/html
│
├─ tp-vagrant-web-db/      # Étape 3 : Multi-VM Web + DB
│   ├─ Vagrantfile
│   ├─ scripts/
│   │   ├─ db_provision.sh
│   │   └─ web_provision.sh
│   ├─ db_sql/
│   │   └─ db_init.sql
│   └─ shared/             # Dossier monté dans /var/www/html
```

---

##  Étape 1 – Debian Base (`tp-vagrant-debian`)

### Objectif

Créer une VM Debian minimale pour comprendre le fonctionnement d’une box Vagrant.

### Caractéristiques

* Box : `bento/debian-13`
* Nom d’hôte : `debian-base`
* RAM : 1024 Mo, CPU : 1
* IP privée : `192.168.56.10`
* Message personnalisé dans `/etc/motd` : “VM TP – Debian Base”

### Commandes utiles

```bash
vagrant up
vagrant ssh
vagrant provision
vagrant destroy -f
```

---

## 📝 Étape 2 – VM LAMP + dossier partagé (`tp-vagrant-lamp`)

### Objectif

Créer une VM avec stack LAMP et un dossier partagé pour le développement web.

### Caractéristiques

* Box : `bento/debian-13`
* Nom d’hôte : `lamp-server`
* Port forwarding : **hôte 7676 → VM 80**
* Dossier partagé : `./shared → /var/www/html`

  * Owner : www-data, Group : www-data, fmode=644, dmode=755

### Provisionnement

* Apache2 + PHP + extensions PHP installés
* Apache activé au démarrage
* `/var/www/html` nettoyé
* Fichier `index.html` ou `index.php` ajouté avec contenu HTML simple
* Message personnalisé dans `/etc/motd`

### Commandes utiles

```bash
vagrant up
vagrant ssh
# Tester dans le navigateur :
http://localhost:7676
```

---

##  Étape 3 – Infrastructure multi-VM Web + DB (`tp-vagrant-web-db`)

### Objectif

Mettre en place 2 VM communicantes : un serveur Web et une base de données.

### VM 1 : Base de données (`db-server`)

* Box : `bento/debian-13`
* IP privée : `192.168.56.11`
* RAM : 1024 Mo, CPU : 1
* MariaDB installée et configurée pour écoute sur toutes les interfaces
* Script SQL externe `db_sql/db_init.sql` pour :

  * Créer la base `tp_db`
  * Créer l’utilisateur `tp_user` avec mot de passe `tp_password`
  * Donner tous les droits sur la base

### VM 2 : Serveur Web (`web-server`)

* Box : `bento/debian-13`
* IP privée : `192.168.56.10`
* Port forwarding : hôte 8080 → VM 80
* Dossier partagé `./shared → /var/www/html`
* Apache2 + PHP + php-mysql installés
* `index.html` par défaut supprimé automatiquement
* `index.php` créé pour tester la connexion à la DB

### Commandes utiles

```bash
vagrant up
vagrant ssh web
vagrant ssh db
vagrant provision web
vagrant provision db
# Accès au site :
http://localhost:8080
```

---

##  Scripts fournis

* `db_provision.sh` : provisionnement de MariaDB et exécution du script SQL
* `web_provision.sh` : installation Apache + PHP et création du fichier `index.php`
* `db_sql/db_init.sql` : script SQL pour créer la base et l’utilisateur

---

## Notes Git

* `.vagrant/` ignoré
* Contenu du dossier `shared/` ignoré mais le dossier lui-même est suivi via `.gitkeep`


---

## Nettoyage

Pour supprimer toutes les VMs :

```bash
vagrant destroy -f
```

---

## Prérequis

* Vagrant
* VirtualBox
* Git (optionnel)

---

## Auteur

Projet réalisé dans le cadre de la formation **DevOps 2025**.
