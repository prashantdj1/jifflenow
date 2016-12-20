class wordpress::files(){

    file { "/root/.ssh/id_rsa":
        source  => 'puppet:///modules/wordpress/id_rsa',
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
    }

    file { "/root/.ssh/config":
        source  => 'puppet:///modules/wordpress/config',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

}
