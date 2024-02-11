**PHP 8.3 WordPress - NetGuy Variant**

**Description:**
This Dockerfile and entrypoint script combination facilitates the deployment of WordPress applications within a Docker container. The Dockerfile extends from thecodingmachine/php image, providing a pre-configured PHP environment with Apache web server. The entrypoint script handles initialization and configuration of WordPress upon container startup, including environment variable validation, database setup, wp-config.php generation, and plugin activation.

**Usage:**
1. **Building the Docker Image:**
   - Place the Dockerfile and entrypoint script in the root directory of your WordPress project.
   - Run the following command to build the Docker image:
     ```
     docker build -t your-image-name .
     ```
   Replace `your-image-name` with the desired name for your Docker image.

2. **Running the Docker Container:**
   - Before running the container, ensure you have a MySQL/MariaDB database set up with appropriate credentials.
   - Define the required environment variables:
     - `SITE_URL`: URL of your WordPress site.
     - `WORDPRESS_DB_NAME`: Name of the WordPress database.
     - `WORDPRESS_DB_USER`: Username for accessing the WordPress database.
     - `WORDPRESS_DB_PASSWORD`: Password for the WordPress database user.
     - `WORDPRESS_DB_HOST`: Hostname or IP address of the database server.
   - Optionally, set additional environment variables to customize WordPress settings:
     - `WORDPRESS_TABLE_PREFIX`: Database table prefix (default is `wp_`).
     - `WORDPRESS_MEMORY_LIMIT`: PHP memory limit for WordPress (default is `256M`).
     - `SITE_NAME`: Name of your WordPress site (default is `Your Site Name`).
     - `SITE_DESCRIPTION`: Description of your WordPress site (default is `Your Site Description`).
     - `WORDPRESS_DEBUG`: Enable WordPress debugging (default is `false`).
     - `WORDPRESS_DEBUG_DISPLAY`: Display PHP errors (default is `false`).
     - `WORDPRESS_DEBUG_LOG`: Log PHP errors to wp-content/debug.log (default is `true`).
     - `WORDPRESS_AUTO_UPDATE_CORE`: Enable auto-updates for WordPress core (default is `true`).
     - `AUTOMATIC_UPDATER_DISABLED`: Disable automatic updates (default is `false`).
     - `WP_ALLOW_MULTISITE`: Enable WordPress multisite (default is `true`).
     - `WORDPRESS_POST_REVISIONS`: Number of post revisions to keep (default is `5`).
     - `DISALLOW_FILE_EDIT`: Disallow file editing from WordPress admin (default is `false`).
     - `FORCE_SSL_ADMIN`: Force SSL for WordPress admin (default is `true`).
     - `REDIS_HOST`: Hostname or IP address of Redis server for object caching (optional).
     - `REDIS_PORT`: Port number of Redis server (optional).
     - `REDIS_PASSWORD`: Password for Redis server (optional).
   - Run the Docker container with the following command:
     ```
     docker run -d \
     -e SITE_URL=your-site-url \
     -e WORDPRESS_DB_NAME=your-db-name \
     -e WORDPRESS_DB_USER=your-db-user \
     -e WORDPRESS_DB_PASSWORD=your-db-password \
     -e WORDPRESS_DB_HOST=your-db-host \
     -e WORDPRESS_TABLE_PREFIX=wp_ \
     -e WORDPRESS_MEMORY_LIMIT=256M \
     -e SITE_NAME="Your Site Name" \
     -e SITE_DESCRIPTION="Your Site Description" \
     -e WORDPRESS_DEBUG=false \
     -e WORDPRESS_DEBUG_DISPLAY=false \
     -e WORDPRESS_DEBUG_LOG=true \
     -e WORDPRESS_AUTO_UPDATE_CORE=true \
     -e AUTOMATIC_UPDATER_DISABLED=false \
     -e WP_ALLOW_MULTISITE=true \
     -e WORDPRESS_POST_REVISIONS=5 \
     -e DISALLOW_FILE_EDIT=false \
     -e FORCE_SSL_ADMIN=true \
     -e REDIS_HOST=optional \
     -e REDIS_PORT=optional \
     -e REDIS_PASSWORD=optional \
     -p 80:80 \
     your-image-name
     ```
   Replace `your-site-url`, `your-db-name`, `your-db-user`, `your-db-password`, `your-db-host`, and `your-image-name` with appropriate values.

**Customization:**
- **Adding PHP Extensions:** Modify the `PHP_EXTENSION_` environment variables in the Dockerfile to include additional PHP extensions required by your WordPress site.
- **WordPress Configuration:** Customize the wp-config.php generation process in the entrypoint script to suit your specific requirements, such as defining custom constants or enabling/disabling features.
- **Plugin Activation:** Modify the entrypoint script to activate/deactivate specific plugins upon container startup as needed.

**Notes:**
- This setup assumes Apache as the web server. Adjustments may be necessary if you prefer using a different web server (e.g., Nginx).
- Ensure your Docker environment is properly configured, and you have appropriate permissions to execute Docker commands and access resources.

**References:**
- [Docker Documentation](https://docs.docker.com/)
- [thecodingmachine/php Docker Image](https://hub.docker.com/r/thecodingmachine/php)
- [WordPress Documentation](https://wordpress.org/support/)
- [WP-CLI Documentation](https://wp-cli.org/)

**Author:**
[NetGuy](https://netguy.com.au/)

**License:**
[Specify any licensing information or terms of use if applicable]
