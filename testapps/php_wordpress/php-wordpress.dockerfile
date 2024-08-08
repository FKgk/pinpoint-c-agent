FROM  wordpress:beta-php8.1-apache

# COPY config.m4 /pinpoint-c-agent/config.m4 
# COPY pinpoint_php.cpp /pinpoint-c-agent/pinpoint_php.cpp 
# COPY php_pinpoint_php.h /pinpoint-c-agent/php_pinpoint_php.h
# COPY common /pinpoint-c-agent/common
# COPY testapps/php_wordpress/pinpoint_php.ini /pinpoint-c-agent/pinpoint_php.ini

# RUN cd /pinpoint-c-agent/ && phpize && ./configure && make install
# RUN INI_DIR=`php-config --ini-dir` && cp /pinpoint-c-agent/pinpoint_php.ini $INI_DIR

# COPY install_pinpoint_php.sh /tmp/
# RUN sh /tmp/install_pinpoint_php.sh

RUN curl -sL https://github.com/pinpoint-apm/pinpoint-c-agent/releases/latest/download/install_pinpoint_php.sh | sh

COPY testapps/php_wordpress/wp-config.php /usr/src/wordpress/wp-config.php
#  install composer
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
USER www-data
RUN cd /var/www/html/ && composer require -w pinpoint-apm/pinpoint-php-aop:v3.0.1
USER root