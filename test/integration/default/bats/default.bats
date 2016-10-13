#!/usr/bin/env bats
# vi: se ft=sh:

@test "nginx is running" {
    run service nginx status
    [ $status -eq 0 ]
}

@test "MySQL is running" {
    run service mysql-default status
    [ $status -eq 0 ]
}

@test "Phabricator daemons are running" {
    run service phd status
    [ $status -eq 0 ]
}

@test "Phabricator responds to HTTP requests" {
    curl http://localhost | {
        run grep Phabricator
        [ $status -eq 0 ]
    }
}

@test "SSHD VCS is running" {
    if [ $(lsb_release -r | awk '{print $2}') == "12.04" ]; then
      skip "SSH hosting not supported on 12.04"
    fi

    run service ssh-vcs status
    [ $status -eq 0 ]
}

@test "SSHd for VCS is listening" {
    if [ $(lsb_release -r | awk '{print $2}') == "12.04" ]; then
      skip "SSH hosting not supported on 12.04"
    fi

    run sh -c "netstat -nlp |grep :617"
    [ $status -eq 0 ]
}
