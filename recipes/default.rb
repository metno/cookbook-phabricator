#
# Cookbook Name:: phabricator
# Recipe:: default
#
# Copyright 2014, MET Norway
#
# Authors: Kim Tore Jensen <kimtj@met.no>
#

# Copy some parameters into explicit Phabricator configuration
node.default['phabricator']['config']['repository.default-local-path'] = node['phabricator']['repository_path']
node.default['phabricator']['config']['phd.user'] = node['phabricator']['user']
node.default['phabricator']['config']['storage.local-disk.path'] = node['phabricator']['file_storage_path']

# Some default Phabricator settings
node.default['phabricator']['config']['metamta.domain'] = node['phabricator']['domain']
node.default['phabricator']['config']['metamta.default-address'] = "#{node['phabricator']['user']}@#{node['phabricator']['domain']}"
node.default['phabricator']['config']['metamta.reply-handler-domain'] = node['phabricator']['domain']

# Disable nginx default site
node.default['nginx']['default_site_enabled'] = false

if node['phabricator']['ssl']
    node.default['phabricator']['config']['phabricator.base-uri'] = "https://#{node['phabricator']['domain']}/"
else
    node.default['phabricator']['config']['phabricator.base-uri'] = "http://#{node['phabricator']['domain']}/"
end

nginx_available_conf = "/etc/nginx/sites-available/#{node['phabricator']['domain']}.conf"
nginx_enabled_conf = "/etc/nginx/sites-enabled/#{node['phabricator']['domain']}.conf"

# Make sure the package list is up to date
include_recipe 'apt'

# Include needed recipes
include_recipe "nginx"
include_recipe "php"
include_recipe "php-fpm"

# Only install MySQL if it is local. ::1 is ipv6 loopback.
if ['localhost', '127.0.0.1', '::1'].include?(node['phabricator']['mysql_host'])
    include_recipe 'phabricator::mysql_server'
end

# Install required packages for Phabricator
node['phabricator']['packages'].each do |p|
    package p do
        action :upgrade
    end
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
        repository "https://github.com/phacility/#{repo}.git"
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

# Set up file storage
directory node['phabricator']['file_storage_path'] do
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
    php_options node['phabricator']['php']['options']
end

template '/etc/init/phd.conf' do
    source 'upstart/phd.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

template "/etc/logrotate.d/phd" do
    source "phd-logrotate.erb"
    user "root"
    group "root"
    mode "0644"
end

template nginx_available_conf do
    source "nginx.erb"
    user "root"
    group "www-data"
    mode "0640"
    notifies :reload, "service[nginx]"
end

link nginx_enabled_conf do
    to nginx_available_conf
    action :create
    notifies :reload, "service[nginx]"
end

# Set the MySQL credentials first of all
['host', 'port', 'user', 'pass'].each do |key|
    phabricator_config "mysql.#{key}" do
        action :set
        if key == 'pass'
            value node["phabricator"]["mysql_password"]
        else
            value node["phabricator"]["mysql_#{key}"]
        end
        path node["phabricator"]["path"]
    end
end

execute "upgrade_phabricator_databases" do
    command "true"
    if node['phabricator']['storage_upgrade_done']
        action :nothing
    else
        action :run
    end
    notifies :stop, "service[php-fpm]", :immediately
    notifies :stop, "service[phd]", :immediately
    notifies :run, "execute[run_storage_upgrade]", :immediately
    # Starting service phd intentionally omitted, due to a possible Chef bug.
    # It is started by default, though, so no harm done.
    notifies :start, "service[php-fpm]", :immediately
end

execute "run_storage_upgrade" do
    command "#{node['phabricator']['path']}/phabricator/bin/storage upgrade --force"
    user node['phabricator']['user']
    group node['phabricator']['group']
    action :nothing
end

node['phabricator']['config'].each do |key, value|
    phabricator_config key do
        action :set
        value value
        path node['phabricator']['path']
    end
end

service 'phd' do
    supports :status => true, :restart => true, :start => true, :stop => true
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
end

ruby_block 'set_storage_upgrade_done' do
    block do
        node.set['phabricator']['storage_upgrade_done'] = true
    end
end
