Phabricator CHANGELOG
=====================

1.5.0
-----
- Add centos/rhel support (Fedora not tested)

1.4.0
-----
- Try to remove both apache2 and apache2.2 packages.
- Add a simple test suite to the default Kitchen environment.
- Make sure that the storage upgrade function is run at least once before trying to configure anything.
- Always make sure that the mysql variables are configured first, and never query them from phabricator/bin/config lest they throw an error.
- Default installation domain to node[:fqdn]
- Always make sure the package list is up to date, using the apt cookbook.

1.3.0
-----
- Add the arcanist recipe, for easy setup of arcanist on developer workstations.
- Remove attributes description from README.md, see attributes/default.rb instead.

1.2.0
-----
- Configure the MySQL innodb_buffer_pool_size variable, default to 40% of total memory.

1.1.2
-----
- Update cookbook dependencies.

1.1.1
-----
- Automatically configure default 'from' e-mail address (metamta.default-address).

1.1.0
-----
- Implement logrotate.d file for /var/tmp/phd/log/daemons.log et al.

1.0.4
-----
- Configure MySQL's ft_stopword_file and ft_min_word_len full text features

1.0.3
-----
- Use https:// instead of git:// as Phabricator source

1.0.2
-----
- Fix Debian dependency version in metadata.rb

1.0.1
-----
- Use pessimistic versions for cookbook dependencies
- Only stop and disable Apache2 if it's really installed

1.0.0
-----
- Kim Tore Jensen <kimtj@met.no> - Initial release of phabricator
