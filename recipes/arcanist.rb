#
# Cookbook Name:: phabricator
# Recipe:: arcanist
#
# Copyright 2014, MET Norway
#
# Authors: Kim Tore Jensen <kimtj@met.no>
#
# This recipe installs the Arcanist libraries for use by developers.
#

package 'php5-cli'
package 'php5-curl'
package 'git'

directory node['phabricator']['arcanist']['destination'] do
    action :create
    recursive true
    owner 'root'
    group 'root'
    mode '0755'
end

git "#{node['phabricator']['arcanist']['destination']}/libphutil" do
    repository 'https://github.com/phacility/libphutil.git'
    revision node['phabricator']['revision']['libphutil']
    action :sync
end

git "#{node['phabricator']['arcanist']['destination']}/arcanist" do
    repository 'https://github.com/phacility/arcanist.git'
    revision node['phabricator']['revision']['arcanist']
    action :sync
end

link node['phabricator']['arcanist']['bin'] do
    to "#{node['phabricator']['arcanist']['destination']}/arcanist/bin/arc"
end
