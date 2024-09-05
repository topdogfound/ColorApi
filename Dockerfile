# Build stage
FROM composer:latest as build
WORKDIR /app
COPY . .
RUN composer install --prefer-dist --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs -vvv

# Production stage
FROM php:8.1-apache-buster as production
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

ENV APP_ENV=production
ENV APP_DEBUG=false

RUN docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install pdo pdo_mysql

COPY --from=build /app /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Cache configuration and routes
RUN php artisan config:cache && \
    php artisan route:cache

CMD ["php", "artisan", "serve"]