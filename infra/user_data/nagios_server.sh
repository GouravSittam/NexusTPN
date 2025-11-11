#!/bin/bash
# cloud-init / user-data for Nagios Core (Ubuntu)
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y apache2 php libapache2-mod-php build-essential libgd-dev unzip wget

cd /tmp
# use a stable Nagios release version; update URL if version changes
NAGIOS_VERSION="4.4.14"
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_VERSION}.tar.gz
tar -zxvf nagios-${NAGIOS_VERSION}.tar.gz
cd nagios-${NAGIOS_VERSION}

./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
make install-groups-users
usermod -aG nagios www-data || true
make install
make install-daemoninit
make install-commandmode
make install-config
make install-webconf

# create web admin user (default: nagiosadmin)
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin NagiosAdmin123!

systemctl restart apache2
systemctl enable nagios
systemctl start nagios
