#
# Cookbook Name:: phabricator
# Recipe:: mysql_server
#
# Copyright 2014, MET Norway
#
# Authors: Kim Tore Jensen <kimtj@met.no>
#          Andrew Mulholland <andrew@bash.sh>
#
# Installs and configures MySQL for Phabricator

# Make sure the package list is up to date
include_recipe 'apt'

# Make sure MySQL has a default root password
if not node.run_state.has_key?('mysql_root_password') then
    Chef::Log.warn("****** Your MySQL password is set to an insecure default value, please modify it using `node.run_state['mysql_root_password']`! ******")
    node.run_state['mysql_root_password'] = 'pleaserootmydatabase'
end

# Set up a MySQL server
mysql_service 'default' do
    initial_root_password node.run_state['mysql_root_password']
    version node['mysql']['version']
    action [:create, :start]
end

# Define MySQL connection credentials
mysql_connection = {
    :host => '127.0.0.1',
    :port => 3306,
    :user => 'root',
    :password => node.run_state['mysql_root_password']
}

# Include needed recipes
include_recipe "database::mysql"

# Phabricator needs special MySQL configuration.
mysql_config 'phabricator' do
    source 'phabricator.cnf.erb'
    instance 'default'
    action :create
    notifies :restart, 'mysql_service[default]', :immediately
end

mysql_database_user node['phabricator']['mysql_user'] do
    connection mysql_connection
    password node['phabricator']['mysql_password']
    database_name 'phabricator_%'
    privileges [:all]
    action [:create, :grant]
end
