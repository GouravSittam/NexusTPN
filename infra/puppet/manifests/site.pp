# Nagios server node
node /^nagios-server/ {
  include nagios_server
}

# App server nodes (default)
node default {
  include nginx
  include nagios_client
}
