#!/usr/bin/env bash

set -eoux pipefail

echo "::group::Executing build-initramfs"

# The base image stamps its build date into os-release (e.g. 44.20261017.0),
# and dracut copies os-release into the initramfs as initrd-release. That alone
# makes the initramfs (~240MB) differ on every build, so every update had to
# re-download it. Build against a copy with the date stripped, then put the
# real file back.
OS_RELEASE=/usr/lib/os-release
mv "$OS_RELEASE" "$OS_RELEASE.orig"
trap 'mv -f "$OS_RELEASE.orig" "$OS_RELEASE"; echo "::endgroup::"' EXIT
sed -E -e '/^OSTREE_VERSION=/d' -e 's/\b([0-9]+)\.[0-9]{8}\.[0-9]+\b/\1/g' "$OS_RELEASE.orig" > "$OS_RELEASE"

# kernel package suffix, e.g. "cachyos" for kernel-cachyos. Empty (the default)
# targets the stock Fedora kernel. Needs a default because of set -u.
KERNEL_SUFFIX="${KERNEL_SUFFIX:-}"
QUALIFIED_KERNEL="$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' "kernel${KERNEL_SUFFIX:+-${KERNEL_SUFFIX}}")"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible --zstd -v --add ostree --add fido2 -f "/usr/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

chmod 0600 /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img

# chunkah keeps the mtime of files no package owns, so a freshly generated
# initramfs would get a new layer on every build even when its contents are
# identical. Give it the kernel's mtime (set by the kernel package) instead.
touch -r /usr/lib/modules/"$QUALIFIED_KERNEL"/vmlinuz /usr/lib/modules/"$QUALIFIED_KERNEL"/initramfs.img
