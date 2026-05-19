source ./.env
make -s modx-update
make -s modx-cache-clean
make -s up

# Копируем файл-конфиг для установки modx в интерактивном режиме
docker exec -i site sh -c "git config --global --add safe.directory /var/www/modx"
docker exec site sh -c "rm -r composer.lock && rm -r config.core.php && rm -r ./core/vendor"
docker exec -i site sh -c "composer install"
docker exec site sh -c "composer require symfony/var-dumper"
docker exec site sh -c "composer require finetuned/modx-cli"
docker cp ./docker/php-fpm8.5/.bashrc site:/root/.bashrc

# Устанавливаем modx интерактивно
docker exec -i db_modx mysql -u root -e "DROP DATABASE IF EXISTS ${DB_NAME};CREATE DATABASE ${DB_NAME};"
docker exec site sh -c "composer run-script post-create-project-cmd"
docker cp ./scripts/modx/config.new.xml site:/var/www/modx/setup/config.xml # Копируем файл-конфиг для установки modx в интерактивном режиме
docker exec site sh -c "cd setup && php ./index.php --installmode=new && rm -f config.xml"
docker exec site sh -c "cd ./_build && rm -f build.config.php && rm -f build.properties.php"

# File permissions
docker exec site sh -c "chmod -R 777 ./ && chmod -R 644 ./core/config/config.inc.php && chmod -R 755 ./core/cache"
docker exec db_modx sh -c "chmod -R 644 /etc/mysql/my.cnf"

# Modx update from configure.php
docker cp ./scripts/modx/configure.php site:/var/www/modx/configure.php
docker exec site sh -c "php configure.php && rm -rf ./core/cache/* && rm -f configure.php"

docker cp ./scripts/modx/auth.php site:/var/www/modx/auth.php
start http://ultradent72.ru/auth.php