#!/bin/bash
set -e

# Wait for cloud-init network
sleep 5

# Update & install deps
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip awscli apt-transport-https ca-certificates

# Install Puppet (puppetagent for deb)
wget https://apt.puppetlabs.com/puppet-release-jammy.deb -O /tmp/puppet-release.deb
dpkg -i /tmp/puppet-release.deb || true
apt-get update -y
apt-get install -y puppet

# Install nginx
apt-get install -y nginx
systemctl enable --now nginx

# Install NRPE + nagios-plugins (client)
apt-get install -y nagios-nrpe-server nagios-plugins

# Configure NRPE to allow Nagios server
sed -i "s/^allowed_hosts=.*/allowed_hosts=127.0.0.1,${nagios_server_ip}/" /etc/nagios/nrpe.cfg || true
systemctl restart nagios-nrpe-server || true

# Fetch puppet manifests from S3 and apply (this example fetches a site.pp)
mkdir -p /opt/puppet-manifests
aws s3 cp "s3://${s3_bucket}/puppet/manifests/site.pp" /opt/puppet-manifests/site.pp --region ${aws_region}

# Place a simple puppet apply wrapper
cat > /opt/puppet-manifests/run.sh <<'EOF'
#!/bin/bash
puppet apply /opt/puppet-manifests/site.pp --verbose
EOF
chmod +x /opt/puppet-manifests/run.sh

# run puppet apply
/opt/puppet-manifests/run.sh || true

# deploy React build from S3 prefix if exists
if aws s3 ls "s3://${s3_bucket}/${s3_prefix}/" 2>/dev/null; then
  mkdir -p /var/www/react
  aws s3 sync "s3://${s3_bucket}/${s3_prefix}/" /var/www/react --region ${aws_region}
  # nginx site config
  cat > /etc/nginx/sites-available/react <<'NGINX'
server {
  listen 80;
  server_name _;
  root /var/www/react;
  index index.html index.htm;

  location / {
    try_files $uri $uri/ /index.html;
  }
}
NGINX
  ln -sf /etc/nginx/sites-available/react /etc/nginx/sites-enabled/react
  nginx -s reload || systemctl restart nginx
fi
