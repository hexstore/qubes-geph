#!/bin/bash

set -eu pipefail

export CARGO_NET_GIT_FETCH_WITH_CLI=true

DEST_QUBE=sys-geph
CARGO="${HOME}/.cargo/bin/cargo"

installDeps() {
  sudo apt-get install -yq build-essential

  if ! command -v "${CARGO}" >/dev/null 2>&1
  then
    curl --proto '=https' --tlsv1.2 -sSfL https://sh.rustup.rs | sh -s -- -y -v
  fi
}

main() {
  installDeps

  /usr/bin/rm -rf "${HOME}/.cargo/.package-cache" "${HOME}/.cargo/registry/cache/*"
  /usr/bin/bash -c "${CARGO} install -v geph4-client"

  qvm-copy "${HOME}/.cargo/bin/geph4-client"
}

main "$@"
