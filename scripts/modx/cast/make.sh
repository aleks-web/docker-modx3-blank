make -s up

mysqldump_name="modx_cast.sql"
folder_name="date_"$(date +%d-%m-%Y)"-time_"$(date +%H_%M_%S)
path="./scripts/modx/cast/cast/"
mysqldump_save_path=$path$mysqldump_name
package_path=$path"packages/"
assets_path=$path"assets/"
components_path=$path"components/"
resources_path=$path"resources/"
uploads_path=$path"uploads/"

mkdir -p $path

docker exec db_modx sh -c "mysqldump -u root ${DB_NAME} > $mysqldump_name"
docker cp db_modx:$mysqldump_name $mysqldump_save_path
docker exec db_modx sh -c "rm -rf $mysqldump_name"

docker cp site:/var/www/modx/core/packages $package_path
docker cp site:/var/www/modx/assets $assets_path
docker cp site:/var/www/modx/core/components $components_path
docker cp site:/var/www/modx/resources $resources_path
docker cp site:/var/www/modx/uploads $uploads_path
rm -rf $package_path.gitignore

# find $path -name '*core*' -exec rm -rf {} +