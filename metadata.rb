name                'phabricator'
maintainer          'MET Norway'
maintainer_email    'kimtj@met.no'
license             'BSD'
description         'Installs and configures Phabricator'
long_description    IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version             '1.0.0'
supports            'debian', 'ubuntu'

depends             'php',      '1.4.6'
depends             'php-fpm',  '0.6.8'
depends             'nginx',    '2.7.4'
depends             'mysql',    '5.3.0'
depends             'database', '2.2.0'
