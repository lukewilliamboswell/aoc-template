#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

roc='./roc_nightly/roc'

for roc_file in *.roc; do
    $roc check $roc_file
done

$roc build cli.roc
$roc build web.roc
