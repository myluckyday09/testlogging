FROM    alpine:3.9

RUN     adduser -D -u 1000 -g 1000 -s /bin/sh www-data && \
                mkdir -p /apps

ADD     https://repos.php.earth/alpine/phpearth.rsa.pub /etc/apk/keys/phpearth.rsa.pub
RUN     echo "https://repos.php.earth/alpine/v3.9" >> /etc/apk/repositories && \
                apk add --no-cache php7.3

RUN     apk add --no-cache --update tini

COPY    --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/bin/supervisord

COPY	./docker/referral_leaderboard.sh /tmp/referral_leaderboard.sh
COPY    ./docker/supervisord.conf /supervisord.conf
COPY    ./docker/php-fpm-www.conf /etc/php/7.3/php-fpm.d/www.conf
COPY    ./docker/php.ini /etc/php/7.3/php.ini
COPY    ./docker/php.ini-development /etc/php/7.3/php.ini-development
COPY    ./docker/php.ini-production /etc/php/7.3/php.ini-production
COPY    ./docker/nginx.conf /nginx.conf
COPY    ./docker/docker-entrypoint.sh /docker-entrypoint.sh

RUN     apk add --no-cache --update \
                gettext \
                nginx nginx-mod-http-lua bash && \
                mkdir -p /var/cache/nginx && \
                chown -R www-data:www-data /var/cache/nginx && \
                chown -R www-data:www-data /var/lib/nginx && \
                chown -R www-data:www-data /var/tmp/nginx && \
                chown -R www-data:www-data /apps && \
                chmod 775 -R /apps

RUN     apk add --no-cache --update php7.3 php7.3-apcu php7.3-bcmath php7.3-bz2 php7.3-cgi php7.3-ctype php7.3-curl php7.3-dom php7.3-fpm php7.3-ftp php7.3-gd php7.3-iconv php7.3-json php7.3-mbstring php7.3-opcache php7.3-openssl php7.3-pcntl php7.3-pdo php7.3-pdo_mysql php7.3-mysqli php7.3-phar php7.3-mysqli php7.3-pdo_pgsql php7.3-pgsql php7.3-redis php7.3-session php7.3-simplexml php7.3-tokenizer php7.3-xdebug php7.3-xml php7.3-xmlwriter php7.3-zip php7.3-zlib php7.3-pdo_pgsql php7.3-pgsql php7.3-fileinfo nodejs

ENV     SERVER_NAME="localhost"
ENV     SERVER_ALIAS=""
ENV     SERVER_ROOT=/apps/public

COPY    . /apps/
RUN     if [ -d /apps/node_modules ]; then rm -rf /apps/node_modules; fi

EXPOSE  80
WORKDIR /apps
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

