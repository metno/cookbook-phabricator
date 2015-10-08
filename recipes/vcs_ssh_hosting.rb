#
# Cookbook Name:: phabricator
# Recipe:: vcs_ssh_hosting
#
# Copyright 2014, MET Norway
#
# Authors: Kim Tore Jensen <kimtj@met.no>,
#          Andrew Mulholland <andrew@bash.sh>
#
# Sets up phabricator for hosting repositories over SSH

# To prevent the `node['phabricator']['vcs_ssh']['user']` (i.e. git ) user from being locked, a
# password needs to be provided with account creation. Using OpenSSLCookbook's RandomPassword
# function to generate a secure password.
unless node['phabricator']['vcs_ssh']['password']
    Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)
    require 'digest/sha2'
    password = Digest::SHA512.hexdigest(random_password(length: 50))
    node.set['phabricator']['vcs_ssh']['password'] = password
end

user node['phabricator']['vcs_ssh']['user'] do
    comment 'VCS User'
    home node['phabricator']['vcs_ssh']['home_dir']
    shell '/bin/sh'
    system true
    # This password is never used!
    password node['phabricator']['vcs_ssh']['password']
    action [:create, :unlock]
end

directory node['phabricator']['vcs_ssh']['home_dir'] do
    action :create
    owner node['phabricator']['vcs_ssh']['user']
    mode '0755'
end

directory '/etc/ssh-phabricator' do
    action :create
end

# Install Upstart init script for the SSH Daemon
template '/etc/init/ssh-vcs.conf' do
    source 'upstart/ssh-vcs.conf.erb'
    owner 'root'
    group 'root'
    mode '0755'
    notifies :restart, 'service[ssh-vcs]'
end

service 'ssh-vcs' do
    provider Chef::Provider::Service::Upstart
    supports status: true, restart: true, reload: true
    action [:enable, :start]
end

template '/etc/ssh-phabricator/sshd_config' do
    source 'vcs_ssh/sshd_config.erb'
    owner 'root'
    group 'root'
    mode '0755'
    notifies :restart, 'service[ssh-vcs]'
end

directory '/usr/libexec' do
    owner 'root'
    group 'root'
    mode '0755'
end

template '/usr/libexec/ssh-phabricator-hook' do
    source 'vcs_ssh/ssh-phabricator-hook.erb'
    owner 'root'
    group 'root'
    mode '0755'
end

# enable /etc/sudoers.d directory to enable the sudoer provider to work
node.override['authorization']['sudo']['include_sudoers_d'] = true

# We use template here, because right now upstream `sudo` cookbook doesn't support
# setting setenv, which is needed because phab runs `sudo -E`.
# Have filed https://github.com/chef-cookbooks/sudo/pull/72 for this.
sudo 'vcs_user' do
    template 'vcs_ssh/phab_sudo.erb'
    variables commands: ['/usr/bin/git-upload-pack',
                         '/usr/bin/git-receive-pack',
                         '/usr/bin/hg',
                         '/usr/bin/svnserve'],
              nopasswd: true,
              setenv: true,
              sudoer: node['phabricator']['vcs_ssh']['user'],
              runas: node['phabricator']['user']
end

sudo 'www-data' do
    template 'vcs_ssh/phab_sudo.erb'
    variables commands: ['/usr/bin/git-http-backend'],
              nopasswd: true,
              setenv: true,
              sudoer: 'www-data',
              runas: node['phabricator']['user']
end

# Install Git, Mercurial, SVN
%w(git subversion mercurial).each do |pkg|
    package pkg do
        action :install
    end
end
