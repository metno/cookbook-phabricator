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
