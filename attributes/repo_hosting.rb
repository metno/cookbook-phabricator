# Default to previous behaviour of not hosting repos in phabricator
# NB this setting has no effect on Ubuntu 12.04 as its version of OpenSSH
# is too old to work.
default['phabricator']['repo_hosting_enabled'] = false

# Port that VCS SSH will listen on
default['phabricator']['ssh_vcs_port'] = '617'

# User for Source code hosting
default['phabricator']['vcsuser'] = 'git'

append_paths = []
append_paths << File.join(node['phabricator']['path'], '/phabricator/support/bin')
append_paths << '/bin'
append_paths << '/usr/bin'
append_paths << '/usr/local/bin'
append_paths << '/usr/lib/git-core'

default['phabricator']['config']['environment.append-paths'] = %Q('#{append_paths}')
