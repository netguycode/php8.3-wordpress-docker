# Use thecodingmachine/php image as the base
FROM thecodingmachine/php:8.3-v4-apache

# Set environment variables to non-root user provided by TheCodingMachine images
ENV APACHE_RUN_USER=docker
ENV APACHE_RUN_GROUP=docker

# Install PHP extensions required by WordPress and for performance optimization
ENV PHP_EXTENSION_GD=1 \
    PHP_EXTENSION_INTL=1 \
    PHP_EXTENSION_IMAGICK=1 \
    PHP_EXTENSION_GMP=1 \
    PHP_EXTENSION_MYSQLI=1 \
    PHP_EXTENSION_PDO=1 \
    PHP_EXTENSION_PDO_MYSQL=1 \
    PHP_EXTENSION_ZIP=1 \
    PHP_EXTENSION_CURL=1 \
    PHP_EXTENSION_MBSTRING=1 \
    PHP_EXTENSION_XML=1 \
    PHP_EXTENSION_SOAP=1 \
    PHP_EXTENSION_BCMATH=1 \
    PHP_EXTENSION_EXIF=1

# Enable Apache Modules required by WordPress and for optimizations
RUN a2enmod expires && \
    a2enmod ext_filter && \
    a2enmod headers && \
    a2enmod rewrite && \
    a2enmod deflate

# Install and enable Brotli for Apache
RUN apt-get update && \
    apt-get install -y --no-install-recommends brotli && \
    a2enmod brotli

# Clean up to minimize the image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*
\

# Copy your application code to the container (assuming your application is in the "app" directory)
COPY ./wp-init.sh /usr/local/bin/wp-init.sh

# Fix permissions to ensure that the app directory is owned by the non-root user
RUN chown -R docker:docker /var/www/html

# Expose port 80 and 443
EXPOSE 80 443

# Modify the entry point to execute the WordPress initialization script before starting Apache
ENTRYPOINT ["/usr/local/bin/wp-init.sh"]

# When the container starts, start Apache as well
CMD ["apache2-foreground"]
