FROM php:8.2-apache


RUN docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-enable mysqli pdo_mysql \
    && apt-get update && apt-get install -y default-mysql-client \
    && a2enmod rewrite \
    && chown -R www-data:www-data /var/www


# Copier la configuration Apache custom
COPY apache.conf /etc/apache2/sites-available/000-default.conf

COPY app/ /var/www

WORKDIR /var/www/web

# Pas obligatoire car ouvert dans le docker compose
# Mais ça sert de documentation et permet à Docker d’automatiser le mapping si nécessaire.
# EXPOSE 80
