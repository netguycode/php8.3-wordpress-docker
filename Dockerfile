
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
    PHP_EXTENSION_EXIF=1 \
    APACHE_DOCUMENT=/var/www/html/wordpress

# Enable Apache Modules required by WordPress and for optimizations
RUN \
    # Enable common Apache modules
    a2enmod expires && \
    a2enmod ext_filter && \
    a2enmod headers && \
    a2enmod rewrite && \
    a2enmod deflate && \
    a2enmod ssl && \
    # Enable Brotli compression
    a2enmod brotli

# Install Certbot and Brotli for SSL and compression
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends certbot python3-certbot-apache brotli && \
    # Clean up to minimize the image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install the latest version of WordPress
RUN \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz -C /var/www/html/wordpress/ --strip-components=1 && \
    rm latest.tar.gz && \
    chown -R docker:docker /var/www/html/wordpress

# Install WP-CLI
RUN \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Fix permissions to ensure that the app directory is owned by the non-root user
RUN chown -R docker:docker /var/www/html/wordpress

# Import wp-entrypoint.sh file
COPY wp-entrypoint.sh /usr/local/bin/wp-init.sh

# Expose port 80 and 443
EXPOSE 80

# Modify the entry point to execute the WordPress initialization script before starting Apache
ENTRYPOINT ["/usr/local/bin/wp-init.sh"]

# When the container starts, start Apache as well
CMD ["apache2-foreground"]
