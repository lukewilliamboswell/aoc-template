#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

if [ -z "${ROC:-}" ]; then
  echo "INFO: The ROC environment variable is not set."
  export ROC=$(which roc)
fi

EXAMPLES_DIR='./examples'
PACKAGE_DIR='./package'

# List of files to ignore
IGNORED_FILES=("xx.roc")

# roc check examples
for ROC_FILE in $EXAMPLES_DIR/**/*.roc; do
    if [[ " ${IGNORED_FILES[*]} " != *" ${ROC_FILE##*/} "* ]]; then
        $ROC check $ROC_FILE
    fi
done

# roc test package NO TESTS CURRENTLY
# $ROC test $PACKAGE_DIR/main.roc

# test building docs website
$ROC docs $PACKAGE_DIR/main.roc

echo "INFO: Completed all tests... 🎉"
