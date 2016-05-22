# = Class: confluence::params
#
# Default configuration for the confluence class.
#
# == Author
#   Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class confluence::params {
  $hostname = $::fqdn

  $md5sum = '323f8d47944d4c53fc57a5abc4ebeaf5'
  $version = '5.6.3'

  $db_url = 'jdbc:postgresql://localhost:5432/confluence'
  $db_driver = 'org.postgresql.Driver'
  $db_dialect = 'net.sf.hibernate.dialect.PostgreSQLDialect'
  $db_username = 'confluence'
  $db_password = 'secret'

  $http_address = '127.0.0.1'
  $http_port = 8090
  $ajp_address = '127.0.0.1'
  $ajp_port = 8009
  $protocols = ['http', 'ajp']

  $java_opts = '-Xms1024m -Xmx1024m -XX:MaxPermSize=256m'
  $java_package = $::operatingsystem ? {
    default => 'sun-java6-jdk',
  }
  $plugin_startup_timeout = undef

  $purge_backups_after = undef

  $package_dir = $::operatingsystem ? {
    default => '/var/cache/puppet/archives',
  }

  $install_dir = $::operatingsystem ? {
    default => '/opt',
  }

  $data_dir = $::osfamily ? {
    default => '/var/lib/confluence',
  }

  $run_dir = $::osfamily ? {
    default => '/var/run'
  }

  $service_name = 'confluence'
  $service_uid = undef
  $service_gid = undef
  $service_disabled = false
  $service_systemd = false
}
