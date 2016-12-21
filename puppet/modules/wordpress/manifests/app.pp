
define wordpress::app (
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
    $port	            =   undef,
    ){

    ###The basic data-type validation 
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
    exec { "Download_wordpress_${title}":
    command => "wget ${install_url}/wordpress-${version}.tar.gz",
    creates => "${wp_root}/wordpress-${version}.tar.gz",
    require => File[$install_dir],
    user    => $wp_owner,
    group   => $wp_group,
  }
  -> exec { "Extract_wordpress_${title}":
    command => "cd $wp_root && tar zxvf ${wp_root}/wordpress-${version}.tar.gz ",
    creates => "${install_dir}/index.php",
    user    => $wp_owner,
    group   => $wp_group,
  }
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
        require => Exec["Extract_wordpress_${title}"],
    }

    concat { "${install_dir}/${title}/wp-config.php":
        mode    => '0400',
        require => Exec["Extract_wordpress_${title}"],
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
        require => Exec["Extract_wordpress_${title}"],
    }

}
