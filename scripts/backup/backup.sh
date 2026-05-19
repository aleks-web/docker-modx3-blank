BACKUP_FOLDER_NAME = $(shell date +%F)

docker exec -i db_modx sh -c "mysqldump -u root ${DB_NAME} > modx_db_backup.sql"
mkdir "./site/backup/backup_$(BACKUP_FOLDER_NAME)_"
docker cp db_modx:modx_db_backup.sql ./site/backup/modx_db_backup.sql
