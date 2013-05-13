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

cp -a "$INDIR/gitblit" "$PACKDIR/gitblit"

pack

cleanup

