#!/usr/bin/env bash

cd /
sudo yum update -y

# nginx install
sudo touch /etc/yum.repos.d/nginx.repo
sudo chmod a+w /etc/yum.repos.d/nginx.repo
sudo cat <<EOF >> /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOF
sudo yum install -y nginx

# php php-fpm install
sudo yum -y install epel-release
sudo yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
sudo yum -y install php72 php72-php
sudo yum -y install --enablerepo=remi,remi-php72 php php-fpm php-mbstring php-xml php-xmlrpc php-gd php-pdo php-pecl-mcrypt php-mysqlnd php-pecl-mysql php-pecl-zip composer

# php-fpm nginx: Cooperation setting
sudo cp /vagrant/setting/default.conf /etc/nginx/conf.d/default.conf
sudo cp /vagrant/setting/www.conf /etc/php-fpm.d/www.conf

# php-fpm nginx start
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo systemctl start nginx
sudo systemctl enable nginx

# create index.php to debug
sudo touch /usr/share/nginx/html/index.php
sudo chmod a+w /usr/share/nginx/html/index.php
sudo cat <<EOF >> /usr/share/nginx/html/index.php
<?php phpinfo(); ?>
EOF

# composer install
cd ~
# sudo curl -sS https://getcomposer.org/installer | php
# sudo mv composer.phar /usr/local/bin/composer
# sudo yum -y install --enablerepo=remi,remi-php72 php-pecl-zip composer

# node(npm) install
sudo curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum -y install nodejs

# mariaDB install
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
sudo yum -y install MariaDB-server
sudo cp /vagrant/setting/mariaDB_server.cnf /etc/my.cnf.d/server.cnf
sudo systemctl enable mariadb
sudo systemctl start mariadb

# create Laravel project
cd /vagrant/
composer create-project "laravel/laravel=6.*" laravel-project
sudo ln -s /vagrant/laravel-project/public/ /var/www/
sudo chmod -R 777 /vagrant/laravel-project/storage/
sudo chmod -R 777 /vagrant/laravel-project/bootstrap/cache/