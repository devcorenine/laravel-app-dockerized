FROM php:8.3-apache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install system dependencies
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpq-dev libzip-dev libonig-dev && \
    docker-php-ext-install pdo pdo_mysql zip && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Ensure Laravel can write to storage and cache
#RUN mkdir -p /var/www/html/storage/framework/{cache,sessions,views} \
#    && mkdir -p /var/www/html/storage/logs \
#    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
#    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Set Apache DocumentRoot to /public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
 && sed -i 's|/var/www/|/var/www/html/public|g' /etc/apache2/apache2.conf

EXPOSE 80

