#!/usr/bin/env bash

set -eoux pipefail

echo "::group::Executing install-nirimod"

NIRIMOD_SRC=""
cleanup() {
  rm -rf "$NIRIMOD_SRC"
  echo "::endgroup::"
}
trap cleanup EXIT

# NiriMod (https://github.com/srinivasr/nirimod) is a GTK4/libadwaita GUI
# configurator for the niri Wayland compositor. Upstream only ships an
# interactive, per-user install.sh, so we install it system-wide here
# instead: pip-install the package into /usr and register its desktop
# entry/icon so it's available to every user out of the box.
#
# Pinned to a specific commit for reproducible builds, since upstream
# does not publish tagged releases.
NIRIMOD_REPO="https://github.com/srinivasr/nirimod"
NIRIMOD_REF="7a449c8451bd171d3c1d4281afc61f9d9f3ed86d"

NIRIMOD_SRC="$(mktemp -d)"

git clone "$NIRIMOD_REPO" "$NIRIMOD_SRC"
git -C "$NIRIMOD_SRC" checkout "$NIRIMOD_REF"

# PyGObject/GTK4/libadwaita/Pycairo bindings come from the system packages
# installed via dnf; nirimod's own pyproject.toml has no PyPI dependencies.
pip install --prefix=/usr --no-cache-dir --break-system-packages "$NIRIMOD_SRC"

install -Dm644 "$NIRIMOD_SRC/data/nirimod.svg" /usr/share/icons/hicolor/scalable/apps/nirimod.svg

mkdir -p /usr/share/applications
cat > /usr/share/applications/io.github.nirimod.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=NiriMod
GenericName=Compositor Settings
Comment=GUI Configuration Manager for the Niri Wayland Compositor
Exec=nirimod
Icon=nirimod
Terminal=false
Type=Application
Categories=Utility;Settings;DesktopSettings;
Keywords=compositor;windowmanager;wayland;niri;settings;config;
StartupNotify=true
StartupWMClass=nirimod
EOF
chmod 644 /usr/share/applications/io.github.nirimod.desktop

gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
update-desktop-database /usr/share/applications || true
