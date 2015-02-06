#!/bin/bash

#sudo apt-get update
sudo apt-get install git curl apache2 mysql-server libapache2-mod-auth-mysql php5-mysql php5 php5-cli libapache2-mod-php5 php5-mcrypt phpmyadmin -y

sudo mysql_install_db
sudo /usr/bin/mysql_secure_installation

### Add index.php
#nano /etc/apache2/mods-enabled/dir.conf
#<IfModule mod_dir.c>
#
#          DirectoryIndex index.php index.html index.cgi index.pl index.php index.xhtml index.htm
#
#</IfModule>

sudo cp dir.conf /etc/apache2/mods-enabled/dir.conf

# Install Composer
sudo curl -sS https://getcomposer.org/installer | php
sudo cp composer.phar /usr/bin/composer

# restart apache
sudo service apache2 restart

# install ruby and rubygems

# Checking if RVM is installed
if ! [ -d "~/.rvm" ]; then
    echo "Installing RVM..."
    \curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
else
    echo "Updating RVM..."
    rvm get stable
fi;

echo -n "RVM version is: "
rvm --version

echo "Installing Ruby..."
rvm install ruby

echo "Making installed Ruby the default one..."
rvm use ruby --default

echo "Installing latest version of Ruby Gems..."
rvm rubygems current