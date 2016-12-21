define wordpress::db(
    $install_dir            =   $wordpress::params::install_dir,
    $install_url            =   $wordpress::params::install_url,
    $version                =   $wordpress::params::version,
    $db_host                =   $wordpress::params::db_host,
    $mysql_db_password      =   $wordpress::params::mysql_db_password,
    $wp_owner               =   $wordpress::params::wp_owner,
    $wp_group               =   $wordpress::params::wp_group,
    $db_password            =   undef,
    $wp_lang                =   undef,
    $wp_plugin_dir          =   undef,
    $wp_additional_config   =   undef,
    $wp_table_prefix        =   undef,
    $wp_proxy_host          =   undef,
    $wp_proxy_port          =   undef,
    $wp_site_domain         =   undef,
    $wp_site_name           =   undef,
    $wp_site_title          =   undef,
    $wp_admin               =   undef,
    $wp_admin_email         =   undef,
    $wp_admin_password      =   undef,
    $port                   =   undef,
    ) {
    exec { "create-${title}-db":
      command => "/usr/bin/mysql -uroot -p${mysql_db_password}  -h${db_host} -e \"CREATE DATABASE IF NOT EXISTS ${title}; GRANT SELECT, CREATE, INSERT, UPDATE, DELETE ON ${title}.* TO ${title}@'${client_net}.%' IDENTIFIED BY '${db_password}';\"",
      unless  => "/usr/bin/mysql -u${title} -p${db_password} -h${db_host} ${title}",
    }
  }
