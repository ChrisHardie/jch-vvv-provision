#!/usr/bin/env bash

# Add the site name to the hosts file
echo "127.0.0.1 ${VVV_SITE_NAME}.test # vvv-auto" >> "/etc/hosts"

# Make a database, if we don't already have one
echo -e "\nCreating database '${VVV_SITE_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${VVV_SITE_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${VVV_SITE_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log

# Install and configure the latest stable version of WordPress
mkdir -p ${VVV_PATH_TO_SITE}/public_html
cd ${VVV_PATH_TO_SITE}/public_html
if ! $(wp core is-installed --path="${VVV_PATH_TO_SITE}/public_html" --allow-root); then
  wp core download --path="${VVV_PATH_TO_SITE}/public_html" --allow-root
  wp core config --dbname="${VVV_SITE_NAME}" --dbuser=wp --dbpass=wp --quiet --allow-root
  wp core install --url="${VVV_SITE_NAME}.test" --quiet --title="${VVV_SITE_NAME}" --admin_name=admin --admin_email="admin@${VVV_SITE_NAME}.test" --admin_password="password" --allow-root
  wp site empty --uploads --yes --allow-root
  wp plugin delete hello --allow-root
  wp plugin delete hello-dolly --allow-root
  wp config set WP_DEBUG true --raw --add --allow-root
  wp config set SCRIPT_DEBUG true --raw --add --allow-root
  wp config set WP_DEBUG_LOG true --raw --add --allow-root
  wp config set WP_DEBUG_DISPLAY false --raw --add --allow-root
  wp config set SAVEQUERIES true --raw --add --allow-root
  wp config set FORCE_SSL_ADMIN true --raw --add --allow-root
  wp config set JETPACK_DEV_DEBUG true --raw --add --allow-root
  wp plugin install jetpack --activate --allow-root
  wp plugin install query-monitor --activate --allow-root
  wp plugin install debug-bar --allow-root
  wp plugin install wordpress-importer --activate --allow-root
  wp plugin install post-meta-inspector --activate --allow-root
else
  wp core update --allow-root
  wp core update-db --allow-root
fi
