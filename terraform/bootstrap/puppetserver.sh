#!/bin/bash
# Optimized Puppet Server installation with better performance settings
set -e

echo "Starting Puppet Server installation and optimization..."

# Update system and install prerequisites
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y wget apt-transport-https lsb-release ca-certificates

# Add Puppet repo
wget -q https://apt.puppet.com/puppet7-release-jammy.deb
dpkg -i puppet7-release-jammy.deb
apt-get update -y

# Install Puppet Server with Java
DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-11-jre-headless puppetserver

# Configure memory footprint - Increased for better performance
# Using 2GB for better performance (adjust based on instance size)
if grep -q '^JAVA_ARGS=' /etc/default/puppetserver; then
  sed -i 's/^JAVA_ARGS=.*/JAVA_ARGS="-Xms1g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=50"/' /etc/default/puppetserver
else
  echo 'JAVA_ARGS="-Xms1g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=50"' >> /etc/default/puppetserver
fi

# Create optimized tuning configuration
cat <<'EOF' >/etc/puppetlabs/puppetserver/conf.d/tuning.conf
# Optimized Puppet Server performance settings
jruby-puppet {
  # Increased instances for parallel catalog compilation
  max-active-instances = 2
  max-requests-per-instance = 10000
  borrow-timeout = 1200000
  max-queued-requests = 150
  max-retry-delay = 1800
}

# Improved webserver settings
webserver {
  max-threads = 100
  ssl-protocols = [TLSv1.2, TLSv1.3]
}

# Disable persistent data for faster compilation
persistent-data {
  disable = true
}
EOF

# Configure auth.conf for better performance
cat <<'EOF' >/etc/puppetlabs/puppetserver/conf.d/auth.conf
authorization: {
    version: 1
    rules: [
        {
            match-request: {
                path: "/"
                type: path
            }
            allow-unauthenticated: true
            sort-order: 1
            name: "Allow all"
        }
    ]
}
EOF

# Optimize puppet.conf
cat <<'EOF' >/etc/puppetlabs/puppet/puppet.conf
[main]
certname = puppetserver
server = puppetserver
environment = production
runinterval = 30m

[master]
dns_alt_names = puppetserver,puppet
autosign = true
EOF

# Create environments directory
mkdir -p /etc/puppetlabs/code/environments/production/{manifests,modules}

# Enable firewall rule
ufw allow 8140/tcp || true

# Start Puppet Server
systemctl enable puppetserver
systemctl start puppetserver

# Wait for Puppet Server to fully start
echo "Waiting for Puppet Server to start..."
for i in {1..30}; do
  if systemctl is-active --quiet puppetserver; then
    echo "Puppet Server started successfully"
    break
  fi
  sleep 2
done

echo "Puppet Server installation complete!"
