# = Class: confluence::install
#
# Installs the Confluence package and sets up all required directories.
#
# == Author
#   Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class confluence::install inherits confluence {

  $application_dir = $confluence::application_dir
  $data_dir = $confluence::data_dir
  $md5sum = $confluence::md5sum
  $version = $confluence::version
  $service_name = $confluence::service_name
  $pid_file = "${confluence::pid_directory}/${service_name}.pid"
  $working_dirs = [
    "${application_dir}/logs",
    "${application_dir}/temp",
    "${application_dir}/work"
  ]

  group { $service_name:
    ensure => present,
    gid    => $confluence::service_gid,
    system => true,
  }

  user { $service_name:
    ensure     => present,
    uid        => $confluence::service_uid,
    gid        => $service_name,
    home       => $data_dir,
    shell      => '/bin/false',
    system     => true,
    managehome => true,
  }

  archive { "atlassian-confluence-${version}":
    ensure        => present,
    digest_string => $md5sum,
    url           => "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${version}.tar.gz",
    target        => $confluence::install_dir,
    src_target    => $confluence::package_dir,
    timeout       => 600,
    require       => [
      File[$confluence::install_dir],
      File[$confluence::package_dir],
    ],
  }

  file { $application_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Archive["atlassian-confluence-${version}"]
  }

  file { $working_dirs:
    ensure  => directory,
    owner   => $service_name,
    group   => $service_name,
    mode    => '0644',
  }

  file { $confluence::params::service_script:
    ensure  => file,
    content => template('confluence/confluence.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { $pid_directory:
    ensure => directory,
    owner  => $service_name,
    group  => $service_name,
    mode   => '0755',
  }
}
