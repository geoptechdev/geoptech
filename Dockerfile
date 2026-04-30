FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache nginx supervisor curl git unzip libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files first (for caching)
COPY composer.json composer.lock ./

RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy full project
COPY . .

# Optimize autoload
RUN composer dump-autoload --optimize

# Fix permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Clear Laravel cache
RUN php artisan config:clear && \
    php artisan cache:clear && \
    php artisan view:clear

# Copy configs
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# 🔥 IMPORTANT: Bunny requires 8080
EXPOSE 8080

CMD ["/entrypoint.sh"]
