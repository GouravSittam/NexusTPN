class react_deploy (
  String $repo_url = 'https://github.com/GouravSittam/YumYum.git',
  String $deploy_dir = '/opt/react-app',
) {
  package { ['git','nodejs','npm']:
    ensure => present,
  }

  exec { "clone_app":
    command => "rm -rf ${deploy_dir} && git clone ${repo_url} ${deploy_dir}",
    creates => $deploy_dir,
    require => Package['git'],
  }

  exec { "install_deps":
    cwd     => $deploy_dir,
    command => '/usr/bin/npm install',
    require => Exec['clone_app'],
  }

  exec { "build_react":
    cwd     => $deploy_dir,
    command => '/usr/bin/npm run build',
    require => Exec['install_deps'],
  }

  # serve static build using simple http-server (or configure nginx)
  # Parcel outputs to 'dist' directory, but check for both 'dist' and 'build'
  package { 'http-server':
    ensure   => present,
    provider => 'npm',
    require  => Exec['build_react'],
  }

  file { '/etc/systemd/system/react-app.service':
    ensure  => file,
    content => @(EOF)
      [Unit]
      Description=YumYum React App static server
      After=network.target

      [Service]
      Type=simple
      # Parcel builds to 'dist', Create React App builds to 'build'
      # Try dist first (Parcel), fallback to build
      ExecStart=/bin/bash -c 'if [ -d ${deploy_dir}/dist ]; then /usr/bin/npx http-server ${deploy_dir}/dist -p 3000; else /usr/bin/npx http-server ${deploy_dir}/build -p 3000; fi'
      Restart=on-failure
      User=root

      [Install]
      WantedBy=multi-user.target
      | EOF
    require => Package['http-server'],
  }

  service { 'react-app':
    ensure    => running,
    enable    => true,
    provider  => 'systemd',
    require   => File['/etc/systemd/system/react-app.service'],
  }
}
