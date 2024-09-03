FROM ubuntu:20.04
ENV TZ=Asia/Shanghai
ENV LC_CTYPE=en_US.UTF-8
WORKDIR /workspace
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN DEBIAN_FRONTEND="noninteractive" apt update && apt-get install -y build-essential git php7.4 php7.4-dev php7.4-curl  php7.4-mysql libmemcached-dev zlib1g-dev libssl-dev  pkg-config
COPY testapps/SimplePHP/php.ini /etc/php/7.4/cli/php.ini
COPY testapps/SimplePHP/src /workspace/src
COPY testapps/SimplePHP/composer-real.json /workspace/composer.json
COPY testapps/SimplePHP/run.php /workspace/run.php
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN git clone --recurse-submodules --depth 1 --branch 1.18.1 https://github.com/mongodb/mongo-php-driver.git && cd mongo-php-driver && phpize && ./configure && make -j && make install 
RUN cd /tmp/ && git clone https://github.com/phpredis/phpredis.git && cd phpredis && git checkout 6.0.2 && phpize && ./configure &&  make install
RUN cd /tmp/ && git clone https://github.com/php-memcached-dev/php-memcached.git && cd php-memcached && phpize && ./configure &&  make install
RUN cd /tmp/ && git clone https://github.com/krakjoe/apcu.git && cd apcu && phpize && ./configure &&  make install
COPY config.m4 /pinpoint-c-agent/config.m4 
COPY pinpoint_php.cpp /pinpoint-c-agent/pinpoint_php.cpp 
COPY php_pinpoint_php.h /pinpoint-c-agent/php_pinpoint_php.h
COPY common /pinpoint-c-agent/common
COPY tests /pinpoint-c-agent/tests

RUN cd /pinpoint-c-agent/ && phpize && ./configure && make && make install

RUN COMPOSER_ALLOW_SUPERUSER=1 composer require pinpoint-apm/pinpoint-php-aop:^3.0.2

CMD [ "php" ,"/workspace/run.php" ]
