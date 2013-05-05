#!/usr/bin/false

source config.sh

ROOTDIR="$PWD"
INDIR="$PWD/in"
OUTDIR="$PWD/out"

function init {
  WORKDIR="$(mktemp -d -t anchovy)"
}

function _find_one {
  RESULTS="$(find "$@")"
  COUNT="$(wc -l <<<$RESULTS)"
  if [ "$COUNT" -eq 0 ]; then
    echo "Not found: $*"
    exit 1
  elif [ "$COUNT" -gt 1 ]; then
    echo "Ambiguous result: $*"
    exit 1
  else
    cat - <<<$RESULTS
  fi
}

function _pkg_file {
  _find_one "$INDIR" -name "$(printf '%s-%s.*' "$NAME" "$VERSION")"
}

function _file_type {
  file --mime-type --brief "$1"
}

function unpack {
  FILE="$(_pkg_file)"
  UNPACKDIR="$WORKDIR/unpack"
  PACKDIR="$WORKDIR/pack"
  mkdir -p "$UNPACKDIR" "$PACKDIR"
  case "$(_file_type "$FILE")" in
    application/zip)
      unzip "$FILE" -d "$UNPACKDIR" >/dev/null 2>&1
      ;;
    *)
      echo "Unknown package type: $FILE"
      ;;
  esac
}

function take {
  cp -a "$UNPACKDIR/$1" "$PACKDIR/$1"
}

function _pkg_desc {
  DESCFILE="$ROOTDIR/$NAME.txt"
  if [ -f "$DESCFILE" ]; then
    cat "$DESCFILE"
  else
    echo
  fi
}

function pack {
  pushd "$PACKDIR" >/dev/null 2>&1
  fpm \
    $CORE_FPM_OPTIONS \
    $FPM_OPTIONS \
    -s dir \
    -t deb \
    -n "$NAME" \
    -v "$VERSION" \
    --description "$(_pkg_desc)" \
    --prefix "/opt/$NAME/$VERSION" \
    --deb-compression xz \
    --deb-user 0 \
    --deb-group 0 \
    * >/dev/null 2>&1
  MADE="$(ls *.deb)"
  mv *.deb "$OUTDIR/"
  popd >/dev/null 2>&1
  echo "$OUTDIR/$MADE"
}

function cleanup {
  rm -rf "$WORKDIR"
}

function set_shebang {
  FILE="$1"
  SHEBANG="#!$2"
  if [ ! -f "$FILE" ]; then
    echo "Not found: $FILE"
    exit 1
  fi
  TMPFILE="$(mktemp -t anchovy)"
  if head -n 1 "$FILE" | grep -q '^#!'; then
    (echo "$SHEBANG"; tail -n +2 "$FILE") > "$TMPFILE"
  else
    (echo "$SHEBANG"; cat "$FILE") > "$TMPFILE"
  fi
  mv "$TMPFILE" "$FILE"
}

