#!/usr/bin/env bash

set -eoux pipefail

echo "::group::Executing install-regreet"
trap 'echo "::endgroup::"' EXIT

# ReGreet isn't packaged for Fedora, so it needs to be compiled from source.
# See: https://github.com/rharish101/ReGreet
REGREET_VERSION="0.5.0"
BUILD_DIR="$(mktemp -d)"
export CARGO_HOME="$BUILD_DIR/.cargo"

# Build-time only dependencies, removed again at the end of this script.
dnf5 install -y \
    cargo \
    gtk4-devel \
    rust

curl -fsSL "https://github.com/rharish101/ReGreet/archive/refs/tags/${REGREET_VERSION}.tar.gz" |
    tar -xz -C "$BUILD_DIR" --strip-components=1

pushd "$BUILD_DIR"
cargo build --release --locked
install -Dm755 target/release/regreet /usr/bin/regreet
install -Dm644 systemd-tmpfiles.conf /usr/lib/tmpfiles.d/regreet.conf
popd

rm -rf "$BUILD_DIR"

dnf5 remove -y cargo gtk4-devel rust
