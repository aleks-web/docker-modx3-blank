#!/bin/sh

chown -R www-data:www-data /var/www/modx
chmod -R 777 /var/www/modx
chmod -R 644 /var/www/modx/core/config/config.inc.php

php-fpm -R