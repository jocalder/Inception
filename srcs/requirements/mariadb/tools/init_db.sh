#!/bin/sh

set -e

DB_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB..."
	mariadb-install-db \
		--user=mysql \
		--datadir=/var/lib/mysql

	echo "Starting temporary MariaDB..."
	mariadb \
		--user=mysql \
		--skip-networking \
		--socket=/run/mysqld/mysqld.sock &

	until mariadb-admin ping --silent
	do
		sleep 2
	done

	echo "Creating database and users..."
	mariadb << EOF

ALTER USER 'root'@'localhost'
IDENTIFIED BY '${DB_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.*
TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;

EOF
	echo "Stop temporary MariaDB..."
	mariadb-admin -u root \
	-p"${DB_ROOT_PASSWORD}" shutdown
	echo "Database Initialized!!!"
else
	echo "Database already exists"
fi

echo "Starting MariaDB!!!"
exec mariadb --user=mysql --console
