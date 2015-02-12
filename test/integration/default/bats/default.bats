#!/usr/bin/env bats
# vi: se ft=sh:

@test "nginx is running" {
    run /etc/init.d/nginx status
    [ $status -eq 0 ]
}

@test "MySQL is running" {
    run /etc/init.d/mysql status
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
