#------------------------------------------------------------------------------
# Stage 1: Build the php app
#------------------------------------------------------------------------------
FROM php:8.3-cli-alpine AS builder

RUN set -eux; \
  apk add --no-cache \
  # Minimal packages required for building PHP extensions for drupal/core-recommended
  # Existing Drupal projects may need git/patch/curl support for additional dependencies
  # git patch curl \
  zip \
  freetype-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libzip-dev; \
  docker-php-ext-configure gd --with-freetype --with-jpeg; \
  docker-php-ext-install gd zip

# Get the composer binary from the official composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY web/ ./web/
COPY config/ ./config/
COPY composer.json composer.lock ./

# Install dependencies and optimize autoloader
RUN composer install \
  --no-dev --no-interaction --prefer-dist --optimize-autoloader

#------------------------------------------------------------------------------
# Stage 2: Create the final image
#------------------------------------------------------------------------------
FROM serversideup/php:8.3-fpm-nginx-alpine

# Configure PHP, NGINX, and other settings, via environment variables!
# A full list of configurable items is listed at the end of this file or at:
# https://serversideup.net/open-source/docker-php/docs/reference/environment-variable-specification
ENV NGINX_WEBROOT=/var/www/html/web

# Install system dependencies
USER root
RUN install-php-extensions gd redis

# Copy the application from the builder stage
USER www-data
# COPY --from=builder --chown=www-data:www-data /app /var/www/html
COPY --from=builder --chown=www-data:www-data /app/vendor /var/www/html/vendor
COPY --from=builder --chown=www-data:www-data /app/config /var/www/html/config
COPY --from=builder --chown=www-data:www-data /app/web /var/www/html/web

# Expose default ports for NGINX. Remember to set app_port in Kamal's deploy.yml to match!
EXPOSE 8080 8443

# APACHE_DOCUMENT_ROOT=/var/www/html/public
# APACHE_MAX_CONNECTIONS_PER_CHILD=0
# APACHE_MAX_REQUEST_WORKERS=150
# APACHE_MAX_SPARE_THREADS=75
# APACHE_MIN_SPARE_THREADS=10
# APACHE_RUN_GROUP=www-data
# APACHE_RUN_USER=www-data
# APACHE_START_SERVERS=2
# APACHE_THREAD_LIMIT=64
# APACHE_THREADS_PER_CHILD=25
# APP_BASE_DIR=/var/www/html
# AUTORUN_ENABLED=false
# AUTORUN_LARAVEL_CONFIG_CACHE=true
# AUTORUN_LARAVEL_EVENT_CACHE=true
# AUTORUN_LARAVEL_MIGRATION=true
# AUTORUN_LARAVEL_MIGRATION_ISOLATION=false
# AUTORUN_LARAVEL_MIGRATION_TIMEOUT=30
# AUTORUN_LARAVEL_ROUTE_CACHE=true
# AUTORUN_LARAVEL_STORAGE_LINK=true
# AUTORUN_LARAVEL_VIEW_CACHE=true
# COMPOSER_ALLOW_SUPERUSER=1
# COMPOSER_HOME=/composer
# COMPOSER_MAX_PARALLEL_HTTP=24
# DISABLE_DEFAULT_CONFIG=false
# HEALTHCHECK_PATH=/healthcheck
# LOG_OUTPUT_LEVEL=warn
# NGINX_FASTCGI_BUFFERS=8 8k
# NGINX_FASTCGI_BUFFER_SIZE=8k
# NGINX_SERVER_TOKENS=off
# NGINX_WEBROOT=`/var/www/html/public
# PHP_DATE_TIMEZONE=UTC
# PHP_DISPLAY_ERRORS=Off"
# PHP_DISPLAY_STARTUP_ERRORS=Off
# PHP_ERROR_LOG=/dev/stderr
# PHP_ERROR_REPORTING=22527
# PHP_FPM_PM_CONTROL=fpm: dynamic; fpm-apache: ondemand; fpm-nginx: ondemand
# PHP_FPM_PM_MAX_CHILDREN=20
# PHP_FPM_PM_MAX_SPARE_SERVERS=3
# PHP_FPM_PM_MIN_SPARE_SERVERS=1
# PHP_FPM_PM_START_SERVERS=2
# PHP_FPM_POOL_NAME=www
# PHP_FPM_PROCESS_CONTROL_TIMEOUT=10s
# PHP_MAX_EXECUTION_TIME=99
# PHP_MAX_INPUT_TIME=-1
# PHP_MEMORY_LIMIT=256M
# PHP_OPCACHE_ENABLE=0 #(to keep developers sane)
# PHP_OPCACHE_INTERNED_STRINGS_BUFFER=8
# PHP_OPCACHE_MAX_ACCELERATED_FILES=10000
# PHP_OPCACHE_MEMORY_CONSUMPTION=128
# PHP_OPCACHE_REVALIDATE_FREQ=2
# PHP_OPEN_BASEDIR=None
# PHP_POST_MAX_SIZE=100M
# PHP_SESSION_COOKIE_SECURE=1 #(true)
# PHP_UPLOAD_MAX_FILE_SIZE=100M
# S6_BEHAVIOUR_IF_STAGE2_FAILS=2 #(stop the container)
# S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0
# S6_VERBOSITY=1
# SHOW_WELCOME_MESSAGE=true
# SSL_CERTIFICATE_FILE=/etc/ssl/private/self-signed-web.crt
# SSL_MODE=off
# SSL_PRIVATE_KEY_FILE=/etc/ssl/private/self-signed-web.key
# UNIT_CERTIFICATE_NAME=self-signed-web-bundle
# UNIT_CONFIG_DIRECTORY=/etc/unit/config.d
# UNIT_CONFIG_FILE=/etc/unit/config.d/config.json
# UNIT_PROCESSES_IDLE_TIMEOUT=30y
# UNIT_PROCESSES_MAX=20
# UNIT_PROCESSES_SPARE=2
# UNIT_WEBROOT=/var/www/html/public
# UNIT_MAX_BODY_SIZE=104857600 #(100MB)

