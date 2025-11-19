#!/usr/bin/env bash

apt-get update -y
apt-get install -y mariadb-server


sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb
systemctl enable mariadb

mysql < /vagrant/db_sql/db_init.sql

apt-get install -y php php-mbstring php-mysql apache2 unzip
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.3/phpMyAdmin-5.2.3-all-languages.zip
unzip phpMyAdmin-5.2.3-all-languages.zip

mv phpMyAdmin-5.2.3-all-languages /var/www/html/phpmyadmin

mkdir -p /var/www/html/phpmyadmin/tmp
chown -R www-data:www-data /var/www/html/phpmyadmin
chmod 777 /var/www/html/phpmyadmin/tmp

cat << 'EOF' > /var/www/html/phpmyadmin/config.inc.php
<?php
$cfg['blowfish_secret'] = sodium_hex2bin('f16ce59f45714194371b48fe362072dc3b019da7861558cd4ad29e4d6fb13851');

$i = 0;
$i++;
$cfg['Servers'][$i]['host'] = '192.168.56.11';
$cfg['Servers'][$i]['user'] = 'tp_user';
$cfg['Servers'][$i]['password'] = 'tp_password';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['AllowNoPassword'] = false;
?>
EOF

systemctl restart apache2