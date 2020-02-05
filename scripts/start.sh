#!/bin/bash

###
# Laravel configuration
###
echo "Instalando dependencias..."
cd /application | tee -a /start.log
composer install --no-progress --no-suggest --prefer-dist | tee -a /start.log
# config timezone

# config locale

# generate key
echo "Gerando chave" | tee -a /start.log
cp .env.example .env | tee -a /start.log
php artisan key:generate | tee -a /start.log

# setup permission
# chmod 775 app storage bootstrap -R

# migrate data base
echo "Migrando banco de dados..." | tee -a /start.log
php artisan migrate --force | tee -a /start.log

# Alimentando banco
echo "Alimentando banco..." | tee -a /start.log
php artisan db:seed --force | tee -a /start.log

# Aplicando permissões na pasta storage e bootstrap
echo "Aplicando permissões na pasta storage e bootstrap" | tee -a /start.log
chown -R $USER:www-data storage bootstrap/cache | tee -a /start.log
chmod -R ug+rwx storage bootstrap/cache | tee -a /start.log

# linkando storage
echo "Linkando storage..." | tee -a /start.log
php artisan storage:link | tee -a /start.log

# Iniciando PHP-FPM
/usr/sbin/php-fpm7.4 -O
