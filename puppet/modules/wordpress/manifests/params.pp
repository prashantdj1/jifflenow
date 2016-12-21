 class wordpress::params (
    $install_dir          = undef,
    $install_url	  = undef,
    $version              = undef,
    $db_host              = undef,
    $mysql_db_password    = undef,
    $client_net           = undef,
    $wp_owner             = undef,
    $wp_group             = undef,
    $site_hash          = hiera_hash('wordpress::site_hash', {}),
  ){}
