#
# Cookbook Name:: phabricator
# Recipe:: default
#
# Copyright 2014, MET Norway
#
# Authors: Kim Tore Jensen <kimtj@met.no>
#

# Copy some parameters into explicit Phabricator configuration
node.set['phabricator']['config']['mysql.host'] = node['phabricator']['mysql_host']
node.set['phabricator']['config']['mysql.port'] = node['phabricator']['mysql_port']
node.set['phabricator']['config']['mysql.user'] = node['phabricator']['mysql_user']
node.set['phabricator']['config']['mysql.pass'] = node['phabricator']['mysql_password']
node.set['phabricator']['config']['repository.default-local-path'] = node['phabricator']['repository_path']
node.set['phabricator']['config']['phd.user'] = node['phabricator']['user']

node.default['phabricator']['config']['metamta.domain'] = node['phabricator']['domain']
node.default['phabricator']['config']['metamta.reply-handler-domain'] = node['phabricator']['domain']

node.default['nginx']['default_site_enabled'] = false

node.default['php']['directives']['date.timezone'] = 'UTC'
node.default['php']['directives']['apc.stat'] = 0

if node['phabricator']['ssl']
    node.default['phabricator']['config']['phabricator.base-uri'] = "https://#{node['phabricator']['domain']}/"
else
    node.default['phabricator']['config']['phabricator.base-uri'] = "http://#{node['phabricator']['domain']}/"
end

nginx_available_conf = "/etc/nginx/sites-available/#{node['phabricator']['domain']}.conf" 
nginx_enabled_conf = "/etc/nginx/sites-enabled/#{node['phabricator']['domain']}.conf" 

mysql_connection = {
    :host => 'localhost',
    :user => 'root',
    :password => node['mysql']['server_root_password']
}

node['phabricator']['packages'].each do |p|
    package p do
        action :upgrade
    end
end

# In case Apache2 is automatically installed, remove it.
# This might happen on Ubuntu systems!
package 'apache2' do
    action :remove
    notifies :disable, 'service[apache2]', :immediately
    notifies :stop, 'service[apache2]', :immediately
end

service 'apache2' do
    action :nothing
end

include_recipe "php"
include_recipe "php-fpm"
include_recipe "nginx"
include_recipe "mysql::server"
include_recipe "database::mysql"

# Unfortunately, the PHP-FPM recipe does not have any concept of how to
# actually configure the PHP-FPM configuration file itself [sic] - it needs to
# be linked to manually.
#
# FIXME: this should definately be fixed in the php cookbook.
link "/etc/php5/fpm/php.ini" do
    to "../cli/php.ini"
    action :create
    notifies :restart, "service[php-fpm]"
end

# Phabricator is really picky about this one:
# By default MySQL will silently ignore some types of errors, which can cause
# data loss and raise security concerns. Enabling strict mode makes MySQL raise
# an explicit error instead, and prevents this entire class of problems from
# doing any damage.
template "/etc/mysql/conf.d/phabricator_sql_mode.cnf" do
    source "phabricator_sql_mode.cnf.erb"
    mode "0644"
    owner "root"
    group "root"
    notifies :restart, "service[mysql]"
end

group node['phabricator']['group'] do
    action :create
end

user node['phabricator']['user'] do
    system true
    group node['phabricator']['group']
    home node['phabricator']['path']
    shell "/bin/bash"
    action :create
end

directory node['phabricator']['path'] do
    action :create
    user node['phabricator']['user']
    group node['phabricator']['group']
    mode "0750"
end

%w{ phabricator libphutil arcanist }.each do |repo|
    git "#{node['phabricator']['path']}/#{repo}" do
        user node['phabricator']['user']
        group node['phabricator']['group']
        repository "git://github.com/facebook/#{repo}.git"
        revision node['phabricator']['revision'][repo]
        action :sync
        notifies :run, "execute[upgrade_phabricator_databases]"
    end
end

directory node['phabricator']['repository_path'] do
    action :create
    user node['phabricator']['user']
    group node['phabricator']['group']
    mode "0750"
end

php_fpm_pool "phabricator" do
    process_manager "dynamic"
    max_requests 200
    user node['phabricator']['user']
    group node['phabricator']['group']
    listen_owner node['phabricator']['user']
    listen_group node['phabricator']['group']
    listen_mode "0660"
    php_options 'php_admin_flag[log_errors]' => 'on', 'php_admin_value[memory_limit]' => node['phabricator']['php_memory_limit']
end

template "/etc/init.d/phd" do
    source "phd.erb"
    user "root"
    group "root"
    mode "0755"
    variables :vars => {
        :node => node
    }
    notifies :restart, "service[phd]"
end

template nginx_available_conf do
    source "nginx.erb"
    user "root"
    group "www-data"
    mode "0640"
    variables :vars => {
        :node => node
    }
    notifies :restart, "service[nginx]"
end

link nginx_enabled_conf do
    to nginx_available_conf
    action :create
    notifies :restart, "service[nginx]"
end

mysql_database_user node['phabricator']['mysql_user'] do
    connection mysql_connection
    password node['phabricator']['mysql_password']
    database_name 'phabricator_%'
    privileges [:all]
    action [:create, :grant]
end

node['phabricator']['config'].each do |key, value|
    phabricator_config key do
        action :set
        value value
        path node['phabricator']['path']
    end
end

execute "upgrade_phabricator_databases" do
    command "true"
    action :nothing
    notifies :stop, "service[php-fpm]", :immediately
    notifies :stop, "service[phd]", :immediately
    notifies :run, "execute[run_storage_upgrade]", :immediately
    notifies :start, "service[phd]", :immediately
    notifies :start, "service[php-fpm]", :immediately
end

execute "run_storage_upgrade" do
    command "#{node['phabricator']['path']}/phabricator/bin/storage upgrade --force"
    action :nothing
end

service "phd" do
    action :enable
end

service "mysql" do
    action [:enable, :start]
end
