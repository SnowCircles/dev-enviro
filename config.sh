#!/bin/bash

# dnsmasq setup
echo 'address=/.dev/127.0.0.1' > /etc/dnsmasq.conf
echo 'listen-address=127.0.0.1' >> /etc/dnsmasq.conf

# make sure domain name servers is prepended by 127.0.0.1
# on /etc/dhcp3/dhclient.conf

# prepend domain-name-servers 127.0.0.1;

# resolver setup
echo 'nameserver 127.0.0.1' > /etc/resolver/dev

/etc/init.d/dnsmasq restart