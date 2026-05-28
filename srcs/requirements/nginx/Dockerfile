FROM	debian:12-slim

ENV	DEBIAN_FRONTEND=noninteractive

RUN	apt-get update && apt-get install -y --no-install-recommends \
	nginx \
	openssl \
	&& rm -rf /var/lib/apt/lists/*

RUN	mkdir -p \
	/etc/nginx/ssl \
	/var/www/html \
	/run/nginx

RUN	openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=42/CN=jocalder.42.fr"

COPY	tools/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE	443

ENTRYPOINT	["nginx", "-g", "daemon off;"]
