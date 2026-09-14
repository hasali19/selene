#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to / (this includes
# usr/share/plymouth/themes/spinner/watermark.png, rendered from
# branding/logo-dark.svg by the "watermark" build stage in the Containerfile)
cp -avf "/ctx/system_files"/. /

KERNEL_VARIANT="${KERNEL_VARIANT:-fedora}"

if [[ "${KERNEL_VARIANT}" == "cachyos" ]]; then
    /ctx/install-kernel.sh
    KERNEL_SUFFIX=cachyos /ctx/build-initramfs.sh
else
    # dracut bakes the plymouth theme into the initramfs, so it has to be
    # rebuilt even for the stock kernel to pick up files copied from
    # system_files above
    /ctx/build-initramfs.sh
fi

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y \
    adw-gtk3-theme \
    btop \
    cascadia-code-nf-fonts \
    dmidecode \
    edk2-ovmf \
    fish \
    gnome-boxes \
    greetd \
    kde-connect \
    kf6-kitemmodels \
    libatomic \
    liquidctl \
    nautilus \
    niri \
    noctalia \
    openconnect \
    swtpm-tools \
    waypipe

dnf5 config-manager addrepo --from-repofile=https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo && \
    dnf5 install -y noctalia-greeter && \
    rm -f /etc/yum.repos.d/terra.repo

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

systemctl enable greetd.service
