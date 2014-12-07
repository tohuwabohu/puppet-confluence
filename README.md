#confluence

##Overview

Puppet module to install and manage Atlassian Confluence (5.6 and above).

##Usage

Just install Confluence with all default values:

```
class { 'confluence': }
```

Install a more recent version:

```
class { 'confluence':
  version => '5.6.5',
  md5sum  => '....',
}
```

Tweak the database configuration:

```
class { 'confluence':
  db_url      => 'jdbc:postgresql://localhost:5432/confluence',
  db_driver   => 'org.postgresql.Driver',
  db_dialect  => 'net.sf.hibernate.dialect.PostgreSQLDialect',
  db_username => 'confluence',
  db_password => $db_password,
}
```
(note: the database configuration can only be managed once the initial setup has been completed and the relevant
configuration file exists in the data directory).

##Limitations

The module has been tested on the following operating systems. Testing and patches for other platforms are welcome.

* Debian Linux 7.0 (Wheezy)

[![Build Status](https://travis-ci.org/tohuwabohu/puppet-confluence.png?branch=master)](https://travis-ci.org/tohuwabohu/puppet-confluence)

##Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
