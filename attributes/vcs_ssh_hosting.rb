# Default to previous behaviour of not setting up SSH for VCS Hosting.
# NB this setting has no effect on Ubuntu 12.04 as its version of OpenSSH
# is too old to work.
# See:
# [https://secure.phabricator.com/book/phabricator/article/diffusion_hosting/#configuring-ssh]
default['phabricator']['vcs_ssh']['hosting_enabled'] = false

# Port that VCS SSH will listen on (seperate daemon)
default['phabricator']['vcs_ssh']['port'] = '617'

# Username for SSH for VCS
default['phabricator']['vcs_ssh']['user'] = 'git'

# Homedir for VCS user. NB this is not the repo path. See
# `node['phabricator']['repository_path']` in the default attributes
# file for this.`
home_dir_prefix = '/home'
home_dir = File.join(home_dir_prefix, node['phabricator']['vcs_ssh']['user'])
default['phabricator']['vcs_ssh']['home_dir'] = home_dir

append_paths = []
append_paths << File.join(node['phabricator']['path'], '/phabricator/support/bin')
append_paths << '/bin'
append_paths << '/usr/bin'
append_paths << '/usr/local/bin'
append_paths << '/usr/lib/git-core'

default['phabricator']['config']['environment.append-paths'] = %('#{append_paths}')
