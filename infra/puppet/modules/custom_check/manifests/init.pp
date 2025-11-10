class custom_check {
  # Drop the custom check script in place for NRPE or local use
  file { '/usr/local/bin/check_custom.sh':
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/custom_check/check_custom.sh',
  }
}
