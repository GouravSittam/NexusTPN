class nginx {
  package { 'nginx':
    ensure => installed,
  }

  service { 'nginx':
    ensure => running,
    enable => true,
    require => Package['nginx'],
  }

  file { '/var/www/react':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
  }

  file { '/etc/nginx/sites-available/react':
    ensure  => file,
    content => template('nginx/react.erb'), # optional template if you use puppet templates
    notify  => Service['nginx'],
  }

  file { '/etc/nginx/sites-enabled/react':
    ensure => link,
    target => '/etc/nginx/sites-available/react',
    require => File['/etc/nginx/sites-available/react'],
  }
}
