class wordpress (
    $install_dir        =   $wordpress::params::install_dir,
    $version            =   $wordpress::params::version,
    $db_host            =   $wordpress::params::db_host,
    $mysql_db_password  =   $wordpress::params::mysql_db_password,
    $wp_owner           =   $wordpress::params::wp_owner,
    $wp_group           =   $wordpress::params::wp_group,
    $client_net         =   $wordpress::params::client_net,
    $client_hash        =   $wordpress::params::client_hash,
) inherits wordpress::params {

    include wordpress::files
    include wordpress::nginx
    include php5_fpm
    include mysql::server

    create_resources('wordpress::db',$client_hash)
    create_resources('wordpress::app',$client_hash)
    create_resources('wordpress::vhost',$client_hash)

    Wordpress::Db <| |> ->
    Wordpress::App <| |> ->
    Wordpress::Vhost <| |>
    
}
