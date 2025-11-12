#!/bin/bash
apt-get update -y
apt-get install -y wget curl git build-essential
# Install Nagios Core dependencies
apt-get install -y libgd-dev libssl-dev libc6-dev libperl-dev libdbi-perl libdbd-mysql-perl libnet-snmp-perl
# Download and install Nagios Core
cd /tmp
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz
tar -xzf nagios-4.4.6.tar.gz
cd nagios-4.4.6
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
# Install Nagios plugins
apt-get install -y nagios-plugins nagios-plugins-contrib
# Create nagiosadmin user
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin admin
# Enable and start Nagios
systemctl enable nagios
systemctl start nagios
# Configure Apache
a2enmod rewrite cgi
systemctl restart apache2
# Allow HTTP access
ufw allow 80/tcp || true

