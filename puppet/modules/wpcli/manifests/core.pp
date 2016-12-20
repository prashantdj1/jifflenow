## ==

define wpcli::core::download (
    $wp_version,
    $location,
) {
    require wpcli::install

    exec { "wp_download_${location}":
    command => "${wpcli::wpcli} core download --version=${wp_version}",
        cwd     => $location,
        require => [ Class['wpcli::install'] ],
        onlyif  => "test ! -d ${location}/wp-content",
    }
}

define wpcli::core::install (
    $location,
    $url,
    $siteurl        = $url,
    $sitename       = 'WordPress Site',
    $admin_user     = 'admin',
    $admin_email    = 'admin@example.com',
    $admin_password = 'password',
    $network        = false,
    $subdomains     = false
) {
    include wpcli::install
    
    if ( $network == true ) and ( $subdomains == true ) {
        $install = "multisite-install --subdomains --url='$url'"
    }
    elsif ( $network == true ) {
        $install = "multisite-install --url='$url'"
    }
    else {
        $install = "install --url='$url'"
    }

    exec { "wp_install_${location}":
        command => "${wpcli::wpcli} core $install --title='${sitename}' --admin_email='${admin_email}' --admin_name='${admin_user}' --admin_password='${admin_password}'",
        cwd     => $location,
        require => [ Class['wpcli::install'] ],
        unless  => "${wpcli::wpcli} core is-installed",
    }

    if $siteurl != $url {
        wpcli::option { "wp_siteurl_${location}":
            location => $location,
            ensure   => 'equal',
            key      => 'siteurl',
            value    => $siteurl
        }
    }
}
