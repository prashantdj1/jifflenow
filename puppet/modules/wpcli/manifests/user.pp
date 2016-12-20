## == Define: wpcli::plugin

define wpcli::user (
    $location,
    $uname,
    $fname,
    $lname,
    $urole,
    $email,
    $upass='',
    $ensure = present,
    $networkwide = false
) {

    require wpcli::install
    $display_name = inline_template('<%= @fname[0]+@lname -%>')

    case $ensure {
        present: {

            if getvar('::ks_wp_users_list') {
                $ls_users = inline_template('<%= @ks_wp_users_list.split(",").map { |x| x.split(":")[1] }.compact %>')
                if ( $uname in $ls_users ) {
                    $command = "update ${uname} --user_email=${email}"
                } else {
                    $command = "create ${uname} ${email}"
                }
            } else {
                $command = "create ${uname} ${email}"
            }

            $run_cmd = "${wpcli::wpcli} user ${command} --role=${urole} --first_name=${fname} --last_name=${lname} --display_name=${display_name} --send-email"
            exec { "wp_user_create_${uname}":
                cwd     => $location,
                command => $run_cmd,
                require => Class['wpcli::install'],
                onlyif  => "${wpcli::wpcli} core is-installed"
            }
            #notify { "The COMMAND => ${run_cmd} <=\n": }
        }

        absent: {

            if $networkwide {
                $network = '--network'
            } else {
                $network = ''
            }
            exec { "wp_user_delete_${uname}":
                cwd     => $location,
                command => "${wpcli::wpcli} user delete ${uname} ${network} --yes",
                require => Class['wpcli::install'],
                onlyif  => [
                             "${wpcli::wpcli} core is-installed",
                             "${wpcli::wpcli} user get ${uname} --field=ID",
                           ]
            }
        }

        disable: {

            if $networkwide {
                notify { "disable is not ready yet for ${uname}\n": }
            }
        }

        default: {
            fail('Invalid ensure for wpcli::user')
        }
    }
}
