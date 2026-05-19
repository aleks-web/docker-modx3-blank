source ./.env
make -s modx-get
make -s modx-cache-clean
make -s up

sql_cast_name='modx_cast.sql'

# Копируем файл-конфиг для установки modx в интерактивном режиме
docker exec -i site sh -c "git config --global --add safe.directory /var/www/modx"
docker exec -i site sh -c "composer install"
docker exec site sh -c "composer require symfony/var-dumper"
docker exec site sh -c "composer require finetuned/modx-cli"

# Дропаем бд
docker exec -i db_modx mysql -u root -e "DROP DATABASE IF EXISTS ${DB_NAME};CREATE DATABASE ${DB_NAME};"

# File permissions
docker exec db_modx sh -c "chmod -R 644 /etc/mysql/my.cnf"
docker exec site sh -c  "chmod -R 777 ./"

# Import database
docker cp ./scripts/modx/cast/cast/$sql_cast_name db_modx:$sql_cast_name
docker exec db_modx sh -c "mysql -u root ${DB_NAME} < $sql_cast_name"
docker exec -i db_modx rm -f $sql_cast_name

cp -r -a -v ./scripts/modx/cast/cast/packages/ ./site/modx/core/
cp -r -a -v ./scripts/modx/cast/cast/components ./site/modx/core/
cp -r -a -v ./scripts/modx/cast/cast/uploads ./site/modx/
cp -r -a -v ./scripts/modx/cast/cast/resources ./site/modx/

#docker cp ./scripts/modx/cast/cast/packages site:/var/www/modx/core/packages
#docker cp ./scripts/modx/cast/cast/components site:/var/www/modx/core/components
#docker cp ./scripts/modx/cast/cast/uploads site:/var/www/modx/uploads
#docker cp ./scripts/modx/cast/cast/resources site:/var/www/modx/resources

# docker exec site sh -c "composer run-script post-create-project-cmd"
# docker exec site sh -c "cd ./_build && rm -f build.config.php && rm -f build.properties.php"

# Modx update from configure.php
docker cp ./scripts/modx/configure.php site:/var/www/modx/configure.php
docker exec site sh -c "php configure.php && rm -rf ./core/cache/* && rm -f configure.php"