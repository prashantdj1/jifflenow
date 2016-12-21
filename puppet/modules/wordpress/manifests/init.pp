class wordpress (
    $install_dir        =   $wordpress::params::install_dir,
    $install_url	=   $wordpress::params::install_url,
    $version            =   $wordpress::params::version,
    $db_host            =   $wordpress::params::db_host,
    $mysql_db_password  =   $wordpress::params::mysql_db_password,
    $wp_owner           =   $wordpress::params::wp_owner,
    $wp_group           =   $wordpress::params::wp_group,
    $site_hash          =   $wordpress::params::site_hash,
) inherits wordpress::params {

    include wordpress::nginx
    include php5_fpm
    include mysql::server

    create_resources('wordpress::db',$site_hash)
    create_resources('wordpress::app',$site_hash)
    create_resources('wordpress::vhost',$site_hash)

    Wordpress::Db <| |> ->
    Wordpress::App <| |> ->
    Wordpress::Vhost <| |>
    
}
