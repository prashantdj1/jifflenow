# Create pools per vhost

define php5_fpm::create_pool (
  $poolname,
  $runowner,
  $rungroup
) {

  file { "/etc/php5/fpm/pool.d/${poolname}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('php5_fpm/etc/php5/fpm/pool.d/pool.conf.erb')
  }

}
