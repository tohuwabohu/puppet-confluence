# = Class: confluence::service
#
# Configures the Confluence service.
#
# == Author
#   Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class confluence::service inherits confluence {

  $service_ensure = $confluence::service_disabled ? {
    true    => stopped,
    default => running,
  }
  $service_enable = $confluence::service_disabled ? {
    true    => false,
    default => true,
  }
  $service_script = $confluence::params::service_script

  service { $service_name:
    ensure   => $service_ensure,
    enable   => $service_enable,
    provider => base,
    start    => "${service_script} start",
    restart  => "${service_script} restart",
    stop     => "${service_script} stop",
    status   => "${service_script} status",
    require  => Package[$confluence::java_package],
  }
}
