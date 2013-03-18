
#
# Install nginx and setup basic vhost for symfony2
#
class setup_nginx {

	include nginx
	
	file { "nginx_symfony2.conf":
		owner  => root,
		group  => root,
		mode   => 664,
		source => "/vagrant/conf/nginx/symfony2.conf",
		path   => "/etc/nginx/sites-available/symfony2.conf",
		require => Package['nginx'],
	}

	file { "/etc/nginx/sites-enabled/symfony2.conf":
		owner  => root,
		group  => root,
		mode   => 664,
		ensure => link,
		target => "/etc/nginx/sites-available/symfony2.conf",
		require => Package['nginx'],
		notify => Service['nginx'],
	}
}

#
# Install php and some required modules
#
class setup_php_centos {

	require repo_epel
	
	include php::fpm

    php::module { [
        'gd', 'mcrypt', 'pecl-memcached', 'mysql',
        'tidy', 'pecl-xhprof',
        ]:
        notify => Class['php::fpm::service'],
    }

	php::module { [ 'pecl-xdebug', ]:
        notify  => Class['php::fpm::service'],
		source => "/vagrant/conf/php/xdebug.ini",
    }
	
	php::module { [ 'suhosin', ]:
        notify  => Class['php::fpm::service'],
    }
	
	php::module { [ 'pdo' ]:
        notify  => Class['php::fpm::service'],
    }

    file { "/etc/php.d/custom.ini":
        owner  => root,
        group  => root,
        mode   => 664,
        source => "/vagrant/conf/php/custom.ini",
        notify => Class['php::fpm::service'],
    }

    file { "/etc/php-fpm.d/symfony2.conf":
        owner  => root,
        group  => root,
        mode   => 664,
        source => "/vagrant/conf/php/php-fpm/php-fpm.conf",
        notify => Class['php::fpm::service'],
    }
}


class {'vim':}

class {'repo_epel':}

iptables::allow { 'tcp/80': port => '80', protocol => 'tcp' }

include mysql::server

mysql::db { "symfony2": source => "/vagrant/conf/mysql/symfony2.sql" }

mysql::grant { "Symfony2_User": user => "symfony2", password => "password", db => "symfony2" }

class { 'memcached':
	max_memory => 65536
}

include setup_nginx
include setup_php_centos
