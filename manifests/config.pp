# = Class: confluence::config
#
# Configures the Confluence installation.
#
# == Author
#   Martin Meinhold <Martin.Meinhold@gmx.de>
#
# === Copyright
#
# Copyright 2014 Martin Meinhold, unless otherwise noted.
#
class confluence::config inherits confluence {

  $current_dir = $confluence::install::current_dir
  $data_dir = $confluence::data_dir
  $config_file = "${data_dir}/confluence.cfg.xml"
  $plugin_startup_timeout = $confluence::plugin_startup_timeout
  $real_db_password = pick($confluence::db_password, '""')

  file { "${current_dir}/conf/server.xml":
    content => template('confluence/server.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file_line { "${current_dir}/bin/setenv.sh":
    path => "${current_dir}/bin/setenv.sh",
    line => '. `dirname $0`/setenv2.sh',
  }

  file { "${current_dir}/bin/setenv2.sh":
    content => template('confluence/setenv2.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0555',
  }

  augeas { "${current_dir}/bin/user.sh":
    lens    => 'Shellvars.lns',
    incl    => "${current_dir}/bin/user.sh",
    changes => "set CONF_USER \"${confluence::service_name}\"",
  }

  file { "${current_dir}/confluence/WEB-INF/classes/confluence-init.properties":
    content => "confluence.home=${confluence::data_dir}\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  augeas { $config_file:
    lens    => 'Xml.lns',
    incl    => $config_file,
    changes => [
      "set confluence-configuration/properties/property[#attribute/name = 'hibernate.connection.url']/#text ${confluence::db_url}",
      "set confluence-configuration/properties/property[#attribute/name = 'hibernate.connection.driver_class']/#text ${confluence::db_driver}",
      "set confluence-configuration/properties/property[#attribute/name = 'hibernate.connection.username']/#text ${confluence::db_username}",
      "set confluence-configuration/properties/property[#attribute/name = 'hibernate.connection.password']/#text ${real_db_password}",
      "set confluence-configuration/properties/property[#attribute/name = 'hibernate.dialect']/#text ${confluence::db_dialect}",
    ],
    # Only update the configuration when the database configuration actually exists. It is created as part of the
    # initial setup and hence doesn't existing unless the installation is completed.
    onlyif => 'match confluence-configuration/properties/property[#attribute/name = \'hibernate.connection.url\'] size == 1',
  }
}
