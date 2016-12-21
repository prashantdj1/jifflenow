node default {

    Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin' }

    # Common modules
    include wget
    class { 'apt': always_apt_update => true, }
    apt::ppa { 'ppa:nginx/stable': }
    class { 'wordpress': }
}
