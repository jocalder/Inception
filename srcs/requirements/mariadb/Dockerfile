
FROM	debian:12-slim

RUN	apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

RUN	mkdir -p /run/mysqld /var/lib/mysql && \
	chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
	chmod 755 /run/mysqld

COPY	tools/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY	tools/init_db.sh /usr/local/bin/

RUN	chmod +x /usr/local/bin/init_db.sh

EXPOSE	3306

ENTRYPOINT	["/usr/local/bin/init_db.sh"]
