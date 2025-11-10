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
aws s3 cp "s3://${PUCKET_PLACEHOLDER}/puppet/manifests/site.pp" /opt/puppet-manifests/site.pp --region ${AWS_DEFAULT_REGION:-us-east-1} || true

# FIXME: The puppet bucket name will be templated by Terraform - ensure placeholder replaced by templatefile or upload manually.

# run puppet apply if manifest is present
if [ -f /opt/puppet-manifests/site.pp ]; then
  puppet apply /opt/puppet-manifests/site.pp || true
fi

# open firewall rules already handled in SGs
