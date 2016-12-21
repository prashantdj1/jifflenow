# Custom php7.0-fpm maintainer, designed specifically for the wordpress env :(
class php7_fpm {

  $php_packages = [
    'php7.0-fpm',
    'php7.0-mysql',
    'php7.0-gd',
    'php7.0-curl',
    'php7.0-mcrypt',
    'php7.0-cli'
  ]

  package { $php_packages:
    ensure => 'latest'
  }

  service {
    'php7.0-fpm':
      ensure  => 'running',
      enable  => true,
      require => Package['php7.0-fpm'],
  }

  file {
    '/etc/php/7.0/mods-available/local.ini':
      ensure  => present,
      source  => 'puppet:///modules/php7_fpm/etc/php7.0/mods-available/local.ini',
      notify  => Service['php7.0-fpm'],
      require => Package['php7.0-fpm'],
      owner   => 'root',
      group   => 'root';

    '/etc/php/7.0/fpm/conf.d/99-local.ini':
      ensure  => link,
      target  => '/etc/php/7.0/mods-available/local.ini',
      notify  => Service['php7.0-fpm'],
      require => Package['php7.0-fpm'];

    '/etc/php/7.0/cli/conf.d/99-local.ini':
      ensure  => link,
      target  => '/etc/php/7.0/mods-available/local.ini',
      notify  => Service['php7.0-fpm'],
      require => Package['php7.0-fpm'];

    '/etc/php/7.0/fpm/pool.d/www.conf':
      ensure  => present,
      content => template('php7_fpm/etc/php7.0/fpm/pool.d/www.conf.erb'),
      notify  => Service['php7.0-fpm'],
      require => Package['php7.0-fpm'];

    '/var/run/php7.0-fpm/':
      ensure  => directory,
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['php7.0-fpm'];
  }
}
