#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin-password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

echo "Waiting for MariaDB..."

until mysqladmin ping \
	-h"$WP_DB_HOST" \
	-u"$WP_DB_USER" \
	-p"$DB_PASSWORD" \
	--silent
do
	sleep 2
done

echo "MariaDB ready..."

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Downloading WordPress..."
	wp core download \
		--path=/var/www/html \
		--allow-root

	echo "Creating wp-config.php..."
	wp config create \
		--dbname="$WP_DB_NAME" \
		--dbuser="$WP_DB_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="$WP_DB_HOST" \
		--path=/var/www/html \
		--allow-root

	echo "Installing WordPress..."
	wp core install \
		--url="https://$DOMAIN_NAME" \
		--title="Inception" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASS" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--path=/var/www/html \
		--allow-root

	echo "Creating second user..."
	wp user create \
		"$WP_USER" "$WP_USER_EMAIL" \
		--role=author \
		--user_pass="$WP_USER_PASS" \
		--allow-root \
		--path=/var/www/html

	echo "Setting permissions..."
	chown -R www-data:www-data /var/www/html
	find /var/www/html -type d -exec chmod 755 {} \;
	find /var/www/html -type f -exec chmod 644 {} \;

	echo "WordPress installed!!"
else
	echo "WordPress already configured"

fi
echo "Starting PHP-FPM!!"
exec /usr/sbin/php-fpm8.2 -F
