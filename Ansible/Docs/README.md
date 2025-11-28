# 📘 Résumé : Ce que j’ai appris sur Ansible

Ce document synthétise les notions essentielles apprises lors de la réalisation du projet d’automatisation avec Ansible. Il sert de guide clair et organisé pour garder en tête les concepts fondamentaux.

---

## 🧩 1. Qu’est-ce qu’Ansible ?

Ansible est un outil d’automatisation qui permet de :

* déployer des applications
* configurer des serveurs
* gérer des environnements complets

Son fonctionnement est **déclaratif**, sans agent, et repose principalement sur SSH.

---

## 📂 2. Structure d’un projet Ansible

Un projet organisé contient généralement :

* **playbook.yml** : la liste des actions à exécuter
* **inventory.ini** : la liste des machines cibles
* **ansible.cfg** : configuration Ansible
* **roles/** : regroupement des tâches selon un thème (web, db, etc.)

Les rôles apportent :

* une structure propre
* la réutilisation
* la séparation des responsabilités

---

## 🎭 3. Les Playbooks

Un playbook décrit

* **sur quelles machines agir** (hosts)
* **avec quels privilèges** (become)
* **quels rôles ou tâches exécuter**

Exemple de structure :

```yaml
- name: Configuration commune
  hosts: all
  roles:
    - common
```

Un playbook peut appeler plusieurs rôles, chaque rôle ayant ses propres tâches.

---

## ⚙️ 4. Les Rôles

Un rôle permet de regrouper :

* **tasks/** : actions exécutées
* **defaults/** : variables par défaut
* **templates/** : fichiers Jinja2
* **files/** : fichiers statiques
* **handlers/** : actions conditionnelles (ex : redémarrer un service)

Exemple : un rôle *web* pour installer Apache, un rôle *db* pour MariaDB.

---

## 🧪 5. Les modules Ansible

Ansible fournit des modules préconstruits pour éviter de tout faire à la main.
Quelques modules utilisés :

* `apt` : installation de paquets
* `service` / `systemd` : gestion de services
* `git` : clonage d’un dépôt
* `mysql_db` et `mysql_user` : gestion MariaDB
* `ufw` : firewall
* `template` : génération de fichiers à partir de variables

Chaque module est robuste et idempotent (ne fait rien si l’état est déjà correct).

---

## 🧷 6. Les Variables & Defaults

Les variables permettent de rendre les rôles réutilisables.
Elles peuvent être définies dans :

* `defaults/main.yml`
* `vars/main.yml`
* l’inventaire
* la ligne de commande

Exemple :

```yaml
db_name: covoit
```

---

## 🔁 7. Boucles & Conditions

Ansible permet d’exécuter plusieurs fois une tâche avec `loop` :

```yaml
loop: "{{ common_firewall_port }}"
```

Et ajoute des conditions :

```yaml
when: not web_site_enabled.stat.exists
```

---

## 🛎️ 8. Les Handlers

Les handlers sont déclenchés uniquement si une tâche notifie un changement.

Exemple :

```yaml
notify: Restart Apache
```

Cela évite des redémarrages inutiles.

---

## 🏷️ 9. Les Tags

Les tags permettent d’exécuter :

* seulement certaines tâches (`--tags`)
* ou au contraire tout sauf ces tâches (`--skip-tags`)

Exemples :

```bash
ansible-playbook playbook.yml --tags firewall
ansible-playbook playbook.yml --skip-tags update
```

---

## 🔐 10. Ansible Vault

Vault permet de **chiffrer des fichiers sensibles** (certificats, mots de passe…).

Commandes principales :

```bash
ansible-vault encrypt fichier.yml
ansible-vault decrypt fichier.yml
ansible-playbook playbook.yml --ask-vault-pass
```

Cela garantit que les informations confidentielles ne sont pas visibles.

---

## 🧠 11. Ce que j’ai réellement appris

* Organiser un projet Ansible propre avec des rôles
* Déployer automatiquement un environnement complet
* Utiliser des templates, des modules, des handlers
* Gérer des bases de données avec Ansible
* Faire communiquer des machines (web ↔ db)
* Sécuriser mes fichiers grâce à Vault
* Utiliser Vagrant pour créer des machines de test

---
