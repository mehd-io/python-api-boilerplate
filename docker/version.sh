#!/bin/bash
# Simple bash script to generate version based on hash of files or git command
ROOT=$(git rev-parse --show-toplevel)

OS=$(uname -s)
if [ "$OS" = "Linux" ]; then
  md5_cmd="md5sum"
elif [ "$OS" = "Darwin" ]; then
  md5_cmd="md5 -r"
else
  echo "OS NOT DETECTED, couldn't get hash for version"
  exit 1;
fi

case $1 in

  base)
    REQ_HASH=$(
      cat \
        "$ROOT/pyproject.toml" \
        "$ROOT/poetry.lock" \
        "$ROOT/docker/base.Dockerfile" \
      | ${md5_cmd} \
      | cut -d' ' -f1 \
      | tr '[:upper:]' '[:lower:]'
    )
    echo "$1-${REQ_HASH:0:20}"
    ;;

  app)
    echo "$1-$(git rev-parse --short=20 HEAD)"
    ;;

  dev)
    echo "$1-latest"
    ;;

  *)
    echo "unknown"
    ;;
esac