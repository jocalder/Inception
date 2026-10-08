*This project has been created as part of the 42 curriculum by jocalder.*

# Inception

## Description

**Inception** is a system administration and Docker project from the 42 curriculum. The main goal of the project is to build a small infrastructure composed of several Docker containers, each running a specific service, and to make them communicate securely with each other.

The project is designed around the principles of **containerization**, **service isolation**, **networking**, **persistent storage**, and **secure configuration**.

The infrastructure is composed of three main services:

* **NGINX** — acts as the entry point to the infrastructure and provides HTTPS access.
* **WordPress** — provides the web application and PHP execution environment.
* **MariaDB** — provides the database used by WordPress.

Each service runs in its own Docker container and is built from its own Dockerfile. The containers communicate through a dedicated Docker network, while persistent data is stored using Docker volumes.

The project also demonstrates how several independent services can be combined to create a complete web infrastructure while keeping each component isolated and independently configurable.

### Project Architecture

The basic architecture can be represented as follows:

```text
                         HTTPS
                          │
                          ▼
                 ┌─────────────────┐
                 │      NGINX      │
                 │   Port 443      │
                 │  TLS / HTTPS    │
                 └────────┬────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │    WordPress    │
                 │   PHP-FPM      │
                 └────────┬────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │     MariaDB     │
                 │    Database     │
                 └─────────────────┘

                  Docker Network
```

### Docker

Docker is used to package and run each service in an isolated container. Instead of installing NGINX, WordPress/PHP and MariaDB directly on the host operating system, each component is installed and configured inside its own container.

The Docker images are built from Dockerfiles rather than relying on pre-built application images. This makes it possible to understand and control the environment in which every service runs.

Docker Compose is used to define and start the complete infrastructure from a single configuration.

The main design choices are:

* One container per service.
* Separate Dockerfiles for each service.
* A dedicated Docker network for communication between containers.
* Docker volumes for persistent application and database data.
* HTTPS communication through NGINX.
* Configuration and sensitive values separated from the application code.
* Automatic service startup through the container configuration.
* Restart policies to improve service availability.

### Sources included in the project

The project contains the configuration and source files required to build the infrastructure, including:

```text
├── Makefile
├── README.md
├── secrets
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs
    ├── .env
    ├── docker-compose.yml
    └── requirements
        ├── mariadb
        │   ├── Dockerfile
        │   └── tools
        │       ├── 50-server.cnf
        │       └── init_db.sh
        ├── nginx
        │   ├── Dockerfile
        │   └── tools
        │       └── nginx.conf
        └── wordpress
            ├── Dockerfile
            └── tools
                ├── setup_wordpress.sh
                └── www.conf
```

Every service has its own configuration and build instructions.

---

# Instructions

## Requirements

The project requires:

* A virtual machine
* Sufficient disk space for Docker images, containers and volumes
* Docker
* Docker Compose
* Git

The project was designed to run on a Linux environment.

## Configuration

Before starting the project, configure the environment variables required by the infrastructure.

Sensitive configuration such as passwords should not be hard-coded directly into Dockerfiles or application configuration files.

For example:

```text
DOMAIN_NAME=login.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=********
MYSQL_ROOT_PASSWORD=********
```

The actual values should be adapted to the local environment.

## Building and starting the infrastructure

Clone the repository:

```bash
git clone https://github.com/jocalder/Inception.git
cd inception
```

Build the Docker images:

```bash
make
```

Depending on the Makefile implementation, this will normally execute Docker Compose and build the required images.

The infrastructure can also be started directly with:

```bash
docker compose -f srcs/docker-compose.yml up --build
```

If the system uses the legacy Docker Compose command:

```bash
docker-compose -f srcs/docker-compose.yml up --build
```

## Stopping the infrastructure

To stop the running containers:

```bash
make down
```

or:

```bash
docker compose -f srcs/docker-compose.yml down
```

## Checking running containers

To see the containers currently running:

```bash
docker ps
```

To see all containers, including stopped containers:

```bash
docker ps -a
```

## Checking Docker networks

```bash
docker network ls
```

The project should create a dedicated network used by the services.

## Checking Docker volumes

```bash
docker volume ls
```

Volumes are used to keep persistent data even when containers are stopped or recreated.

## Accessing the website

Once the infrastructure is running, the WordPress website can be accessed through the configured domain:

```text
https://jocalder.42.fr
```

The domain must resolve to the machine running the Docker infrastructure.

For a local environment, the `/etc/hosts` file can be configured accordingly:

```text
127.0.0.1 jocalder.42.fr
```

The exact domain depends on the login and configuration used for the project.

---

# Services

## NGINX

NGINX is the entry point of the infrastructure.

Its main responsibilities are:

* Accept HTTPS connections.
* Provide TLS encryption.
* Serve as a reverse proxy.
* Forward requests to WordPress/PHP-FPM.
* Prevent direct access to internal services from outside the Docker network.

NGINX listens on port `443`.

Only the necessary public port is exposed to the host.

## WordPress

WordPress provides the web application.

The WordPress container contains the necessary PHP environment and PHP-FPM process required to execute WordPress.

WordPress communicates with MariaDB through the Docker network.

The WordPress container does not need to expose its PHP-FPM port directly to the host.

## MariaDB

MariaDB provides the relational database used by WordPress.

It stores WordPress data such as:

* Users
* Posts
* Pages
* Settings
* Metadata
* Other application data

The database is kept in a Docker volume so that the data remains persistent when the MariaDB container is recreated.

---

# Technical Choices

## Virtual Machines vs Docker

A **Virtual Machine** virtualizes an entire computer system. It normally contains its own operating system, kernel, libraries and applications.

Docker containers instead share the host operating system's kernel while isolating applications and their dependencies.

### Virtual Machines

Advantages:

* Stronger isolation at the operating-system level.
* Each virtual machine can run a completely different operating system.
* Useful when a complete independent operating system is required.

Disadvantages:

* Usually requires more memory and storage.
* Requires a complete guest operating system.
* Startup is generally slower.
* More resources are needed for several independent services.

### Docker

Advantages:

* Lightweight compared with full virtual machines.
* Containers start quickly.
* Services can be isolated independently.
* Images can be reproduced consistently.
* Networking and persistent storage can be configured explicitly.
* Multiple services can run on the same host without requiring several complete operating systems.

Disadvantages:

* Containers share the host kernel.
* Isolation is different from full hardware virtualization.
* Docker introduces its own networking, storage and image-management concepts that must be understood.

For this project, Docker is appropriate because the objective is to create an infrastructure composed of several isolated services while keeping the resource requirements relatively small.

---

# Secrets vs Environment Variables

Both mechanisms can be used to provide configuration values to containers, but they serve different purposes.

## Environment Variables

Environment variables are convenient for configuration such as:

```text
DOMAIN_NAME
MYSQL_DATABASE
MYSQL_USER
```

They can also contain passwords, although sensitive credentials should preferably use a dedicated secrets mechanism when available.

Environment variables are simple and widely supported, but their values can potentially become visible through container configuration or process environments depending on how they are used.

## Secrets

Docker secrets are designed specifically for sensitive information such as:

* Database passwords
* API keys
* Private credentials
* Certificates or private keys

Secrets can be provided to containers without putting sensitive values directly into the image.

For sensitive production environments, a secrets mechanism is generally preferable to storing credentials directly in environment variables.

In this project, configuration values and credentials are separated from the Dockerfiles so that sensitive information is not embedded in the images.

---

# Docker Network vs Host Network

## Docker Network

A Docker network provides an isolated network between containers.

Containers can communicate with each other using their service names.

For example:

```text
nginx → wordpress → mariadb
```

The database does not need to be exposed directly to the host.

Advantages:

* Service isolation.
* Internal DNS resolution.
* Controlled communication between containers.
* Reduced exposure of internal services.

## Host Network

With host networking, a container uses the host's network stack directly.

This can provide simpler networking in some situations, but it reduces network isolation and can create port conflicts with services running on the host.

For Inception, a dedicated Docker network is used because the services need to communicate internally while only the required public service should be exposed externally.

---

# Docker Volumes vs Bind Mounts

## Docker Volumes

Docker volumes are managed by Docker and are designed for persistent container data.

They are particularly useful for databases and application data.

For example:

```text
MariaDB
   │
   ▼
Docker Volume
   │
   ▼
Persistent database data
```

Advantages:

* Managed by Docker.
* Independent from the container lifecycle.
* Suitable for persistent application data.
* Easier to move and manage within Docker infrastructure.

## Bind Mounts

A bind mount maps a specific directory or file from the host filesystem into a container.

Example:

```text
Host directory
      │
      ▼
Container directory
```

Advantages:

* Direct access to files from the host.
* Useful during development.
* Easy to inspect and modify files externally.

Disadvantages:

* More dependent on the host filesystem structure.
* Permissions can become more complicated.
* Less portable than Docker-managed volumes.

For this project, Docker volumes are used for persistent WordPress and MariaDB data because the data needs to survive container recreation.

---

# Persistence

Containers themselves are considered ephemeral. Removing a container should not result in the loss of important application data.

Docker volumes provide persistence for the project.

The main persistent data includes:

* WordPress files.
* MariaDB database files.

This allows containers to be rebuilt or recreated without losing the application data stored in the volumes.

---

# Security

Several security principles are applied in the infrastructure:

* HTTPS is used instead of plain HTTP for external access.
* Internal services are not unnecessarily exposed to the host.
* MariaDB communicates through the internal Docker network.
* Sensitive credentials are kept outside Dockerfiles.
* Each service runs in its own container.
* Only required ports are exposed.
* Persistent data is stored separately from container lifecycles.

TLS certificates are configured in NGINX so that external communication with the WordPress website is encrypted.

---

# Useful Docker Commands

List images:

```bash
docker images
```

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

Display container logs:

```bash
docker logs <container_name>
```

Enter a running container:

```bash
docker exec -it <container_name> /bin/bash
```

List networks:

```bash
docker network ls
```

Inspect a network:

```bash
docker network inspect <network_name>
```

List volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect <volume_name>
```

Stop all Compose services:

```bash
docker compose down
```

Rebuild the services:

```bash
docker compose build
```

Start the services:

```bash
docker compose up
```

---

# Resources

## Docker Documentation

The official Docker documentation is the main reference used to understand Docker concepts and commands:

* Docker Documentation: https://docs.docker.com/
* Docker Compose Documentation: https://docs.docker.com/compose/
* Dockerfile reference: https://docs.docker.com/reference/dockerfile/
* Docker networking: https://docs.docker.com/engine/network/
* Docker volumes: https://docs.docker.com/engine/storage/volumes/
* Docker secrets: https://docs.docker.com/engine/swarm/secrets/

## NGINX

Official NGINX documentation:

https://nginx.org/en/docs/

NGINX documentation was useful for understanding:

* Server blocks.
* HTTPS configuration.
* TLS certificates.
* Reverse proxy configuration.
* Connection handling.

## WordPress

Official WordPress documentation:

https://wordpress.org/documentation/

WordPress documentation was used to understand the installation, configuration and administration of WordPress.

## MariaDB

Official MariaDB documentation:

https://mariadb.com/docs/

The MariaDB documentation provides information about database configuration, users, authentication and server administration.

## Linux

Linux manual pages and documentation:

https://man7.org/linux/man-pages/

These resources are useful for understanding Linux commands, permissions, processes, networking and system administration.

## Docker Networking and Containers

Additional educational resources can be found through:

* Docker official documentation.
* Docker's official guides.
* Linux networking documentation.
* NGINX documentation.
* MariaDB documentation.
* WordPress documentation.

These resources provide information about containerization, networking, persistent storage, web servers and database administration.

---

# AI Usage

AI-assisted tools were used as a supplementary learning and troubleshooting resource during the project.

They were used to:

* Clarify Docker and Docker Compose concepts.
* Explain Linux and networking commands.
* Help understand configuration errors and Docker behaviour.
* Review possible approaches to configuring the infrastructure.
* Explain documentation and technical concepts when necessary.

The project's configuration, implementation and testing were carried out as part of the learning process, with official documentation and technical references used to verify the relevant concepts.

---

# Conclusion

Inception demonstrates how to build a small multi-service infrastructure using Docker.

The project combines:

* Docker containers
* Docker Compose
* NGINX
* WordPress
* PHP-FPM
* MariaDB
* HTTPS/TLS
* Docker networks
* Docker volumes
* Linux system administration

The main objective is not simply to run WordPress, but to understand how independent services can be isolated, connected, configured and maintained as part of a reproducible infrastructure.
