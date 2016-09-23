#
# Attribute file for Phabricator
#

# Where to install Phabricator, Arcanist and libphutil
default['phabricator']['path'] = '/opt/phabricator'

# Which user and group will Phabricator run as?
default['phabricator']['user'] = 'phabricator'
default['phabricator']['group'] = 'www-data'

# FQDN that will host Phabricator
default['phabricator']['domain'] = node['fqdn']

# Git revisions to check out, use 'master' for bleeding edge
default['phabricator']['revision']['phabricator'] = 'master'
default['phabricator']['revision']['arcanist'] = 'master'
default['phabricator']['revision']['libphutil'] = 'master'

# Where to put source code repositories, both hosted and external
default['phabricator']['repository_path'] = '/var/repo'

# Set up file storage and support for large files.
# Files larger than `storage.mysql-engine.max-size` will be stored in this directory.
default['phabricator']['file_storage_path'] = "#{node['phabricator']['path']}/filestore"

# Set 'ssl' to true if you want to use SSL, and provide the paths.
default['phabricator']['ssl'] = false
default['phabricator']['ssl_cert_path'] = ''
default['phabricator']['ssl_key_path'] = ''
default['phabricator']['ssl_protocols'] = ['TLSv1', 'TLSv1.1', 'TLSv1.2']

# MySQL credentials
default['phabricator']['mysql_host'] = 'localhost'
default['phabricator']['mysql_port'] = '3306'
default['phabricator']['mysql_user'] = 'phabricator'
default['phabricator']['mysql_password'] = 'changeme'

# MySQL version
default['mysql']['version'] = '5.5'

# PHP settings
default['phabricator']['php']['options'] = {
    'php_admin_value[date.timezone]' => 'UTC',
    'php_admin_value[post_max_size]' => '32M',
    'php_admin_value[upload_max_filesize]' => '32M',
    'php_admin_value[memory_limit]' => '128M',
    'php_admin_flag[apc.stat]' => 'off',
    'php_admin_flag[apc.write_lock]' => 'on',
    'php_admin_flag[apc.slam_defense]' => 'off',
    'php_admin_flag[log_errors]' => 'on',
}

# Initial storage upgrade has been done
default['phabricator']['storage_upgrade_done'] = false

# MySQL option innodb_buffer_pool_size
mem = node['memory']['total'].split("kB")[0].to_i*1024*0.4
default['phabricator']['innodb_buffer_pool_size'] = mem.to_int

# MySQL options
default['phabricator']['mysql']['max_allowed_packet'] = 32*1024*1024
default['phabricator']['mysql']['max_connections'] = 100000

# Various config settings, feel free to expand with your own stuff.
default['phabricator']['config'] = {
    'pygments.enabled' => 'true',
}

# Package dependencies
default['phabricator']['packages'] = [
    'curl', 'git', 'php5', 'php5-ldap', 'php5-mysql', 'php5-gd', 'php5-dev', 'php5-curl',
    'php-apc', 'php5-cli', 'php5-json', 'python-pygments',
]

# Where to put Arcanist when using the arcanist recipe
default['phabricator']['arcanist']['destination'] = '/usr/local/lib/phabricator'
default['phabricator']['arcanist']['bin'] = '/usr/local/bin/arc'
