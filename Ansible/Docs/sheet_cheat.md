# ⚡ Ansible Cheat Sheet

Un aide‑mémoire simple et rapide pour retrouver l’essentiel d’Ansible.

---

## 🔧 Commandes de base

```bash
ansible all -m ping                # Tester la connexion SSH
ansible-playbook playbook.yml      # Lancer un playbook
ansible-inventory --list           # Voir l’inventaire
```

---

## 📁 Structure d’un projet

```
project/
├── inventory.ini
├── ansible.cfg
├── playbook.yml
└── roles/
    ├── role_name/
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   ├── templates/
    │   ├── files/
    │   └── defaults/main.yml
```

---

## 🖥️ Inventaire (inventory.ini)

```ini
[webservers]
app1 ansible_host=192.168.56.111

't[dbservers]'
app2 ansible_host=192.168.56.112
```

---

## 📘 Playbook minimal

```yaml
- hosts: webservers
  become: true
  roles:
    - web
```

---

## 🛠️ Modules fréquents

Les modules ci‑dessous sont parmi les **plus utilisés** dans Ansible.

```yaml
apt:            # Installer/mettre à jour des paquets Debian
yum:            # Installer/mettre à jour des paquets RPM
service:        # Gérer les services (start/stop/restart)
systemd:        # Gérer les services systemd
copy:           # Copier des fichiers locaux → distant
template:       # Déployer un fichier Jinja2
git:            # Cloner ou mettre à jour un dépôt Git
file:           # Créer/supprimer des fichiers & permissions
lineinfile:     # Modifier une ligne dans un fichier
stat:           # Vérifier l'existence d'un fichier
command:        # Lancer une commande (non idempotent)
shell:          # Exécuter une commande shell (prudent !)
package:        # Gestion générique de paquet (apt/yum/etc.)
user:           # Créer/supprimer un utilisateur
group:          # Gérer les groupes
unarchive:      # Décompresser une archive
uri:            # Appeler une URL (test HTTP)
get_url:        # Télécharger un fichier via HTTP/HTTPS
mysql_db:       # Créer ou supprimer une base MariaDB/MySQL
mysql_user:     # Gérer les utilisateurs MySQL/MariaDB
```

---

## 🔁 Boucles

```yaml
loop:
  - 80
  - 443
```

---

## ❓ Conditions

```yaml
when: web_site_enabled.stat.exists == false
```

---

## 🛎️ Handlers

```yaml
notify: Restart Apache
```

---

## 🏷️ Tags

```bash
ansible-playbook playbook.yml --tags firewall
ansible-playbook playbook.yml --skip-tags install
```

---

## 🔐 Vault

```bash
ansible-vault encrypt fichier.yml
ansible-vault decrypt fichier.yml
ansible-playbook playbook.yml --ask-vault-pass
```

---

## 🚀 Exécution rapide type

```bash
vagrant up
ansible-playbook -i inventory.ini playbook.yml
```

---

## 🧠 Rappels clés

* Ansible est **idempotent** (ne refait pas ce qui est déjà en place).
* Les rôles permettent de structurer proprement.
* Vault protège les fichiers sensibles.
* Les handlers ne s’exécutent **que si quelque chose change**.

---

Si tu veux, je peux te faire :

* une version imprimable
* une version ultra condensée
* une version en anglais
