GREEN		=	\033[0;32m
RED		=	\033[0;31m
YELLOW		=	\033[0;33m
NC		=	\033[0m


COMPOSE_FILE	=	srcs/docker-compose.yml

DATA_DIR	=	$(HOME)/data

.PHONY: all build up down clean fclean re logs status help

all: build up
	@echo "$(GREEN) Infrastructure ready!!$(NC)"
	@echo "$(GREEN) https://jocalder.42.fr$(NC)"

$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb
	@echo "$(YELLOW) Created: $(DATA_DIR)/mariadb$(NC)"

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress
	@echo "$(YELLOW) Created: $(DATA_DIR)/wordpress$(NC)"

build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@echo "$(YELLOW) Building Docker images...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build

up:
	@echo "$(YELLOW) Starting services..$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d

down:
	@echo "$(RED) Stopping services..$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

status:
	@echo "$(YELLOW) Containers status..$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps

clean: down
	@echo "$(RED) Cleaning containers..$(NC)"
	docker-compose -f $(COMPOSE_FILE) down --rmi all

fclean: clean
	@echo "$(RED) Full cleanup..$(NC)"
	docker-compose -f $(COMPOSE_FILE) down -v --rmi all
	@rm -rf $(DATA_DIR)
	docker system prune -af
	@echo "$(RED) Data removed..$(NC)"

re: fclean all
	@echo "$(GREEN) Full rebuild completed..$(NC)"

help:
	@echo "$(YELLOW) Available commands..$(NC)"
	@echo "make build  -> Build Docker images"
	@echo "make up	   -> Start containers"
	@echo "make down   -> Stop containers"
	@echo "make logs   -> Show logs"
	@echo "make status -> Show container status"
	@echo "make clean  -> Remove containers"
	@echo "make fclean -> Full cleanup"
	@echo "make re     -> Full rebuild"

