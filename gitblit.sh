#!/usr/bin/env bash

set -e

source lib.sh

NAME="gitblit"
VERSION="1.2.1"
FPM_OPTIONS="
  -d java7-runtime-headless \
  -a all \
  --url http://gitblit.com/ \
  --license Apache \
  "

init
unpack

SOURCES="\
  LICENSE \
  NOTICE \
  authority.jar \
  data \
  docs \
  ext \
  gitblit \
  gitblit.jar \
  java-proxy-config.sh \
  "

for i in $SOURCES; do
  take "$i"
done

chmod a+x "$PACKDIR/gitblit"

set_shebang "$PACKDIR/gitblit" "/usr/bin/env bash"

pack

cleanup

