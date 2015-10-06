#
# Cookbook Name:: phabricator
# Recipe:: repo_hosting
#
# Copyright 2014, MET Norway
#
# Authors: Kim Tore Jensen <kimtj@met.no>,
#          Andrew Mulholland <andrew@bash.sh>
#
# Sets up phabricator for hosting repositories over SSH

# To prevent the `vcsuser` (i.e. git ) user from being locked, a password needs to be provided with
# account creation. Using OpenSSLCookbook's RandomPassword function to generate a secure password.
unless node['phabricator']['vcspassword']
    Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)
    require 'digest/sha2'
    node.set['phabricator']['vcspassword'] = Digest::SHA512.hexdigest(random_password(length: 50))
end

user node['phabricator']['vcsuser'] do
    comment 'VCS User'
    home File.join('/home', node['phabricator']['vcsuser'])
    shell '/bin/sh'
    system true
    # This password is never used!
    password node['phabricator']['vcspassword']
    action [:create, :unlock]
end

directory File.join('/home', node['phabricator']['vcsuser']) do
    action :create
    owner node['phabricator']['vcsuser']
    mode '0755'
end

directory '/etc/ssh-phabricator' do
    action :create
end

template '/etc/init/ssh-vcs.conf' do
    source 'ssh-phabricator/ssh-vcs.conf.erb'
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
    source 'ssh-phabricator/sshd_config.erb'
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
    source 'ssh-phabricator/ssh-phabricator-hook.erb'
    owner 'root'
    group 'root'
    mode '0755'
end

# enable /etc/sudoers.d directory to enable the sudoer provider to work
node.override[:authorization][:sudo][:include_sudoers_d] = true

# We use template here, because right now upstream `sudo` cookbook doesn't support
# setting setenv, which is needed because phab runs `sudo -E`.
# Have filed https://github.com/chef-cookbooks/sudo/pull/72 for this.
sudo 'vcsuser' do
    template 'phab_sudo.erb'
    variables commands: ['/usr/bin/git-upload-pack',
                         '/usr/bin/git-receive-pack',
                         '/usr/bin/hg',
                         '/usr/bin/svnserve'],
              nopasswd: true,
              setenv: true,
              sudoer: node['phabricator']['vcsuser'],
              runas: node['phabricator']['user']
end

sudo 'www-data' do
    template 'phab_sudo.erb'
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
