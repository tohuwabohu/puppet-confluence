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
    true    => 'stopped',
    default => 'running',
  }
  $service_enable = $confluence::service_disabled ? {
    true    => false,
    default => true,
  }

  service { $service_name:
    ensure   => $service_ensure,
    enable   => $service_enable,
    provider => base,
    start    => '/etc/init.d/confluence start',
    restart  => '/etc/init.d/confluence restart',
    stop     => '/etc/init.d/confluence stop',
    status   => '/etc/init.d/confluence status',
    require  => Package[$confluence::java_package],
  }
}
