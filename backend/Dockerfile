# backend/Dockerfile - Grosirun Laravel 11 - GAP Docker Fixed
FROM php:8.3-fpm-alpine

# System deps
RUN apk add --no-cache nginx supervisor libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev icu-dev mysql-client oniguruma-dev libxml2-dev curl

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring zip exif pcntl bcmath opcache

# Imagick + Redis via pecl
RUN apk add --no-cache imagemagick-dev $PHPIZE_DEPS \
    && pecl install imagick redis \
    && docker-php-ext-enable imagick redis \
    && apk del $PHPIZE_DEPS

# Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy code
COPY . .

# Install deps (may fail if no .env, ignore)
RUN composer install --no-dev --optimize-autoloader --no-interaction || composer install --optimize-autoloader --no-interaction || true

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 9000 80

CMD ["php-fpm"]
