#!/bin/bash
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install git curl apache2 mysql-server libapache2-mod-auth-mysql php5-mysql php5 php5-cli libapache2-mod-php5 php5-mcrypt phpmyadmin autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev -y

echo "Recongiguring MySQL"
sudo mysql_install_db
sudo /usr/bin/mysql_secure_installation

echo "Copying proper dir.conf"
sudo cp dir.conf /etc/apache2/mods-enabled/dir.conf

echo "Installing Composer"
# Install Composer
sudo curl -sS https://getcomposer.org/installer | php
sudo cp composer.phar /usr/bin/composer

echo "Restarting Apache"
# restart apache
sudo service apache2 restart

echo "Installing Ruby and Gems"
# install ruby and rubygems
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
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

echo "Starting Configuration"
source config.sh
