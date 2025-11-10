class nagios_client {
  package { ['nagios-nrpe-server','nagios-plugins']:
    ensure => installed,
  }

  file { '/etc/nagios/nrpe.cfg':
    ensure  => present,
    content => template('nagios/nrpe.cfg.erb'), # provide allowed_hosts including nagios server ip
    notify  => Service['nagios-nrpe-server'],
  }

  service { 'nagios-nrpe-server':
    ensure => running,
    enable => true,
    require => Package['nagios-nrpe-server'],
  }

  # Example custom check plugin (CPU threshold simple script)
  file { '/usr/local/bin/check_high_cpu.sh':
    ensure  => file,
    mode    => '0755',
    content => @(EOM)
#!/bin/bash
# check_high_cpu.sh: warn if load average (1 minute) > 2.0
load=$(cat /proc/loadavg | awk '{print $1}')
limit=2.0
awk -v l="$load" -v lim="$limit" 'BEGIN { if (l+0 > lim+0) { print "CRITICAL - load " l; exit 2 } else { print "OK - load " l; exit 0 } }'
EOM
  }

  # Add nrpe command in /etc/nagios/nrpe_local.cfg or nrpe.cfg include
  augeas { 'add_nrpe_command':
    context => '/files/etc/nagios/nrpe_local.cfg',
    changes => [
      "set command[1] '/usr/local/bin/check_high_cpu.sh'",
    ],
    onlyif  => "match /files/etc/nagios/nrpe_local.cfg/* size == 0"
  }
}
