Phabricator CHANGELOG
=====================

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
