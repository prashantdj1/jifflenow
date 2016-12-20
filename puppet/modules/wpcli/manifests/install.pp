##
class wpcli::install {
   
    require wpcli

    ## Download WP-CLI
    $wpcli_latest = "php-wpcli_${::wpcli::version}_all.deb"
    wget::fetch { 'fetch_wpcli':
        #source       => "${hr_app_url}/wordpress/${wpcli_latest}",
        source       => "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/deb/${wpcli_latest}",
        destination  => "${hr_app_tmp}/${wpcli_latest}",
        cache_dir    => '/var/cache/wget',
        timeout      => '0',
        verbose      => false,
        before       => Common::Defined::Local_install['php-wpcli'],
    } ->

    ## local-install WP-CLI
    common::defined::local_install { 'php-wpcli':
        src          => "${hr_app_tmp}/${wpcli_latest}",
        require      => Package[ 'php5-cli', 'mysql_client' ];
    }
}

