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

@test "Phabricator responds to HTTP requests" {
    wget -O - http://localhost | {
        run grep Phabricator
        [ $status -eq 0 ]
    }
}
