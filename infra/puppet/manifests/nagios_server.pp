class nagios_server (
  String $app_server_ip = '10.0.1.100',  # Default or pass via fact/hiera
) {
  package { ['nagios4','nagios-plugins','monitoring-plugins-basic','nagios-nrpe-plugin']:
    ensure => installed,
  }

  service { 'nagios':
    ensure => running,
    enable => true,
    require => Package['nagios4'],
  }

  file { '/etc/nagios/conf.d/hosts.cfg':
    ensure  => file,
    content => template('nagios/hosts.cfg.erb'),
    notify  => Service['nagios'],
  }

  file { '/etc/nagios/conf.d/services.cfg':
    ensure  => file,
    content => template('nagios/services.cfg.erb'),
    notify  => Service['nagios'],
  }

  # Place custom plugins directory
  file { '/usr/local/nagios/libexec/custom':
    ensure => directory,
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0755',
  }
}
