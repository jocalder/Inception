#!/bin/sh

set -e

DB_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "Initializing MariaDB..."
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	echo "Starting temporary MariaDB..."
	mysqld --user=mysql \
		--skip-networking \
		--socket=/run/mysqld/mysqld.sock &
	PID="$!"

	for i in $(seq 1 30); do
		mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent && break
		sleep 1
	done
	mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent || {
		echo "Error: MariaDB failed to satrt"
		exit 1
	}

	echo "Creating database and users..."
	mariadb --socket=/run/mysqld/mysqld.sock << EOF

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
	mariadb-admin -u root -p"${DB_ROOT_PASSWORD}" shutdown || true
	wait "$PID" 2>/dev/null || true
	echo "Database Initialized!!!"
else
	echo "Database already exists"
fi

echo "Starting MariaDB!!!"
exec mysqld --user=mysql
