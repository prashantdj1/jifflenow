# Custom php5-fpm maintainer, designed specifically for the wordpress env :(
class php5_fpm {

  $php_packages = [
    'php5-fpm',
    'php5-memcache',
    'php5-memcached',
    'php5-mysql',
    'php5-gd',
    #'php-mail',
    'php5-curl',
    'php5-mcrypt',
    'php5-cli'
  ]

  package { $php_packages:
    ensure => 'latest'
  }

  service {
    'php5-fpm':
      ensure  => 'running',
      enable  => true,
      require => Package['php5-fpm'],
  }

  file {
    '/etc/php5/mods-available/local.ini':
      ensure  => present,
      source  => 'puppet:///modules/php5_fpm/etc/php5/mods-available/local.ini',
      notify  => Service['php5-fpm'],
      require => Package['php5-fpm'],
      owner   => 'root',
      group   => 'root';

    '/etc/php5/fpm/conf.d/99-local.ini':
      ensure  => link,
      target  => '/etc/php5/mods-available/local.ini',
      notify  => Service['php5-fpm'],
      require => Package['php5-fpm'];

    '/etc/php5/cli/conf.d/99-local.ini':
      ensure  => link,
      target  => '/etc/php5/mods-available/local.ini',
      notify  => Service['php5-fpm'],
      require => Package['php5-fpm'];

    '/etc/php5/fpm/pool.d/www.conf':
      ensure  => present,
      content => template('php5_fpm/etc/php5/fpm/pool.d/www.conf.erb'),
      notify  => Service['php5-fpm'],
      require => Package['php5-fpm'];

    '/var/run/php5-fpm/':
      ensure  => directory,
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['php5-fpm'];
  }
}
