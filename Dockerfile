# FROM php:8.4-fpm-alpine

# # Install dependencies
# RUN apk add --no-cache \
#     nginx \
#     supervisor \
#     curl \
#     git \
#     unzip \
#     libzip-dev \
#     oniguruma-dev \
#     icu-dev \
#     libpng-dev \
#     libjpeg-turbo-dev \
#     freetype-dev

# # PHP extensions
# RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
#     && docker-php-ext-install \
#     pdo \
#     pdo_mysql \
#     mbstring \
#     zip \
#     bcmath \
#     intl \
#     gd \
#     exif \
#     pcntl

# # Install Composer
# COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# WORKDIR /var/www/html

# # ✅ COPY FULL PROJECT FIRST (IMPORTANT FIX)
# COPY . .

# # Install dependencies (now artisan exists)
# RUN COMPOSER_ALLOW_SUPERUSER=1 \
#     composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# # Permissions
# RUN chown -R www-data:www-data storage bootstrap/cache

# # Clear cache (safe)
# RUN php artisan config:clear || true
# RUN php artisan cache:clear || true
# RUN php artisan view:clear || true

# # Copy configs
# COPY docker/nginx.conf /etc/nginx/http.d/default.conf
# COPY docker/supervisord.conf /etc/supervisord.conf
# COPY docker/entrypoint.sh /entrypoint.sh

# RUN chmod +x /entrypoint.sh

# EXPOSE 8080

# CMD ["/entrypoint.sh"]

FROM php:8.4-cli

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy full project
COPY . .

# 🔥 VERY IMPORTANT: disable scripts during build
RUN COMPOSER_ALLOW_SUPERUSER=1 \
    composer install --no-dev --no-scripts --optimize-autoloader --no-interaction

# Generate key (safe)
RUN php artisan key:generate || true

# Now run scripts manually (safe fallback)
RUN php artisan package:discover || true

# Clear cache
RUN php artisan config:clear || true
RUN php artisan cache:clear || true

EXPOSE 8080

CMD php artisan serve --host=0.0.0.0 --port=8080
