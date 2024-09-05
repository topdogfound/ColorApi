# Build stage
FROM composer:latest as build
WORKDIR /app
COPY . .
RUN composer install --prefer-dist --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs -vvv

# Production stage
FROM php:8.1-apache-buster as production

# Ensure Apache listens on port 80
EXPOSE 80

# Set Apache server name
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

# Set environment variables
ENV APP_ENV=production
ENV APP_DEBUG=false

# Install PHP extensions
RUN docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install pdo pdo_mysql

# Copy application files from the build stage
COPY --from=build /app /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Cache configuration and routes
RUN php /var/www/html/artisan config:cache && \
    php /var/www/html/artisan route:cache

# Use Apache to serve the application
CMD ["apache2-foreground"]

# Optional: Add a health check
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
