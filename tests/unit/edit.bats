#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "edit: helm edit" {
    run helm secrets edit
    assert_failure
    assert_output --partial 'Edit encrypted secrets'
}

@test "edit: helm edit --help" {
    run helm secrets edit --help
    assert_success
    assert_output --partial 'Edit encrypted secrets'
}

@test "edit: Directory not exits" {
    run helm secrets edit nonexists
    assert_failure
    assert_output --partial 'File does not exist: nonexists'
}

@test "edit: secrets.yaml" {
    if [ "${HELM_SECRETS_DRIVER}" != "sops" ]; then
        skip
    fi

    EDITOR="${TEST_DIR}/assets/mock-editor/editor.sh"
    export EDITOR

    FILE="${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"

    run helm secrets edit "${FILE}"
    assert_success

    run helm secrets view "${FILE}"
    assert_success
    assert_output "hello: world"
}


@test "edit: secrets.yaml + special path" {
    if [ "${HELM_SECRETS_DRIVER}" != "sops" ]; then
        skip
    fi

    EDITOR="${TEST_DIR}/assets/mock-editor/editor.sh"
    export EDITOR

    FILE="${SPECIAL_CHAR_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"

    run helm secrets edit "${FILE}"
    assert_success

    run helm secrets view "${FILE}"
    assert_success
    assert_output "hello: world"
}