# Create pools per vhost

define php7_fpm::create_pool (
  $poolname,
  $runowner,
  $rungroup
) {

  file { "/etc/php/7.0/fpm/pool.d/${poolname}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('php7_fpm/etc/php/7.0/fpm/pool.d/pool.conf.erb')
  }

}
