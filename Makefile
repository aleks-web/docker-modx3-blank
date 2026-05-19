#!/usr/bin/make
# Makefile readme (ru): <http://linux.yaroslavl.ru/docs/prog/gnu_make_3-79_russian_manual.html>
# Makefile readme (en): <https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents>

ENVFILE = .env
ENVFILE_EXAMPLE = .env-example
MODX_BD_EXPORT_FILENAME = modx_export_$(shell date +%Y%m%d_%H%M%S)_$(shell shuf -i 1000-9999 -n 1).sql

# Create the .env file if not exit.
ifeq ("$(wildcard $(ENVFILE))","")
   $(shell cp $(ENVFILE_EXAMPLE) $(ENVFILE))
endif

# Load the environment variables from .env file
include $(ENVFILE)
export $(shell sed '/^\#/d; s/=.*//' $(ENVFILE))

help: ## Помощь по Makefile
	@printf "\033[33m%s:\033[0m\n" 'Commands'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "  \033[32m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

show-env: ## Отображение переменных .env файла
	@printf "\033[33m%s:\033[0m\n" "Variables from $(ENVFILE) file"
	@cat $(ENVFILE) | grep -v '^#' | grep -v '^$$'

build: ## Собрать образы
	docker compose build

build-no-cache: ## Собрать образы без кеша
	docker compose build --no-cache

up: ## Поднять контейнеры docker
ifeq ($(NODE_ENV), dev)
	docker compose up -d && make -s dev-dns-up
endif

ifeq ($(NODE_ENV), production)
	docker compose up -d
endif

down: ## Выключить контейнеры docker
ifeq ($(NODE_ENV), dev)
	docker compose down && make -s dev-dns-down
endif

ifeq ($(NODE_ENV), production)
	docker compose down
endif

s:
	make -s down && make -s build && make -s up && make -s modx-sh

restart: ## Перезапустить контейнеры docker
	make -s down && make -s up

d-clean:
	docker system prune -a --volumes

tw-watch: ## Включить tailwind слежку (для разработки)
	npx @tailwindcss/cli -i ./modx/resources/assets/tw/input.css -o ./modx/resources/assets/tw/output.css --watch

# Команды для работы с modx
modx-new-install: ## Новая установка modx в интерактивном режиме (дропает текущую базу данных)
	sh ./scripts/modx/new-install.sh

submodule-update: ## Обновить submodule
	git submodule update

modx-cache-clean: ## Очистка кеша MODX
	docker exec -i site chmod -R 777 ./core/cache && rm -rf ./core/cache/*

modx-db-drop: ## Удаление базы данных modx
	docker exec -i db_modx mysql -u root -e "DROP DATABASE IF EXISTS $(DB_NAME);"

modx-db-create: ## Создание базы данных modx
	docker exec -i db_modx mysql -u root -e "CREATE DATABASE $(DB_NAME);"

modx-db-recreate: ## Пересоздание базы данных modx
	make -s db-drop && make -s db-create

modx-sh: ## Консоль сайта (/var/www/modx)
	docker exec -it site sh

modx-db-export: ## Экспорт базы данных modx
	docker exec -i db_modx mysqldump -u root ${DB_NAME} > ${MODX_BD_EXPORT_FILENAME}

modx-db-import: ## Импорт базы данных modx
	docker cp ./modx_import.sql db_modx:/modx_import.sql
	docker exec -i db_modx mysql -u modx ${DB_NAME} < modx_import.sql
	docker exec -i db_modx rm -f ./modx_import.sql

modx-session-clear: ## Очистка таблицы сессий modx
	docker exec -i db_modx mysql -u root -e "TRUNCATE TABLE ${DB_NAME}.modx_session"

# Команды для работы с базой данных
db-sh: ## Консоль хоста, где находится база данных
	docker exec -it db_modx sh

db-mysql-sh: ## Консоль базы данных
	docker exec -it db_modx mysql -u modx ${DB_NAME}

# Команды для работы в dev режиме
dev-git: ## Быстро закоммитить и запушить в ветку master (для разработки при старте, когда названия коммитов не так важны)
	git add . && git commit -m "Makefile commit" && git push origin master

## Добавление сопоставления localhost с доменом в hosts файле
## Необходимо для разработки, чтобы в браузере было не localhost, а необходимый домен
## Домены можно сменить в файле ./scripts/dns_change/add.go
dev-dns-up: ## Добавление сопоставления localhost с доменом в hosts файле
	go run ./scripts/dns_change/add.go

dev-dns-down: ## Удаление сопоставления localhost с доменом в hosts файле
	go run ./scripts/dns_change/remove.go