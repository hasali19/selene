#!/usr/bin/env bash

# The sysc-greet RPM's %post scriptlet creates a "greeter" system user and
# adds it to the video/render/input supplementary groups. Those groups are
# normally created dynamically by udev/systemd-sysusers on a running system,
# so they don't exist yet inside the container image build environment. If
# they're missing, `useradd` fails and aborts the whole dnf transaction,
# breaking the image build. Pre-create them here (idempotently) so the
# sysc-greet install succeeds.
set -euo pipefail

groupadd -f -r video
groupadd -f -r render
groupadd -f -r input
