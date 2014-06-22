# = Class: confluence
#
# Manages a Confluence installation.
#
# == Parameters
#
# [*hostname*]
#   Sets the hostname of this Confluence instance.
#
# [*version*]
#   Sets the version to be installed.
#
# [*md5*]
#   Sets the MD5 checksum of the artifact.
#
# [*service_disabled*]
#   Set to `true` to disable the service.
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
  $hostname               = params_lookup('hostname'),
  $version                = params_lookup('version'),

  $service_name           = params_lookup('service_name'),
  $service_uid            = params_lookup('service_uid'),
  $service_gid            = params_lookup('service_gid'),
  $service_disabled       = params_lookup('service_disabled'),

  $md5sum                 = params_lookup('md5sum'),
  $package_dir            = params_lookup('package_dir'),
  $install_dir            = params_lookup('install_dir'),
  $data_dir               = params_lookup('data_dir'),

  $http_address           = params_lookup('http_address'),
  $http_port              = params_lookup('http_port'),
  $ajp_address            = params_lookup('ajp_address'),
  $ajp_port               = params_lookup('ajp_port'),
  $protocols              = params_lookup('protocols'),

  $java_opts              = params_lookup('java_opts'),
  $java_package           = params_lookup('java_package'),
  $plugin_startup_timeout = params_lookup('plugin_startup_timeout'),
) inherits confluence::params {

  if empty($hostname) {
    fail('Class[Confluence]: hostname must not be empty')
  }
  if empty($version) {
    fail('Class[Confluence]: version must not be empty')
  }
  if empty($service_name) {
    fail('Class[Confluence]: service_name must not be empty')
  }
  if !empty($service_uid) and !is_integer($service_uid) {
    fail("Class[Confluence]: service_uid must be an interger, got '${service_uid}'")
  }
  if !empty($service_gid) and !is_integer($service_gid) {
    fail("Class[Confluence]: service_gid must be an interger, got '${service_gid}'")
  }
  if !is_bool($service_disabled) {
    fail("Class[Confluence]: service_disabled must be either true or false, got '${$service_disabled}'")
  }
  validate_absolute_path($package_dir)
  validate_absolute_path($install_dir)
  validate_absolute_path($data_dir)
  validate_string($http_address)
  validate_string($ajp_address)
  validate_array($protocols)
  if empty($java_opts) {
    fail('Class[Confluence]: java_opts must not be empty')
  }

  $manage_service_ensure = $service_disabled ? {
    true    => 'stopped',
    default => 'running',
  }

  $manage_service_enable = $service_disabled ? {
    true    => false,
    default => true,
  }

  $application_dir = "${install_dir}/atlassian-confluence-${confluence::version}"
  $pid_directory = $::operatingsystem ? {
    default => "/var/run/${service_name}",
  }

  class { 'confluence::install': } ->
  class { 'confluence::config': } ~>
  service { $service_name:
    ensure   => $manage_service_ensure,
    enable   => $manage_service_enable,
    provider => base,
    start    => '/etc/init.d/confluence start',
    restart  => '/etc/init.d/confluence restart',
    stop     => '/etc/init.d/confluence stop',
    status   => '/etc/init.d/confluence status',
    require  => Package[$confluence::java_package],
  }
}
