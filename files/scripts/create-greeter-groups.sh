#!/usr/bin/env bash

# The sysc-greet RPM's %post scriptlet creates a "greeter" system user and
# adds it to the video/render/input supplementary groups. Those groups are
# normally created dynamically by udev at runtime, so they don't exist yet
# during the image build.
#
# A plain `groupadd` here isn't enough: rpm-ostree's unified-core dnf
# transaction rebuilds /etc/passwd and /etc/group from the declarative
# sysusers.d files in the tree, which discards ad-hoc edits made outside
# that mechanism. So the groups are instead declared in
# files/system/usr/lib/sysusers.d/95-selene-greeter-groups.conf (copied into
# the tree by the "files" module before this script runs), and we invoke
# systemd-sysusers on it explicitly here to materialize them immediately -
# the same mechanism greetd itself uses to create its own "greetd" group.
set -euo pipefail

systemd-sysusers /usr/lib/sysusers.d/95-selene-greeter-groups.conf
