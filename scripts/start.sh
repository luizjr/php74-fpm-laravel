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
test -f ".env" && echo "Arquivo .env Existe, ignorando copia" | tee -a /start.log || echo "Nao existe, copiando .env.example para .env" && cp .env.example .env | tee -a /start.log
php artisan key:generate | tee -a /start.log

# setup permission
# chmod 775 app storage bootstrap -R

# Aguardando conexão com banco
printf "%s" "Waiting for Banco de Dados ..." | tee -a /start.log
while ! timeout 0.2 ping -c 1 -n db &> /dev/null
do
    printf "%c" "." | tee -a /start.log
done
printf "\n%s\n"  "Server is back online" | tee -a /start.log

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
