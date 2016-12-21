class wordpress::nginx {

    $nginx_packages = [
        'nginx'
    ]

    package { $nginx_packages:
        ensure => 'latest'
    }

    # 'restart' could be ignored here, but it's important that
    # nginx tests the config before it restarts
    service {
        'nginx':
            ensure  => 'running',
            restart => '/usr/sbin/nginx -t && service nginx restart',
            enable  => true,
            require => Package['nginx'];
    }

    file {
        '/etc/nginx/nginx.conf':
            ensure  => present,
            content => template('wordpress/etc/nginx/nginx.conf.erb'),
            notify  => Service['nginx'],
            require => Package['nginx'],
            owner   => 'www-data',
            group   => 'root';

        '/etc/nginx/sites-available':
            ensure  => directory,
            require => Package['nginx'],
            purge   => true,
            force   => true,
            recurse => true,
            owner   => 'root',
            group   => 'root';

        '/etc/nginx/sites-enabled/':
            ensure  => directory,
            require => Package['nginx'],
            purge   => true,
            force   => true,
            recurse => true,
            owner   => 'root',
            group   => 'root';

        '/etc/nginx/fastcgi_params':
            ensure  => present,
            content => template('wordpress/etc/nginx/fastcgi_params.erb'),
            notify  => Service['nginx'],
            require => Package['nginx'],
            owner   => 'www-data',
            group   => 'root';

        '/etc/nginx/conf.d/gzip.conf':
            ensure  => present,
            content => template('wordpress/etc/nginx/conf.d/gzip.conf.erb'),
            notify  => Service['nginx'],
            require => Package['nginx'],
            owner   => 'www-data',
            group   => 'root';

        '/etc/nginx/global':
            ensure => 'directory',
            require => Package['nginx'],
            owner  => 'www-data',
            group  => 'root';
    
        '/etc/nginx/global/restrictions.conf':
            ensure  => present,
            content => template('wordpress/etc/nginx/global/restrictions.conf.erb'),
            notify  => Service['nginx'],
            require => Package['nginx'],
            owner   => 'www-data',
            group   => 'root';

        '/etc/nginx/ssl':
            ensure => 'directory',
            require => Package['nginx'],
            owner  => 'root',
            group  => 'root';
    }

    file {
        "/etc/nginx/ssl/test.crt":
            ensure  => present,
            mode    => '0644',
            source  => "puppet:///modules/wordpress/etc/nginx/ssl/test.crt",
            notify  => Service['nginx'],
            require => Package['nginx'];

        "/etc/nginx/ssl/test.key":
            ensure  => present,
            mode    => '0600',
            owner   => 'root',
            group   => 'root',
            source  => "puppet:///modules/wordpress/etc/nginx/ssl/test.key";

        [ "/etc/nginx/sites-available/load-balancer.conf", "/etc/nginx/sites-enabled/load-balancer.conf" ]:
            ensure  => present,
            mode    => '0644',
            content => template('wordpress/etc/nginx/sites-available/load-balancer.conf'),
            notify  => Service['nginx'],
            require => Package['nginx'];

   }
}
