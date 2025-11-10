#!/bin/bash
set -e
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget gnupg lsb-release awscli

# Install build deps and nagios3 (or nagios4 depending on distro). We'll install nagios core from apt.
apt-get install -y nagios4 nagios-plugins-all nagios-nrpe-server

# enable nagios
systemctl enable --now nagios

# install puppet (for server-side config)
wget https://apt.puppetlabs.com/puppet-release-jammy.deb -O /tmp/puppet-release.deb
dpkg -i /tmp/puppet-release.deb || true
apt-get update -y
apt-get install -y puppet

# fetch puppet manifests and apply
mkdir -p /opt/puppet-manifests
aws s3 cp "s3://${s3_bucket}/puppet/manifests/site.pp" /opt/puppet-manifests/site.pp --region ${aws_region} || true

# run puppet apply if manifest is present
if [ -f /opt/puppet-manifests/site.pp ]; then
  puppet apply /opt/puppet-manifests/site.pp || true
fi

# open firewall rules already handled in SGs
