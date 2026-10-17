#!/usr/bin/env bash

set -eoux pipefail

echo "::group::Executing build-initramfs"

cleanup() {
    mv -f "$OS_RELEASE.orig" "$OS_RELEASE"
    echo "::endgroup::"
}

trap cleanup EXIT

# The base image includes its build date in os-release which dracut copies
# into the initramfs as initrd-release. That makes the initramfs differ on
# every build, inflating update sizes. Build against a copy with the date
# stripped, then restore the file after.
OS_RELEASE=/usr/lib/os-release
mv "$OS_RELEASE" "$OS_RELEASE.orig"
sed -E -e '/^OSTREE_VERSION=/d' -e 's/\b([0-9]+)\.[0-9]{8}\.[0-9]+\b/\1/g' "$OS_RELEASE.orig" > "$OS_RELEASE"

# kernel package suffix, e.g. "cachyos" for kernel-cachyos. Empty (the default)
# targets the stock Fedora kernel. Needs a default because of set -u.
KERNEL_SUFFIX="${KERNEL_SUFFIX:-}"
QUALIFIED_KERNEL="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' "kernel${KERNEL_SUFFIX:+-${KERNEL_SUFFIX}}")"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree --add fido2 -f "/usr/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

chmod 0600 /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img

# Set the mtime of initramfs to the kernel mtime, to avoid it changing when
# contents are identical.
touch -r /usr/lib/modules/"$QUALIFIED_KERNEL"/vmlinuz /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img
