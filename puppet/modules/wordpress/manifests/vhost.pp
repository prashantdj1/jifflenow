# a type to add new vhosts

## Parameters ##

# ssl - true or false?
# ssl_port - should SSL work on a custom port (probably defunct)
# customlog - should they log to a separate location than the generic nginx locations?
# owner/group - this should be the agency that is running the site.

define wordpress::vhost(
    $owner                  =   'www-data',
    $group                  =   'www-data',
    $port                   =   undef,
    $install_dir            =   $wordpress::params::install_dir,
    $version                =   $wordpress::params::version,
    $db_host                =   $wordpress::params::db_host,
    $mysql_db_password      =   $wordpress::params::mysql_db_password,
    $wp_owner               =   $wordpress::params::wp_owner,
    $wp_group               =   $wordpress::params::wp_group,
    $db_name                =   undef,
    $db_user                =   undef,
    $db_password            =   undef,
    $wp_lang                =   undef,
    $wp_plugin_dir          =   undef,
    $wp_additional_config   =   undef,
    $wp_table_prefix        =   undef,
    $wp_proxy_host          =   undef,
    $wp_proxy_port          =   undef,
    $wp_multisite           =   undef,
    $wp_admin               =   undef,
    $wp_admin_password      =   undef,
    $wp_admin_email         =   undef,
    ){

  file {
    "/etc/nginx/sites-available/${title}":
      ensure  => present,
      content => template('wordpress/etc/nginx/sites-available/vhost.erb'),
      notify  => Service['nginx'],
      require => Package['nginx'];

    "/etc/nginx/sites-enabled/${title}":
      ensure   => link,
      target   => "/etc/nginx/sites-available/${title}",
      notify   => Service['nginx'],
      require  => Package['nginx'];

    "/var/log/nginx/${title}":
      ensure => directory,
      path   => "/var/log/nginx/${title}",
      require => Package['nginx'],
      notify  => Service['nginx'],
      owner  => $owner,
      group  => $group;

    "/etc/logrotate.d/nginx-${title}":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      content => template('wordpress/etc/logrotate.d/logrotate.erb'),
    }
}
