# Use official PHP with Apache
FROM php:8.3-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpq-dev libzip-dev libonig-dev \
 && docker-php-ext-install pdo pdo_mysql zip \
 && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module (needed for Laravel routing)
RUN a2enmod rewrite

# Install Composer (from official composer image)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy Laravel application code
COPY . .

# Install Laravel dependencies (production optimized)
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist \
 && php artisan config:clear \
 && php artisan route:clear \
 && php artisan cache:clear

# Set proper permissions for storage and bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
 && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configure Apache DocumentRoot to use Laravel's /public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
 && sed -i 's|/var/www/|/var/www/html/public|g' /etc/apache2/apache2.conf

# Expose port 80 for Apache
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]

