#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable hasali19/niri-git

echo "priority=1" | sudo tee -a /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:hasali19:niri-git.repo

# this installs a package from fedora repos
dnf5 install -y \
    adw-gtk3-theme \
    btop \
    cascadia-code-nf-fonts \
    dmidecode \
    du-dust \
    edk2-ovmf \
    fd-find \
    fish \
    fprintd \
    fprintd-pam \
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
    ripgrep \
    swtpm-tools \
    uupd \
    waypipe

systemctl disable rpm-ostreed-automatic.timer
systemctl enable uupd.timer

# There's a regression in 0.8.2 causing issues with steam popup menus
# TODO: Remove when new xwayland-satellite version is released
dnf5 -y downgrade xwayland-satellite-0.8.1-1.fc44

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
