#!/bin/bash
# cloud-init / user-data for Puppet Server (Ubuntu)
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y wget curl

# install puppet repo
wget https://apt.puppet.com/puppet7-release-$(lsb_release -cs).deb -O /tmp/puppet7.deb
dpkg -i /tmp/puppet7.deb || true
apt-get update -y

# install puppetserver
apt-get install -y puppetserver

# reduce JVM RAM for small instance (optional)
sed -i 's/JAVA_ARGS="-Xms2g -Xmx2g"/JAVA_ARGS="-Xms512m -Xmx512m"/' /etc/default/puppetserver || true

systemctl enable puppetserver
systemctl start puppetserver

# add puppet binary to PATH for ubuntu user convenience
echo 'export PATH=$PATH:/opt/puppetlabs/bin' >> /home/ubuntu/.bashrc
