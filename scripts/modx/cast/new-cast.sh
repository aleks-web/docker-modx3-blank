source ./.env
make -s modx-cache-clean

sql_cast_name='modx_cast.sql'

# Database drop and update
docker exec -i db_modx mysql -u root -e "DROP DATABASE IF EXISTS ${DB_NAME};CREATE DATABASE ${DB_NAME};"
docker cp ./scripts/modx/cast/cast/$sql_cast_name db_modx:$sql_cast_name
docker exec db_modx sh -c "mysql -u root ${DB_NAME} < $sql_cast_name"
docker exec -i db_modx rm -f $sql_cast_name

cp -r -a -v ./scripts/modx/cast/cast/packages/ ./site/
cp -r -a -v ./scripts/modx/cast/cast/components ./site/
cp -r -a -v ./scripts/modx/cast/cast/assets ./site/
cp -r -a -v ./scripts/modx/cast/cast/uploads ./site/
cp -r -a -v ./scripts/modx/cast/cast/resources ./site/

# Modx update from configure.php
docker cp ./scripts/modx/configure.php site:/var/www/modx/configure_cast.php
docker exec site sh -c "php /var/www/modx/configure.php && rm -rf ./core/cache/* && rm -f /var/www/modx/configure_cast.php"

make -s restart