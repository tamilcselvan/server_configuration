#!/bin/sh
#
# ex: sh create_user.sh sitename wpuser wp_password wp_email
# set arguments

sitename=$1

# set wp user as the input 
wpuser=$2

# set wp password as the input
wppassword=$3

# set wp email as the input
wpmail=$4

# get php version 
PHP_VERSION=$(php -v | grep -o -P '(?<=PHP )[0-9]{1,2}\.[0-9]{1,2}')

#generate a random password including special characters
password=$(cat /dev/urandom | tr -dc '_#$%&()a-zA-Z0-9' | fold -w 21 | head -n 1)

# generate a user from sitename with slug for example "example_com"
user=$(echo $sitename | tr '[:upper:]' '[:lower:]' | tr '.' '_')
group=$(echo $sitename | tr '[:upper:]' '[:lower:]' | tr '.' '_')

# create a group with the same name as the user
groupadd $group
# create user and group and assign to www-data and home directory
useradd -m -g $group -s /bin/bash $user

# assign to www-data
usermod -a -G www-data $user
# usermod -a -G ssh $user

# assign to home directory
chown -R $user:$group /home/$user

# assign permissions
chmod -R 755 /home/$user

# set password
echo "$user:$password" | chpasswd

# create home directory
# mkdir /home/$user

# create public_html directory
mkdir /home/$user/public_html

mkdir /home/$user/backups

mkdir /home/$user/logs


# nginx security headers
cat > /etc/nginx/sites-available/$sitename.conf << EOF 
server {
    listen 80;
    server_name $sitename www.$sitename;
    root /home/$user/public_html;
    index index.php index.html index.htm;

    access_log /home/$user/logs/access.log;
    error_log /home/$user/logs/error.log;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
	add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
	add_header X-Xss-Protection "1; mode=block" always;
	add_header Referrer-Policy "origin-when-cross-origin" always;

    set \$skip_cache 0;

	if (\$request_method = POST) {
		set \$skip_cache 1;
	}   
	if (\$query_string != "") {
		set \$skip_cache 1;
	}   

	if (\$request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
		set \$skip_cache 1;
	}   

	if (\$http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
		set \$skip_cache 1;
	}

    location = /favicon.ico {
		log_not_found off;
		access_log off;
	}

	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}
	
	location ~* \.(?:eot|otf|ttf|woff|woff2)$ {
	  expires max;
	  access_log off;
	  add_header Cache-Control "public";
	}

	location ~* \.(?:svg|svgz|mp4|webm)$ {
	  expires max;
	  access_log off;
	  add_header Cache-Control "public";
	}
	
	location ~* \.(js|css|jpg|jpeg|gif|png|ico|cur|gz|aac|m4a|mp3|ogg|ogv|webp)$ {
		expires max;
		log_not_found off;
		add_header Cache-Control "public";
	}
	
	location /wp-content/uploads/ {
		location ~ \.php$ {
			deny all;
		}
		location ~ \.(png|jpe?g)$ {
			add_header Vary "Accept-Encoding";
			add_header "Access-Control-Allow-Origin" "*";
			add_header Cache-Control "public, no-transform";
			access_log off;
			log_not_found off;
			expires max;
			try_files \$uri  \$uri =404;
		}
	}
	
	location ~ /\.(svn|git)/* {
		deny all;
		access_log off;
		log_not_found off;
	}
	
	# Deny backup extensions & log files
	location ~* ^.+\.(bak|log|old|orig|original|php#|php~|php_bak|save|swo|swp|sql)$ {
	  deny all;
	  access_log off;
	  log_not_found off;
	}

	
	location ~* /(?:uploads|files|wp-content|wp-includes|akismet)/.*.php$ {
		deny all;
		access_log off;
		log_not_found off;
	}

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_pass unix:/run/php/php$PHP_VERSION-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;

        # fastcgi_cache_bypass \$skip_cache;
		# fastcgi_no_cache \$skip_cache;
		# fastcgi_cache sitename;
		# fastcgi_cache_valid 60m;
    }
    location ~ /\.ht {
        deny all;
    }

    location /xmlrpc.php {
        deny all;
        access_log off;
        log_not_found off;
        return 444;
    }
}
EOF

ln -s /etc/nginx/sites-available/$sitename.conf /etc/nginx/sites-enabled/$sitename.conf

systemctl restart nginx

# generate mysql password
MYSQL_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})

# create mysql user
mysql -u root -e "CREATE USER '$user'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';"

# create mysql database
mysql -u root -e "CREATE DATABASE $user;"

# give mysql permission to user
mysql -u root -e "GRANT ALL PRIVILEGES ON $user.* TO '$user'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';"

# flush privileges
mysql -u root -e "FLUSH PRIVILEGES;"

cd /home/$user/public_html

# login the su user with password $password
wp_siteurl="https://www.$sitename"

# get $user first three letters
db_prefix="wzd_"

# install wordpress with wp-cli and set the database name and user name and password to the input variables and set the site name to the input variable sitename and set the admin user name to the input variable wpuser and password to the input variable wppassword and email to the input variable wpmail and set the default theme to twentytwelve and set the default admin password to the input variable wppassword and email to the input variable wpmail and set the default admin password to the input variable wppassword and email to the input variable wpmail 
wp core download --path=/home/$user/public_html --locale=en_US --allow-root
# wp core config db prefix=wp_ 
wp core config --dbname=$user --dbuser=$user --dbpass=$MYSQL_PASSWORD --dbhost=localhost --dbprefix=$db_prefix --dbcharset=utf8 --dbcollate=utf8_general_ci --path=/home/$user/public_html --allow-root

wp core install --url=$wp_siteurl --title="$sitename" --admin_user=$wpuser --admin_password=$wppassword --admin_email=$wpmail --path=/home/$user/public_html  --allow-root
wp option update permalink_structure "/%postname%/"   --allow-root
wp option update default_role "subscriber"  --allow-root
wp option update DISALLOW_FILE_EDIT 1  --allow-root
# disable the theme editor
wp plugin disable theme-editor --allow-root
# disable file editor
wp plugin disable file-editor --allow-root
# disable comments on all posts
wp option update default_comment_status "closed" --allow-root
# enable manual approval for comments
wp option update comment_moderation 1 --allow-root
# disable comments on pages
wp option update page_comments 0 --allow-root
# disable comments on posts
wp option update posts_comments 0 --allow-root
# disable comments on media
wp option update media_comments 0 --allow-root
# disable comments on pages
wp option update comments_per_page 0 --allow-root
# disable comments on pages
wp option update comments_pages 0 --allow-root
# disable comments on posts
wp option update comments_posts 0 --allow-root
# disable comments on media
wp option update comments_media 0 --allow-root

# disable pingbacks
wp option update default_ping_status "closed" --allow-root

# Add ftp_method to wp-config.php using wp-cli
wp config set ftp_method "direct" --allow-root

# discourage search engines from indexing the site
wp option update blog_public 0 --allow-root

# remove the default plugins
wp plugin delete akismet hello --allow-root

# remove first post
wp post delete 1 --allow-root

# remove sample page
wp post delete 2 --allow-root

sudo chown -R www-data:$user .

find /home/$user/public_html -type d -exec chmod 775 {} \;
find /home/$user/public_html -type f -exec chmod 644 {} \;


# generate ssl certificate for the site using letsencrypt
# sudo certbot certonly --webroot -w /home/$user/public_html -d $sitename


echo "Sitename: $sitename"
echo "Username: $user"
echo "Password: $password"
