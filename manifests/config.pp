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

  $application_dir = $confluence::application_dir
  $plugin_startup_timeout = $confluence::plugin_startup_timeout

  file { "${application_dir}/conf/server.xml":
    content => template('confluence/server.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${application_dir}/bin/setenv.sh":
    content => template('confluence/setenv.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${application_dir}/bin/user.sh":
    content => template('confluence/user.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${application_dir}/confluence/WEB-INF/classes/confluence-init.properties":
    content => template('confluence/confluence-init.properties.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
