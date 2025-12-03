FROM php:8.2-apache

# Installation de l'extension PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copie des fichiers
COPY . /var/www/html/

EXPOSE 80
