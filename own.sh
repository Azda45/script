#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Nginx
echo "Installing Nginx..."
sudo apt install nginx -y

# Install MySQL
echo "Installing MySQL..."
sudo apt install mysql-server -y
sudo mysql_secure_installation

# Install PHP 7.4 and required modules
echo "Installing PHP 7.4 and required modules..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php7.4 php7.4-fpm php7.4-mysql php7.4-json php7.4-curl php7.4-gd php7.4-xml php7.4-mbstring php7.4-intl php7.4-zip php7.4-bz2 php7.4-imagick php7.4-gmp -y

# Configure PHP settings
echo "Configuring PHP settings..."
PHP_INI="/etc/php/7.4/fpm/php.ini"
sudo sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 10G/' $PHP_INI
sudo sed -i 's/^post_max_size = .*/post_max_size = 10G/' $PHP_INI
sudo sed -i 's/^memory_limit = .*/memory_limit = 512M/' $PHP_INI
sudo sed -i 's/^max_execution_time = .*/max_execution_time = 360/' $PHP_INI

# Restart PHP-FPM
echo "Restarting PHP-FPM..."
sudo systemctl restart php7.4-fpm

# Download and setup OwnCloud
echo "Downloading and setting up OwnCloud..."
wget https://download.owncloud.com/server/stable/owncloud-latest.zip
sudo apt install unzip -y
unzip owncloud-latest.zip
sudo mv owncloud /var/www/
sudo chown -R www-data:www-data /var/www/owncloud
sudo chmod -R 755 /var/www/owncloud

# Create and set permissions for data directory
echo "Creating and setting permissions for data directory..."
sudo mkdir -p /mnt/owncloud/data
sudo chown -R www-data:www-data /mnt/owncloud/data
sudo chmod -R 755 /mnt/owncloud/data

# Configure Nginx for OwnCloud
echo "Configuring Nginx for OwnCloud..."
cat <<EOL | sudo tee /etc/nginx/sites-available/owncloud
server {
    listen 80;
    server_name 172.16.10.14;

    root /var/www/owncloud/;
    index index.php index.html /index.php\$request_uri;

    client_max_body_size 10G;
    fastcgi_buffers 64 4K;

    gzip off;

    error_page 403 /core/templates/403.php;
    error_page 404 /core/templates/404.php;

    location / {
        try_files \$uri /index.php\$request_uri;
    }

    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
        deny all;
    }

    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console) {
        deny all;
    }

    location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v1|ocs/v2|updater/.+|ocs-provider/.+|core/templates/40[34])\.php(?:$|/) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_param HTTPS on;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param modHeadersAvailable true;
        fastcgi_param front_controller_active true;
        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
    }

    location ~ ^/(?:updater|ocs-provider)(?:$|/) {
        try_files \$uri/ =404;
        index index.php;
    }

    location ~ \.(?:css|js|woff|svg|gif|map|ico)$ {
        try_files \$uri /index.php\$request_uri;
        expires 6M;
        access_log off;
    }

    location ~ \.(?:png|html|ttf|ico|jpg|jpeg)$ {
        try_files \$uri /index.php\$request_uri;
        access_log off;
    }
}
EOL

# Enable OwnCloud site and restart Nginx
echo "Enabling OwnCloud site and restarting Nginx..."
sudo ln -s /etc/nginx/sites-available/owncloud /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Create OwnCloud database and user
echo "Creating OwnCloud database and user..."
sudo mysql -u root -p <<MYSQL_SCRIPT
CREATE DATABASE owncloud;
CREATE USER 'ownclouduser'@'localhost' IDENTIFIED BY '434VYLVYJ0OE';
GRANT ALL PRIVILEGES ON owncloud.* TO 'ownclouduser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

echo "OwnCloud installation and configuration complete. Please complete the setup through the web interface at http://172.16.10.14"
