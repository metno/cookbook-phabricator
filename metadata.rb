name                'phabricator'
maintainer          'MET Norway'
maintainer_email    'kimtj@met.no'
license             'GNU GPL 2'
description         'Installs and configures Phabricator'
long_description    ''
version             '3.2.3'

supports            'ubuntu', '= 12.04'
supports            'ubuntu', '= 14.04'

depends             'apt',      '~> 2.6'
depends             'php',      '~> 1.5'
depends             'php-fpm',  '~> 0.7'
depends             'nginx',    '~> 2.7'
depends             'mysql',    '~> 6.0'
depends             'database', '~> 3.1'
