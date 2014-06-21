# = Class: confluence::package
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
class confluence::package($version, $md5, $package_dir, $install_dir, $application_dir, $data_dir, $process) {
  validate_string($md5)
  validate_absolute_path($package_dir)
  validate_absolute_path($install_dir)
  validate_absolute_path($application_dir)
  validate_absolute_path($data_dir)
  validate_string($process)


  $pid_directory = $::operatingsystem ? {
    default => "/var/run/${process}",
  }

  $pid_file = $::operatingsystem ? {
    default => "${pid_directory}/${process}.pid",
  }

  archive { "atlassian-confluence-${version}":
    ensure        => present,
    digest_string => $md5,
    url           => "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${version}.tar.gz",
    target        => $install_dir,
    src_target    => $package_dir,
    timeout       => 600,
    require       => [File[$install_dir], File[$package_dir]],
  }

  file { $application_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Archive["atlassian-confluence-${version}"]
  }

  file { ["${application_dir}/logs",
    "${application_dir}/temp",
    "${application_dir}/work"]:
    ensure  => directory,
    owner   => $process,
    group   => $process,
    mode    => '0644',
    require => User[$process],
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
