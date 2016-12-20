## == Define: wpcli::plugin

define wpcli::plugin (
    $location,
    $ensure = enabled,
    $networkwide = false
) {

    require wpcli::install

    case $ensure {
        enabled: {
            $command = "activate ${title}"

            exec { "wp_install_plugin_${title}":
                cwd     => $location,
                command => "${wpcli::wpcli} plugin install ${title}",
                unless  => "${wpcli::wpcli} plugin is-installed $title",
                before  => Wpcli::Command["${location}_plugin_${title}_${ensure}"],
                require => Class["wpcli::install"],
                onlyif  => "${wpcli::wpcli} core is-installed"
            }
        }
        disabled: {
            $command = "deactivate $title"
        }
        default: {
            fail("Invalid ensure for wpcli::plugin")
        }
    }

    if $networkwide {
        $args = "plugin ${command} --network"
    }
    else {
        $args = "plugin ${command}"
    }

    wpcli::command { "${location}_plugin_${title}_${ensure}":
        location => $location,
        command => $args
    }
}

