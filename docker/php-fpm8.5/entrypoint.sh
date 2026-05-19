#!/bin/sh

chown -R www-data:www-data /var/www/modx
chmod -R 777 /var/www/modx
chmod -R 644 ./core/config/config.inc.php

. /root/.bashrc

php-fpm -R