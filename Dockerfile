# Build stage
FROM composer:latest as build
WORKDIR /app

# Copy the project files to the container
COPY . .

# Install PHP dependencies using Composer
RUN composer install --prefer-dist --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Production stage
FROM php:8.1-apache as production
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

# Set environment variables
ENV APP_ENV=production
ENV APP_DEBUG=false

# Enable PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Set Apache document root to Laravel's public directory
WORKDIR /var/www/html
RUN sed -i -e 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Copy the application from the build stage to the production stage
COPY --from=build /app /var/www/html

# Set proper permissions for Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Cache Laravel configuration and routes
RUN php artisan config:cache && \
    php artisan route:cache

# Expose the HTTP port
EXPOSE 8080

# Start Apache in foreground
CMD ["apache2-foreground"]
