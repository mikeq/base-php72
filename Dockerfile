FROM orsolin/docker-php-5.3-apache
RUN apt-get update && apt-get install -y --no-install-recommends \
mysql-client \
git \
vim \
zip \
less \
ruby1.9.1-dev \
&& apt-get -y autoremove \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
&& curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
# Make sure we're installing what we think we're installing!
&& php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
&& php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --snapshot \
&& rm -f /tmp/composer-setup.*

RUN gem install mailcatcher

RUN echo "date.timezone = Europe/London" >> $PHP_INI_DIR/php.ini \
&& echo "include_path = .:/scope/includes" >> $PHP_INI_DIR/php.ini \
&& echo "error_reporting = 30711" >> $PHP_INI_DIR/php.ini \
&& echo "log_errors = On" >> $PHP_INI_DIR/php.ini \
&& echo "memory_limit = 512M" >> $PHP_INI_DIR/php.ini \
&& echo "register_globals = On" >> $PHP_INI_DIR/php.ini \
&& echo "serialize_precision = 100" >> $PHP_INI_DIR/php.ini \
&& echo "variables_order = GPCS" >> $PHP_INI_DIR/php.ini \
&& echo "sendmail_path = /usr/bin/env $(which catchmail) -f scope@local.dev" >> $PHP_INI_DIR/php.ini

RUN echo "<FilesMatch \\.wsdl$>\n\tSetHandler application/x-httpd-php\n</FilesMatch>" >> /etc/apache2/apache2.conf
RUN echo "IncludeOptional sites-enabled/*.conf" >> /etc/apache2/apache2.conf

CMD [ "apache2-foreground" ]
