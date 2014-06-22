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

  $version = $confluence::version
  $archive_name = "atlassian-confluence-${version}"
  $archive_md5sum = $confluence::md5sum
  $archive_url = "http://www.atlassian.com/software/confluence/downloads/binary/${archive_name}.tar.gz"

  $application_dir = "${confluence::install_dir}/${archive_name}"
  $current_dir = "${confluence::install_dir}/atlassian-confluence-current"
  $data_dir = $confluence::data_dir
  $backup_dir = "${data_dir}/backups"

  $service_name = $confluence::service_name
  $pid_directory = "${confluence::params::run_dir}/${service_name}"
  $pid_file = "${pid_directory}/${service_name}.pid"
  $working_dirs = [
    "${application_dir}/logs",
    "${application_dir}/temp",
    "${application_dir}/work"
  ]
  $cron_ensure = empty($confluence::purge_backups_after) ? {
    true    => absent,
    default => file,
  }

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

  file { $data_dir:
    ensure  => directory,
    owner   => $service_name,
    group   => $service_name,
    mode    => '0644',
    require => User[$service_name],
  }

  archive { $archive_name:
    ensure        => present,
    digest_string => $archive_md5sum,
    url           => $archive_url,
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
    require => Archive[$archive_name]
  }

  file { $current_dir:
    ensure => link,
    target => $application_dir,
    notify => Class['confluence::service'],
  }

  file { $working_dirs:
    ensure => directory,
    owner  => $service_name,
    group  => $service_name,
    mode   => '0644',
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
    mode   => '0644',
  }

  file { $backup_dir:
    ensure => directory,
    owner  => $service_name,
    group  => $service_name,
    mode   => '0644',
  }

  file { '/etc/cron.daily/purge-old-confluence-backups':
    ensure  => $cron_ensure,
    content => "#!/bin/bash\n/usr/bin/find ${backup_dir}/ -name \"*.zip\" -type f -mtime +${confluence::purge_backups_after} -delete",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File[$backup_dir],
  }
}
