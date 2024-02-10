#!/bin/bash

# Check required environment variables and exit if any are missing
required_vars=("SITE_URL" "WORDPRESS_DB_NAME" "WORDPRESS_DB_USER" "WORDPRESS_DB_PASSWORD" "WORDPRESS_DB_HOST")
for var_name in "${required_vars[@]}"; do
    if [ -z "${!var_name}" ]; then
        echo "Error: Environment variable $var_name is not set. This script requires SITE_URL, WORDPRESS_DB_NAME, WORDPRESS_DB_USER, WORDPRESS_DB_PASSWORD, and WORDPRESS_DB_HOST to be set."
        exit 1
    fi
done

# Fetch configuration from environment variables
SITE_URL="${SITE_URL}"
WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME}"
WORDPRESS_DB_USER="${WORDPRESS_DB_USER}"
WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD}"
WORDPRESS_DB_HOST="${WORDPRESS_DB_HOST}"
WORDPRESS_TABLE_PREFIX="${WORDPRESS_TABLE_PREFIX:-wp_}"
WORDPRESS_MEMORY_LIMIT="${WORDPRESS_MEMORY_LIMIT:-256M}"
SITE_NAME="${SITE_NAME:-Your Site Name}"
SITE_DESCRIPTION="${SITE_DESCRIPTION:-Your Site Description}"
WORDPRESS_DEBUG="${WORDPRESS_DEBUG:-false}"
WORDPRESS_DEBUG_DISPLAY="${WORDPRESS_DEBUG_DISPLAY:-false}"
WORDPRESS_DEBUG_LOG="${WORDPRESS_DEBUG_LOG:-true}"
WORDPRESS_AUTO_UPDATE_CORE="${WORDPRESS_AUTO_UPDATE_CORE:-true}"
AUTOMATIC_UPDATER_DISABLED="${AUTOMATIC_UPDATER_DISABLED:-false}"
WP_ALLOW_MULTISITE="${WP_ALLOW_MULTISITE:-true}"
WORDPRESS_POST_REVISIONS="${WORDPRESS_POST_REVISIONS:-5}"
DISALLOW_FILE_EDIT="${DISALLOW_FILE_EDIT:-false}"
FORCE_SSL_ADMIN="${FORCE_SSL_ADMIN:-true}"

# Path to WordPress installation
WP_PATH="/var/www/html/wordpress"

# Ensure necessary utilities are installed
if [ ! -x "$(command -v brotli)" ]; then
    apt-get update && apt-get install -y brotli
fi

if [ ! -x "$(command -v wp)" ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Set permissions for WordPress directory
chown -R www-data:www-data ${WP_PATH}

# Create a PHP file to detect Cloudflare
echo "<?php echo isset(\$_SERVER['HTTP_CF_CONNECTING_IP']) ? 'YES' : 'NO'; ?>" > "${WP_PATH}/cf-detect.php"

# Attempt to detect Cloudflare
CLOUDFLARE_RESPONSE=$(curl -s "${SITE_URL}/cf-detect.php")
if [ "$CLOUDFLARE_RESPONSE" = "YES" ]; then
    CLOUDFLARE_DETECTED=1
else
    CLOUDFLARE_DETECTED=0
fi

# Remove the cf-detect.php file after checking
rm -f "${WP_PATH}/cf-detect.php"

# Create wp-config.php if it does not exist
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    cat > "${WP_PATH}/wp-config.php" <<EOL
<?php
define('WP_HOME','${SITE_URL}');
define('WP_SITEURL','${SITE_URL}');
define( 'DB_NAME', '${WORDPRESS_DB_NAME}' );
define( 'DB_USER', '${WORDPRESS_DB_USER}' );
define( 'DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}' );
define( 'DB_HOST', '${WORDPRESS_DB_HOST}' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
\$table_prefix  = '${WORDPRESS_TABLE_PREFIX}';
define('WP_DEBUG', ${WORDPRESS_DEBUG});
define('WP_DEBUG_DISPLAY', ${WORDPRESS_DEBUG_DISPLAY});
define('WP_DEBUG_LOG', ${WORDPRESS_DEBUG_LOG});
define('WP_AUTO_UPDATE_CORE', ${WORDPRESS_AUTO_UPDATE_CORE});
define('AUTOMATIC_UPDATER_DISABLED', ${AUTOMATIC_UPDATER_DISABLED});
define('WP_ALLOW_MULTISITE', ${WP_ALLOW_MULTISITE});
define('WP_MEMORY_LIMIT', '${WORDPRESS_MEMORY_LIMIT}');
define('WP_POST_REVISIONS', ${WORDPRESS_POST_REVISIONS});
define('DISALLOW_FILE_EDIT', ${DISALLOW_FILE_EDIT});
define('FORCE_SSL_ADMIN', ${FORCE_SSL_ADMIN}); // WP_HOME & WP_SITEURL must start with "https://"
\$_SERVER['HTTPS'] = 'on';
EOL

    if [ $CLOUDFLARE_DETECTED -eq 1 ]; then
        cat >> "${WP_PATH}/wp-config.php" <<'EOL'
// Cloudflare settings
if (isset($_SERVER['HTTP_CF_CONNECTING_IP'])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_CF_CONNECTING_IP'];
}
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    $_SERVER['HTTPS'] = 'on';
}
EOL
    fi
fi

# Check for Redis configuration and add if present
if [ ! -z "${REDIS_HOST}" ]; then
    cat >> "${WP_PATH}/wp-config.php" <<EOL

// Redis settings
define('WP_REDIS_HOST', '${REDIS_HOST}');
EOL
fi

if [ ! -z "${REDIS_PORT}" ]; then
    cat >> "${WP_PATH}/wp-config.php" <<EOL
define('WP_REDIS_PORT', '${REDIS_PORT}');
EOL
fi

if [ ! -z "${REDIS_PASSWORD}" ]; then
    cat >> "${WP_PATH}/wp-config.php" <<EOL
define('WP_REDIS_PASSWORD', '${REDIS_PASSWORD}');
EOL
fi

# Optionally, configure a unique cache key salt for each environment
if [ ! -z "${SITE_URL}" ]; then
    cat >> "${WP_PATH}/wp-config.php" <<EOL
define('WP_CACHE_KEY_SALT', '${SITE_URL}');
EOL
fi

# Shuffle the salts
wp config shuffle-salts --path="${WP_PATH}"

# Update site options
wp option update blogname "${SITE_NAME}" --path="${WP_PATH}"
wp option update blogdescription "${SITE_DESCRIPTION}" --path="${WP_PATH}"

# Add Redis object cache plugin activation, if not already active
# Note: This part assumes WP-CLI is available and Redis plugin is installed
if wp plugin is-installed redis-cache --path="${WP_PATH}" && [ ! $(wp plugin is-active redis-cache --path="${WP_PATH}") ]; then
    wp plugin activate redis-cache --path="${WP_PATH}"
    wp redis enable --path="${WP_PATH}"
fi
