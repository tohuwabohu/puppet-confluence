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
  $hostname               = $confluence::params::hostname,
  $version                = $confluence::params::version,

  $service_name           = $confluence::params::service_name,
  $service_uid            = $confluence::params::service_uid,
  $service_gid            = $confluence::params::service_gid,
  $service_disabled       = $confluence::params::service_disabled,

  $md5sum                 = $confluence::params::md5sum,
  $package_dir            = $confluence::params::package_dir,
  $install_dir            = $confluence::params::install_dir,
  $data_dir               = $confluence::params::data_dir,

  $http_address           = $confluence::params::http_address,
  $http_port              = $confluence::params::http_port,
  $ajp_address            = $confluence::params::ajp_address,
  $ajp_port               = $confluence::params::ajp_port,
  $protocols              = $confluence::params::protocols,

  $java_opts              = $confluence::params::java_opts,
  $java_package           = $confluence::params::java_package,
  $plugin_startup_timeout = $confluence::params::plugin_startup_timeout,

  $purge_backups_after    = $confluence::params::purge_backups_after
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
    fail("Class[Confluence]: service_uid must be an integer, got '${service_uid}'")
  }
  if !empty($service_gid) and !is_integer($service_gid) {
    fail("Class[Confluence]: service_gid must be an integer, got '${service_gid}'")
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
  if !empty($purge_backups_after) and !is_integer($purge_backups_after) {
    fail("Class[Confluence]: purge_backups_after must be an integer, got '${purge_backups_after}'")
  }

  class { 'confluence::install': } ->
  class { 'confluence::config': } ~>
  class { 'confluence::service': }
}
