# WordPress Setup Script with Cloudflare Detection and Redis Configuration

This script automates the setup of WordPress, including the configuration for Cloudflare and Redis. It ensures WordPress is optimized for performance and security by leveraging Cloudflare's protection and Redis for object caching.

## Prerequisites

- A Linux server with Docker and Docker Compose installed.
- Access to the command line of the server.
- A WordPress Docker container setup.
- WP-CLI installed within the container for WordPress management.
- Redis server accessible to the WordPress container.
- (Optional) Cloudflare set up for your domain.

## Environment Variables

To fully utilize the script, set the following required and optional environment variables before running it:

### Required Variables

- `SITE_URL`: The URL of your WordPress site.
- `WORDPRESS_DB_NAME`: The name of your WordPress database.
- `WORDPRESS_DB_USER`: The username for your WordPress database access.
- `WORDPRESS_DB_PASSWORD`: The password for your WordPress database access.
- `WORDPRESS_DB_HOST`: The hostname or IP address of your WordPress database server.

### Optional Variables

- `REDIS_HOST`: Hostname of the Redis server (for object caching).
- `REDIS_PORT`: Port on which the Redis server is running.
- `REDIS_PASSWORD`: Password for the Redis server.
- `WORDPRESS_TABLE_PREFIX`: The database table prefix for WordPress installations. Defaults to `wp_` if not set.
- `WORDPRESS_MEMORY_LIMIT`: The maximum amount of memory that your site can use. Defaults to `256M` if not set.
- `SITE_NAME`: Your site's name. This is used to update the site options.
- `SITE_DESCRIPTION`: A brief description of your site.
- `WORDPRESS_DEBUG`: Enables or disables the WP_DEBUG mode. Defaults to `false`.
- `WORDPRESS_DEBUG_DISPLAY`: Controls the display of errors and warnings. Defaults to `false`.
- `WORDPRESS_DEBUG_LOG`: Enables or disables error logging to `wp-content/debug.log`. Defaults to `true`.
- `WORDPRESS_AUTO_UPDATE_CORE`: Enables automatic updates for the WordPress core. Defaults to `true`.
- `AUTOMATIC_UPDATER_DISABLED`: Disables all automatic updates. Defaults to `false`.
- `WP_ALLOW_MULTISITE`: Enables WordPress Multisite. Defaults to `true`.
- `WORDPRESS_POST_REVISIONS`: Specifies the number of post revisions to keep. Defaults to `5`.
- `DISALLOW_FILE_EDIT`: Disables the file edit feature in the WordPress dashboard. Defaults to `false`.

## Installation

1. Clone this repository to your server:
    ```bash
    git clone https://your-repository-url.git
    ```
2. Navigate to the repository directory:
    ```bash
    cd your-repository-directory
    ```
3. Make the script executable:
    ```bash
    chmod +x setup-wordpress.sh
    ```

## Usage

Before running the script, ensure all required environment variables are set. You can export them directly in your shell or define them in a `.env` file if you're using Docker Compose.

To run the script:
```bash
./setup-wordpress.sh

The script will:

    Check for necessary prerequisites and environment variables.
    Install and configure necessary utilities.
    Detect if Cloudflare is protecting the site and apply configurations if necessary.
    Configure Redis for object caching if Redis details are provided.
    Shuffle security salts and update site options using WP-CLI.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any bugs or improvements.

## License

MIT License - Feel free to use and modify the script as needed for your own WordPress setups.
