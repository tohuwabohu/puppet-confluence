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
  $version = '5.3.1'
  $md5 = '7959324f3be5c9076dfaa3da59d1349b'
  $process = 'confluence'

  $http_address = '127.0.0.1'
  $http_port = 8090
  $ajp_address = '127.0.0.1'
  $ajp_port = 8009
  $protocols = ['http', 'ajp']

  $java_opts = '-Xms256m -Xmx512m -XX:MaxPermSize=256m'
  $java_package = $::operatingsystem ? {
    default => 'sun-java6-jdk',
  }
  $plugin_startup_timeout = undef

  $package_dir = $::operatingsystem ? {
    default => '/var/cache/puppet/archives',
  }

  $install_dir = $::operatingsystem ? {
    default => '/opt',
  }

  $data_dir = $::operatingsystem ? {
    default => '/data/confluence',
  }
}
