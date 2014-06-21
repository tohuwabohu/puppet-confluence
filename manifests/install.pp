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
  $md5 = $confluence::md5
  $process = $confluence::process
  $version = $confluence::version
  $pid_file = "${confluence::pid_directory}/${process}.pid"
  $working_dirs = [
    "${application_dir}/logs",
    "${application_dir}/temp",
    "${application_dir}/work"
  ]

  archive { "atlassian-confluence-${version}":
    ensure        => present,
    digest_string => $md5,
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
    owner   => $process,
    group   => $process,
    mode    => '0644',
  }

  file { '/etc/init.d/confluence':
    ensure  => file,
    content => template('confluence/confluence.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { $pid_directory:
    ensure => directory,
    owner  => $process,
    group  => $process,
    mode   => '0755',
  }
}
