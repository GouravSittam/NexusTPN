#!/bin/bash
apt-get update -y
apt-get install -y wget curl git
# Install puppet agent
wget https://apt.puppet.com/puppet7-release-jammy.deb
dpkg -i puppet7-release-jammy.deb
apt-get update -y
apt-get install -y puppet-agent nodejs npm
# Make sure /opt/puppetlabs/bin is in PATH for the script
export PATH=$PATH:/opt/puppetlabs/bin
# set puppet.conf to point to puppet server (replace <PUPPET_IP> later or template)
sed -i "s/\[main\]/[main]\nserver=puppetserver\nruninterval=30m/" /etc/puppetlabs/puppet/puppet.conf
# start puppet agent (it will try to connect and wait for cert signing)
systemctl enable --now puppet
