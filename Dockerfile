FROM phpdockerio/php74-fpm:latest

WORKDIR /application

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install  php7.4-pgsql php-redis php7.4-sqlite3 \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

ENV COMPOSER_ALLOW_SUPERUSER=1

# Copiando configuração nginx
COPY ./scripts/start.sh /start.sh
RUN chmod +x /start.sh

# Condig PHP
RUN echo 'upload_max_filesize = 800M' >> /etc/php/7.4/fpm/conf.d/99-overrides.ini \
    && echo 'post_max_size = 808M' >> /etc/php/7.4/fpm/conf.d/99-overrides.ini \
    && echo 'memory_limit = -1' >> /etc/php/7.4/fpm/conf.d/99-overrides.ini \
    && echo 'max_input_vars = 3000' >> /etc/php/7.4/fpm/conf.d/99-overrides.ini

CMD ["/bin/bash", "/start.sh"]
