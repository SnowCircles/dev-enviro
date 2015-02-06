#!/bin/bash

# get current user's home directory
userhome="$HOME"

# dnsmasq setup
sudo bash -c "echo 'address=/.dev/127.0.0.1' > /etc/NetworkManager/dnsmasq.d/dnsmasq.conf"
sudo bash -c "echo 'listen-address=127.0.0.1' >> /etc/NetworkManager/dnsmasq.d/dnsmasq.conf"

# Create sites directory in user's home
mkdir -pv $userhome/sites

# Create logs directory
mkdir -pv $userhome/sites/logs

# Create sll directory
mkdir -pv $userhome/sites/ssl

# Create self-signed ssl certificate
openssl req \
  -new \
  -newkey rsa:2048 \
  -days 3650 \
  -nodes \
  -x509 \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=$(whoami)/CN=*.dev" \
  -keyout ~/Sites/ssl/private.key \
  -out ~/Sites/ssl/selfsigned.crt

# Create config file for inclusion of ssl
cat > ~/Sites/ssl/ssl-shared-cert.inc <<EOFSSL
SSLEngine On
SSLProtocol all -SSLv2 -SSLv3
SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW
SSLCertificateFile "${USERHOME}/Sites/ssl/selfsigned.crt"
SSLCertificateKeyFile "${USERHOME}/Sites/ssl/private.key"
EOFSSL

# Add auto virtual host config to apache
sudo cat > /etc/apache2/sites-available/auto_vhosts.conf <<EOFAPACHE
#
# Set up permissions for VirtualHosts in ~/Sites
#
<Directory "${userhome}/Sites">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    <IfModule mod_authz_core.c>
        Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Allow from all
    </IfModule>
</Directory>

# For http://localhost in the users' Sites folder
<VirtualHost _default_:80>
    ServerName localhost
    DocumentRoot "${userhome}/Sites"
</VirtualHost>
<VirtualHost _default_:443>
    ServerName localhost
    Include "${userhome}/Sites/ssl/ssl-shared-cert.inc"
    DocumentRoot "${userhome}/Sites"
</VirtualHost>

#
# VirtualHosts
#

#
# Automatic VirtualHosts
#
# A directory at ${userhome}/Sites/webroot/www can be accessed at http://webroot.dev
# In some cases you need to add this rule to .htaccess: RewriteBase /
#

# This log format will display the per-virtual-host as the first field followed by a typical log line
LogFormat "%V %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combinedmassvhost

# Auto-VirtualHosts with .dev
<VirtualHost *:80>
  ServerName dev
  ServerAlias *.dev

  CustomLog "${userhome}/Sites/logs/dev-access_log" combinedmassvhost
  ErrorLog "${userhome}/Sites/logs/dev-error_log"

  VirtualDocumentRoot ${userhome}/Sites/%-2+
</VirtualHost>
<VirtualHost *:443>
  ServerName dev
  ServerAlias *.dev
  Include "${userhome}/Sites/ssl/ssl-shared-cert.inc"

  CustomLog "${userhome}/Sites/logs/dev-access_log" combinedmassvhost
  ErrorLog "${userhome}/Sites/logs/dev-error_log"

  VirtualDocumentRoot ${userhome}/Sites/%-2+/www
</VirtualHost>
EOFAPACHE

# Enable necessary modules to apache
sudo a2enmod vhost_alias
sudo a2enmod ssl

# Enable auto virtual VirtualHosts
sudo a2ensite auto_vhosts

# Restarting apache
sudo service apache2 restart

# Restarting NetworkManager
sudo service network-manager restart