FROM node:24-alpine AS node
FROM php:8.5-fpm-alpine

RUN apk update && apk upgrade
RUN apk add --no-cache libjpeg-turbo-dev libwebp-dev libpng-dev
RUN apk add --no-cache openssh-server
RUN apk add --no-cache unzip libzip-dev
RUN apk add --no-cache nano git
RUN apk add --no-cache curl
RUN apk add --no-cache gmp gmp-dev
RUN apk add --no-cache freetype-dev
RUN apk add --no-cache shadow

RUN docker-php-ext-install ftp
RUN docker-php-ext-install zip
RUN docker-php-ext-install gmp
RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql
RUN docker-php-ext-install gd
RUN apk add --no-cache pcre-dev $PHPIZE_DEPS

# configure gd
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/share/man/man1/node.1 /usr/local/share/man/man1/node.1
COPY --from=node /usr/local/share/doc/node /usr/local/share/doc/node
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/ /opt/
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
RUN ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

ENV PATH="$PATH:/var/www/modx/core/vendor/bin"

WORKDIR /var/www/modx
RUN chmod -R 644 /var/www/modx

CMD ["php-fpm", "-R"]