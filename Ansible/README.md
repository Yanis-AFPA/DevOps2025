# Projet tp2_webapp_deployment

# 📘 Déploiement Automatisé avec Ansible & Vagrant 

Ce projet met en place automatiquement une infrastructure composée de deux machines virtuelles :

* **app1** : serveur web (Apache + application PHP) + client OpenVPN
* **app2** : serveur base de données (MariaDB)

L’ensemble est orchestré avec **Ansible**, et les machines sont gérées via **Vagrant**.

---

## 🚀 1. Prérequis

Avant d’utiliser ce projet, installez :

* **Vagrant**
* **VirtualBox**
* **Ansible** 


---

## 🏗️ 2. Architecture du projet

```
.
├── Vagrantfile
├── ansible.cfg
├── inventory.ini
├── playbook.yml
├── roles/
│   ├── common/
│   ├── web/
│   ├── db/
│   └── openvpn/
```

### 🧩 Rôles Ansible

* **common** : mise à jour du système, installation firewall UFW, ouverture des ports.
* **web** : installation Apache, PHP, clonage de l'application web, configuration du VirtualHost.
* **db** : installation MariaDB, création BDD + utilisateur, import du schéma.
* **openvpn** : installation OpenVPN + stunnel et déploiement du client.

---

## ▶️ 3. Lancement de l’infrastructure

### 1️⃣ Démarrer les machines virtuelles

Dans le dossier du projet :

```bash
vagrant up
```

Vagrant va :

* télécharger l'image Ubuntu
* créer **app1** et **app2**
* configurer les réseaux privés

---

## 🔧 4. Déployer la configuration Ansible

Une fois les machines démarrées, exécutez :

```bash
ansible-playbook  playbook.yml
```

Cela exécutera :

* les tâches **common** sur toutes les machines
* les tâches **web** + **openvpn** sur **app1**
* les tâches **db** sur **app2**

---

## 🧪 5. Vérifier que tout fonctionne

### 🌐 Serveur Web (app1)

Ouvrez votre navigateur et allez sur :

```
http://192.168.56.111
```

Vous devriez voir l'application PHP déployée.

### 🗄️ Serveur DB (app2)

La base MariaDB écoute sur toutes les interfaces.
Vous pouvez tester la connexion depuis app1.


## 🧹 6. Détruire l’environnement

Si vous souhaitez supprimer les VM :

```bash
vagrant destroy -f
```

---

## 📝 7. Notes

* Les fichiers sensibles du rôle **openvpn** sont gérés via **Ansible Vault**.
* Le projet est conçu pour être réutilisé et facilement modifiable.

---

## 🏷️ 8. Utilisation des tags Ansible

Les rôles et certaines tâches de ce projet peuvent être exécutés via des **tags**, ce qui permet de lancer uniquement une partie du playbook.

### ▶️ Exécuter uniquement un tag

Par exemple, pour n’exécuter que les tâches liées au firewall :

```bash
ansible-playbook playbook.yml --tags firewall
```

### ⏭️ Exécuter tout sauf un tag

Pour lancer tout le playbook **sauf** les tâches du firewall :

```bash
ansible-playbook playbook.yml --skip-tags firewall
```

Vous pouvez utiliser cette méthode avec tous les tags définis dans les rôles (ex : `update`, `install`, `firewall`, etc.).

---

## 🔐 9. Sécurité avec Ansible Vault

Le rôle **openvpn** contient des fichiers sensibles (certificats, clés, mots de passe). Pour éviter de les divulguer, ils sont stockés grâce à **Ansible Vault**.

### 📦 Crypter un fichier

```bash
ansible-vault encrypt roles/openvpn/defaults/main.yml
```

### 🔓 Décrypter un fichier

```bash
ansible-vault decrypt roles/openvpn/defaults/main.yml
```

### ▶️ Exécuter un playbook utilisant des fichiers Vault

Si votre playbook contient des fichiers chiffrés, lancez-le ainsi :

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

Cela garantit que les informations sensibles (comme les `.ovpn`, clés, ports VPN…) restent protégées et n
Vous disposez maintenant d’un environnement complet web + base de données, totalement automatisé avec Ansible et déployable en un seul `vagrant up` !
