#!/usr/bin/env bash

set -eoux pipefail

echo "::group::Executing build-regreet"
trap 'echo "::endgroup::"' EXIT

# ReGreet isn't packaged for Fedora, so it's compiled from source here, in a
# throwaway build stage (see the `regreet` stage and the `copy` modules that
# pull the result out of it in recipe.yml), keeping the build toolchain out
# of the final image.
# See: https://github.com/rharish101/ReGreet
REGREET_VERSION="0.5.0"
SRC_DIR="/tmp/regreet"

dnf5 install -y \
    cargo \
    gtk4-devel \
    rust

mkdir -p "$SRC_DIR"
curl -fsSL "https://github.com/rharish101/ReGreet/archive/refs/tags/${REGREET_VERSION}.tar.gz" |
    tar -xz -C "$SRC_DIR" --strip-components=1

pushd "$SRC_DIR"
cargo build --release --locked
install -Dm755 target/release/regreet /usr/bin/regreet
install -Dm644 systemd-tmpfiles.conf /usr/lib/tmpfiles.d/regreet.conf
popd
