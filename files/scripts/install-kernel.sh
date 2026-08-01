#!/usr/bin/env bash

# Adapted from https://github.com/ublue-os/bazzite/blob/main/build_files/install-kernel-akmods

# create a shims to bypass kernel install triggering dracut
# seems to be minimal impact, but allows progress on build
pushd /usr/lib/kernel/install.d
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x 50-dracut.install
popd

# cleanup leftovers that are not covered by kernel-* packages for some reason
rm -rf /usr/lib/modules

cd /etc/yum.repos.d/
sudo wget https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo
sudo dnf remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
sudo dnf install -y kernel-cachyos

pushd /usr/lib/kernel/install.d
# mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd
