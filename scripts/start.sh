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
test -f ".env" && echo "Arquivo .env Existe, ignorando copia" | tee -a /start.log || echo "Nao existe, copiando .env.example para .env"; cp .env.example .env | tee -a /start.log
php artisan key:generate | tee -a /start.log

# Aguardando conexão com banco
/wait-for-it.sh -t 0 db:5432 | tee -a /start.log

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

# Gerando documentação com SWAGGER
test -f "config/l5-swagger.php" && echo "Arquivo de configuração swagger existe, gerando documentação..."; php artisan l5-swagger:generate | tee -a /start.log || echo "Nao existe configuração para swagger, ignorando documentação." | tee -a /start.log

# Iniciando PHP-FPM
/usr/sbin/php-fpm7.4 -O
