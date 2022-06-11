#!/bin/sh
sitename=$1
user=$(echo $sitename | tr '[:upper:]' '[:lower:]' | cut -d. -f1)
# install nginx
apt-get install nginx

# firewall rules
ufw allow 'Nginx Full' # http, https
ufw allow ssh

# fail2ban install and configuration
apt-get install fail2ban

service fail2ban start

# install zip and unzip and openssl and webp and imagemagick
apt-get install zip unzip openssl webp imagemagick

# enable gzip compression for nginx server and client side (gzip_comp_level=2) (gzip_min_length=1024) (gzip_proxied=any) (gzip_vary=off) (gzip_http_version=1.0) (gzip_types=text/plain application/x-javascript text/css application/xml application/x-httpd-php image/png image/gif image/jpeg image/jpg application/x-javascript application/x-shockwave-flash)
sed -i 's/^gzip.*/gzip on;/' /etc/nginx/nginx.conf
sed -i 's/^gzip_comp_level.*/gzip_comp_level=2;/' /etc/nginx/nginx.conf
sed -i 's/^gzip_min_length.*/gzip_min_length=1024;/' /etc/nginx/nginx.conf
sed -i 's/^gzip_proxied.*/gzip_proxied=any;/' /etc/nginx/nginx.conf
sed -i 's/^gzip_vary.*/gzip_vary=off;/' /etc/nginx/nginx.conf
sed -i 's/^gzip_http_version.*/gzip_http_version=1.0;/' /etc/nginx/nginx.conf
sed -i 's/^gzip_types.*/gzip_types text\/plain application\/x-javascript text\/css application\/xml application\/x-httpd-php image\/png image\/gif image\/jpeg image\/jpg application\/x-javascript application\/x-shockwave-flash;/' /etc/nginx/nginx.conf
sed -i 's/^gzip_buffers.*/gzip_buffers 16 8k;/' /etc/nginx/nginx.conf

# check brotli compression for nginx server and client side (brotli_comp_level=2) (brotli_min_length=1024) (brotli_proxied=any) (brotli_vary=off) (brotli_http_version=1.0) (brotli_types=text/plain application/x-javascript text/css application\/xml application\/x-httpd-php image\/png image\/gif image\/jpeg image\/jpg application\/x-javascript application\/x-shockwave-flash)
sed -i 's/^brotli.*/brotli on;/' /etc/nginx/nginx.conf
sed -i 's/^brotli_comp_level.*/brotli_comp_level=2;/' /etc/nginx/nginx.conf
sed -i 's/^brotli_min_length.*/brotli_min_length=1024;/' /etc/nginx/nginx.conf
sed -i 's/^brotli_proxied.*/brotli_proxied=any;/' /etc/nginx/nginx.conf
sed -i 's/^brotli_vary.*/brotli_vary=off;/' /etc/nginx/nginx.conf
sed -i 's/^brotli_http_version.*/brotli_http_version=1.0;/' /etc/nginx/nginx.conf
sed -i 's/^brotli_types.*/brotli_types text\/plain application\/x-javascript text\/css application\/xml application\/x-httpd-php image\/png image\/gif image\/jpeg image\/jpg application\/x-javascript application\/x-shockwave-flash;/' /etc/nginx/nginx.conf

# remove default nginx site configuration and enable our site
rm /etc/nginx/sites-enabled/default

# add sendfile to nginx
sed -i 's/^sendfile.*/sendfile on;/' /etc/nginx/nginx.conf

# add client_max_body_size to nginx.conf
sed -i 's/^client_max_body_size.*/client_max_body_size 20M;/' /etc/nginx/nginx.conf

# add server_names_hash_bucket_size to nginx.conf
sed -i 's/^server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/' /etc/nginx/nginx.conf

# add server_names_hash_max_size to nginx.conf
sed -i 's/^server_names_hash_max_size.*/server_names_hash_max_size 64;/' /etc/nginx/nginx.conf

# add server_token to nginx.conf
sed -i 's/^server_token.*/server_token off;/' /etc/nginx/nginx.conf

# add server_token_reuse to nginx.conf
sed -i 's/^server_token_reuse.*/server_token_reuse off;/' /etc/nginx/nginx.conf

# add server_token_timeout to nginx.conf
sed -i 's/^server_token_timeout.*/server_token_timeout 3600;/' /etc/nginx/nginx.conf

# add server_token_expire to nginx.conf
sed -i 's/^server_token_expire.*/server_token_expire 3600;/' /etc/nginx/nginx.conf

# add server_token_invalidate to nginx.conf
sed -i 's/^server_token_invalidate.*/server_token_invalidate 3600;/' /etc/nginx/nginx.conf

# SSL version
sed -i 's/^ssl_protocol.*/ssl_protocol TLSv1.2 TLSv1.3;/' /etc/nginx/nginx.conf

# add ssl session cache nginx
sed -i 's/^ssl_session_cache.*/ssl_session_cache shared:SSL:10m;/' /etc/nginx/nginx.conf

# add ssl session timeout nginx
sed -i 's/^ssl_session_timeout.*/ssl_session_timeout 10m;/' /etc/nginx/nginx.conf

# nginx Strict-Transport-Security header
sed -i 's/^add_header Strict-Transport-Security.*/add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";/' /etc/nginx/nginx.conf

# nginx X-Frame-Options header
sed -i 's/^add_header X-Frame-Options.*/add_header X-Frame-Options "SAMEORIGIN";/' /etc/nginx/nginx.conf

# nginx X-XSS-Protection header
sed -i 's/^add_header X-XSS-Protection.*/add_header X-XSS-Protection "1; mode=block";/' /etc/nginx/nginx.conf

# nginx X-Content-Type-Options header
sed -i 's/^add_header X-Content-Type-Options.*/add_header X-Content-Type-Options "nosniff";/' /etc/nginx/nginx.conf

# nginx X-Download-Options header
sed -i 's/^add_header X-Download-Options.*/add_header X-Download-Options "noopen";/' /etc/nginx/nginx.conf

# nginx prevent access to hidden files
sed -i 's/^;*autoindex.*/autoindex off/' /etc/nginx/nginx.conf

# fail2ban wordpress configuration
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
ignoreip =
bantime = 3600
findtime = 600
maxretry = 3
backend = auto
[ssh]
enabled = true
port = ssh
EOF

# nginx restart
service nginx restart

# fail2ban restart
service fail2ban restart

cd ~

# install default php version and its dependencies
apt-get install -y php php-fpm php-cli php-common php-dev php-gd php-json php-opcache php-readline php-mbstring php-mcrypt php-mysql php-xml php-zip php-curl php-intl php-bz2 php-zip php-bcmath php-soap php-gmp php-pgsql php-sqlite3 php-xdebug php-memcached php-redis php-imagick php-tidy php-pspell php-recode php-snmp php-ssh2 php-gettext php-imap php-gmp php-ldap php-intl php-bz2 php-zip php-bcmath php-soap php-gmp php-pgsql php-sqlite3 php-xdebug php-memcached php-redis php-imagick php-tidy php-pspell php-recode php-snmp php-ssh2 php-gettext php-imap php-gmp php-ldap php-intl php-bz2 php-zip php-imap php-bcmath php-soap php-gmp php-memcached php-redis php-imagick

# get php version 
PHP_VERSION=$(php -v | grep -o -P '(?<=PHP )[0-9]{1,2}\.[0-9]{1,2}')

# php date timezone
sed -i 's/^;date.timezone.*/date.timezone = "UTC"/' /etc/php/$PHP_VERSION/fpm/php.ini

# php performance tuning
sed -i 's/^;*memory_limit.*/memory_limit=2048M/' /etc/php/$PHP_VERSION/fpm/php.ini
sed -i 's/^;*upload_max_filesize.*/upload_max_filesize=20M/' /etc/php/$PHP_VERSION/fpm/php.ini
sed -i 's/^;*post_max_size.*/post_max_size=20M/' /etc/php/$PHP_VERSION/fpm/php.ini
sed -i 's/^;*max_execution_time.*/max_execution_time=300/' /etc/php/$PHP_VERSION/fpm/php.ini
sed -i 's/^;*max_input_time.*/max_input_time=300/' /etc/php/$PHP_VERSION/fpm/php.ini
sed -i 's/^;*max_input_vars.*/max_input_vars=2000/' /etc/php/$PHP_VERSION/fpm/php.ini

# php-fpm restart
service php$PHP_VERSION-fpm restart

# restart php-fpm
service php$PHP_VERSION-fpm restart

# installing wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# installing composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# make composer available globally
ln -s /usr/local/bin/composer /usr/bin/composer

# install mariadb latest version
apt-get install -y mariadb-server mariadb-client

# mysql secure installation
mysql_secure_installation

# install certbot snapd package
snap install core; snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

# install redis-server
apt-get install -y redis-server

# install memcached
apt-get install -y memcached


# redis-server configuration for php-fpm
sed -i 's/^;*max-clients.*/max-clients=256/' /etc/redis/redis.conf
sed -i 's/^;*maxmemory-policy.*/maxmemory-policy=volatile-lru/' /etc/redis/redis.conf
sed -i 's/^;*maxmemory-samples.*/maxmemory-samples=3/' /etc/redis/redis.conf

# install redis-tools
apt-get install -y redis-tools

# redis change supervised setting
sed -i 's/^supervised.*/supervised systemd/' /etc/redis/redis.conf

# generate redis password 
REDIS_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
echo "requirepass $REDIS_PASSWORD" >> /etc/redis/redis.conf

# redis-server restart
service redis-server restart

# redis performance tuning
sed -i 's/^;*vm.overcommit_memory.*/vm.overcommit_memory=1/' /etc/sysctl.conf
sysctl -p

# mysql performance tuning
mysql -e "SET GLOBAL innodb_buffer_pool_size=256M;"
mysql -e "SET GLOBAL innodb_log_file_size=256M;"
mysql -e "SET GLOBAL innodb_flush_log_at_trx_commit=2;"
mysql -e "SET GLOBAL innodb_io_capacity=200;"
mysql -e "SET GLOBAL innodb_read_io_threads=4;"
mysql -e "SET GLOBAL innodb_write_io_threads=4;"
mysql -e "SET GLOBAL innodb_thread_concurrency=16;"
mysql -e "SET GLOBAL innodb_flush_log_at_trx_commit=2;"
mysql -e "SET GLOBAL innodb_max_dirty_pages_pct=90;"
mysql -e "SET GLOBAL innodb_file_per_table=1;"
mysql -e "SET GLOBAL innodb_open_files=2000;"

# generate cron job for certbot
# cat > /etc/cron.d/certbot << EOF
# 0 0 1 * * certbot renew --pre-hook "service nginx stop" --post-hook "service nginx start"
# EOF