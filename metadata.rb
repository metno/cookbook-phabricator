name                'phabricator'
maintainer          'MET Norway'
maintainer_email    'kimtj@met.no'
license             'GNU GPL 2'
description         'Installs and configures Phabricator'
long_description    IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version             '1.0.2'

supports            'debian', '~> 7.0'
supports            'ubuntu', '= 12.04'

depends             'php',      '~> 1.4'
depends             'php-fpm',  '~> 0.6'
depends             'nginx',    '~> 2.7'
depends             'mysql',    '~> 5.3'
depends             'database', '~> 2.2'
