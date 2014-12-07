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
  $plugin_startup_timeout = $confluence::plugin_startup_timeout

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
}
