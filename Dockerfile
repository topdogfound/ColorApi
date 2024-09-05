# Build stage
FROM composer:latest as build
WORKDIR /app
COPY . .
RUN composer install --prefer-dist --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs -vvv

# Production stage
FROM php:8.1-apache-buster as production

# Render expects the service to listen on port 8080
EXPOSE 8080

# Ensure Apache listens on port 8080 (Render requirement)
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf

# Set Apache server name
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

# Set environment variables for Laravel
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV APP_URL=http://localhost:8080

# Install necessary PHP extensions
RUN docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install pdo pdo_mysql

# Copy application from the build stage
COPY --from=build /app /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Cache Laravel configuration and routes
RUN php /var/www/html/artisan config:cache && \
    php /var/www/html/artisan route:cache

# Start Apache in the foreground
CMD ["apache2-foreground"]
