## ==

define wordpress::app (
    $install_dir            =   $wordpress::params::install_dir,
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
    ){

    ## The basic data-type validation 
    validate_string($install_dir,$install_url,$version,$db_name,$db_host,$db_user,$db_password)
    validate_string($wp_owner,$wp_group, $wp_lang, $wp_plugin_dir,$wp_additional_config,$wp_table_prefix,$wp_proxy_host,$wp_proxy_port,$wp_site_domain)
    validate_absolute_path($install_dir)
    }

    ## Resource defaults
    File {
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }

    $wp_root    = "${install_dir}/${title}"
    $wp_web_dir = [
                    "${wp_root}/wp-content",
                    "${wp_root}/wp-content/plugins",
                    "${wp_root}/wp-content/themes",
                    "${wp_root}/wp-content/upgrade",
                    "${wp_root}/wp-content/uploads",
                  ]

    ## Download and extract WordPress
    file { $wp_root:
        ensure  => directory,
        mode    => '0755',
    } ->
    wpcli::core::download { "download_wordpress_${title}":
        wp_version    => $version,
        location      => $wp_root,
    } ->
    file { $wp_web_dir:
        ensure => directory,
        owner  => 'www-data',
        mode   => '0755',
    } ->

    file { "${wp_root}/wp-admin/includes/file.php":
        ensure => file,
        owner  => 'www-data',
    } ->

    ## Configure wordpress
    #
    # Template uses no variables
    file { "wp-keysalts_php_${title}":
        path    => "${install_dir}/${title}/wp-keysalts.php",
        ensure  => present,
        content => template('wordpress/wp-keysalts.php.erb'),
        replace => false,
        require => Wpcli::Core::Download["download_wordpress_${title}"],
        #require => Exec["Extract_wordpress_${title}"],
    }

    concat { "${install_dir}/${title}/wp-config.php":
        mode    => '0400',
        require => Wpcli::Core::Download["download_wordpress_${title}"],
        notify  => Class['::fooacl'],
        #require => Exec["Extract_wordpress_${title}"],
    }

    concat::fragment { "${install_dir}/${title}/wp-config.php keysalts":
        target  => "${install_dir}/${title}/wp-config.php",
        source  => "${install_dir}/${title}/wp-keysalts.php",
        order   => '10',
        require => File["wp-keysalts_php_${title}"],
    }

    #Template uses: $db_name, $db_user, $db_password, $db_host, $wp_proxy, 
    #$wp_proxy_host, $wp_proxy_port, $wp_multisite, $wp_site_domain
    concat::fragment { "${install_dir}/${title}/wp-config.php body":
        target  => "${install_dir}/${title}/wp-config.php",
        content => template('wordpress/wp-config.php.erb'),
        order   => '20',
    }

    file { "${install_dir}/${title}/index.php":
        ensure  => present,
        content => template('wordpress/index.php.erb'),
        require => Wpcli::Core::Download["download_wordpress_${title}"],
        #require => Exec["Extract_wordpress_${title}"],
    }

    fooacl::conf { "allow_${wp_owner}_wp_config_${title}":
        target      => "${wp_root}/wp-config.php",
        permissions => [ "user:${wp_owner}:r" ],
        require     => Concat[ "${install_dir}/${title}/wp-config.php" ],
    }

    ## WP-CLI core install
    wpcli::core::install { "install_wordpress_${title}":
        url             => "https://${wp_site_domain}",
        sitename        => $wp_site_title,
        admin_user      => $wp_admin,
        admin_password  => $wp_admin_password,
        admin_email     => $wp_admin_email,
        location        => $wp_root,
        network         => $wp_multisite,
        require         => Concat[ "${install_dir}/${title}/wp-config.php" ],
    }
}
