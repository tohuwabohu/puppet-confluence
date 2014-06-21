# = Class: confluence
#
# Manages a Confluence installation.
#
# == Parameters
#
# [*hostname*]
#   Sets the hostname of this Confluence instance.
#
# [*disable*]
#   Set to 'true' to disable the service.
#
# [*version*]
#   Sets the version to be installed.
#
# [*md5*]
#   Sets the MD5 checksum of the artifact.
#
# [*process*]
#   Sets the name of the process to be used to run the service.
#
# [*package_dir*]
#   Sets the directory where the downloaded package is stored.
#
# [*install_dir*]
#   Sets the directory where the application is installed.
#
# [*data_dir*]
#   Sets the application's home directory.
#
# [*jvm_xms*]
#   Sets the minimal amount of memory to be used by the Java process.
#
# [*http_address*]
#   Sets the IP address the server is listening for HTTP connections. Use '*' for any ip address.
#
# [*http_port*]
#   Sets the port the server is listening for HTTP connections.
#
# [*ajp_address*]
#   Sets the IP address the server is listening for AJP connections. Use '*' for any ip address.
#
# [*ajp_port*]
#   Sets the port the server is listening for the AJP protocol.
#
# [*protocols*]
#   An array of enabled protocols.
#
# [*java_opts*]
#   Sets the Java specific configuration values.
#
# [*java_package*]
#   Sets the Java package required to be install to run the application.
#
# == Author
#   Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class confluence (
  $hostname = params_lookup('hostname'),
  $disable = params_lookup('disable'),
  $version = params_lookup('version'),
  $md5 = params_lookup('md5'),
  $process = params_lookup('process'),

  $package_dir = params_lookup('package_dir'),
  $install_dir = params_lookup('install_dir'),
  $data_dir = params_lookup('data_dir'),

  $http_address = params_lookup('http_address'),
  $http_port = params_lookup('http_port'),
  $ajp_address = params_lookup('ajp_address'),
  $ajp_port = params_lookup('ajp_port'),
  $protocols = params_lookup('protocols'),

  $java_opts = params_lookup('java_opts'),
  $java_package = params_lookup('java_package'),
  $plugin_startup_timeout = params_lookup('plugin_startup_timeout'),
) inherits confluence::params {

  validate_string($hostname)
  $bool_disable = any2bool($disable)
  validate_string($md5)
  validate_string($process)
  validate_absolute_path($package_dir)
  validate_absolute_path($install_dir)
  validate_absolute_path($data_dir)
  validate_string($http_address)
  validate_string($ajp_address)
  validate_array($protocols)
  validate_string($java_opts)

  $manage_service_ensure = $confluence::bool_disable ? {
    true    => 'stopped',
    default => 'running',
  }

  $manage_service_enable = $confluence::bool_disable ? {
    true    => false,
    default => true,
  }

  $application_dir = $::operatingsystem ? {
    default => "${install_dir}/atlassian-confluence-${confluence::version}",
  }

  class { 'confluence::install':
    version         => $confluence::version,
    md5             => $confluence::md5,
    package_dir     => $confluence::package_dir,
    install_dir     => $confluence::install_dir,
    application_dir => $confluence::application_dir,
    data_dir        => $confluence::data_dir,
    process         => $confluence::process,
    require         => Package[$confluence::java_package],
  }

  class { 'confluence::config':
    application_dir => $confluence::application_dir,
    require         => Class['confluence::install'],
  }

  service { 'confluence':
    ensure   => $manage_service_ensure,
    enable   => $manage_service_enable,
    provider => base,
    start    => '/etc/init.d/confluence start',
    restart  => '/etc/init.d/confluence restart',
    stop     => '/etc/init.d/confluence stop',
    status   => '/etc/init.d/confluence status',
    require  => Class['confluence::install'],
  }
}
