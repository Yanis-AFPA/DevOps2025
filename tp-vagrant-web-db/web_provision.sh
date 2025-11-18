#!/usr/bin/env bash

apt-get update -y
apt-get install -y apache2 php php-mysql libapache2-mod-php

systemctl enable apache2
systemctl restart apache2

cat << 'EOF' > /var/www/html/index.php
<?php
$mysqli = new mysqli("192.168.56.11", "tp_user", "tp_password", "tp_db");
if ($mysqli->connect_errno) {
    echo "<h1 style='color:red'>Échec connexion DB : " . $mysqli->connect_error . "</h1>";
} else {
    echo "<h1 style='color:green'>Connexion à la base de données réussie !</h1>";
}
?>
EOF

chown www-data:www-data /var/www/html/index.php
