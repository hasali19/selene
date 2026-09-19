#!/bin/bash

set -ouex pipefail

KERNEL_VARIANT="${KERNEL_VARIANT:-fedora}"
KERNEL_SUFFIX=""

if [[ "${KERNEL_VARIANT}" == "cachyos" ]]; then
    /ctx/install-kernel.sh
    KERNEL_SUFFIX=cachyos
fi

/ctx/build-initramfs.sh
