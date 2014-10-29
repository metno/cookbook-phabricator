#!/usr/bin/env bats
# vi: se ft=sh:

@test "git binary is installed" {
    run which git
    [ $status -eq 0 ]
}

@test "arc binary is installed" {
    run which arc
    [ $status -eq 0 ]
}

@test "arcanist is configured correctly" {
    run arc version
    [ $status -eq 0 ]
}
