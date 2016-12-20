node default {

    Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin' }

    # Common modules
    include wget
    include ostype

    # Make sure it only run on Debian family
    case $::ostype {
        /(?i)(Debian|Ubuntu)/: {
            exec { 'ag_update': command => 'apt-get update || apt-get -o \'Acquire::Check-Valid-Until=false\' update', }
            $ok = true
        }
        default: {
            fail ("Unsupported OS: ${::operatingsystem}!!")
        }
    }
    if $ok {

        class { 'apt': always_apt_update => true, }
        Exec['ag_update'] -> Package <| |>
        apt::ppa { 'ppa:nginx/stable': }
        class { 'wordpress': }
