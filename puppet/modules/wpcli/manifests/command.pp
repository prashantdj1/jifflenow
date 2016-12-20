##
define wpcli::command (
    $location,
    $command
) {
    #include wpcli::cli
    include wpcli

    exec { "${location}_wpcli_${command}":
        command => "${wpcli::wpcli} ${command}",
        cwd     => $location,
        require => [ Class['wpcli::install'] ],
        onlyif  => "${wpcli::wpcli} core is-installed",
    }
}

