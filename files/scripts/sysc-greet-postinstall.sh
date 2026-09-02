#!/usr/bin/env bash

# sysc-greet's own %post RPM scriptlet can't see groups/users created earlier
# in the build: RPM scriptlets run in a sandbox that doesn't share live
# /etc/group state, even within the exact same RUN layer as the install
# (verified: `getent group video render input` succeeds right before dnf5
# runs, but sysc-greet's own useradd inside the scriptlet still reports the
# groups missing). The package is installed with scriptlets disabled
# (--setopt=tsflags=noscripts); this replicates its upstream postinstall.sh
# (https://github.com/Nomadcxx/sysc-greet/blob/v1.1.9/scripts/postinstall.sh)
# as a plain script instead, which isn't sandboxed and works correctly.
set -euo pipefail

echo "==> Setting up sysc-greet..."

if ! id greeter &>/dev/null; then
    echo "==> Creating greeter user..."
    useradd -M -d /var/lib/greeter -G video,render,input -s /usr/bin/nologin greeter
else
    echo "==> Updating greeter user groups..."
    usermod -d /var/lib/greeter -aG video,render,input greeter
fi

echo "==> Setting permissions..."
mkdir -p /var/cache/sysc-greet \
    /var/lib/greeter/Pictures/wallpapers \
    /var/lib/greeter/.cache \
    /var/lib/greeter/.config \
    /var/lib/greeter/.local/state \
    /tmp/greeter-cache
chown -R greeter:greeter /var/cache/sysc-greet 2>/dev/null || true
chown -R greeter:greeter /var/lib/greeter 2>/dev/null || true
chown -R greeter:greeter /tmp/greeter-cache 2>/dev/null || true
chmod 755 /var/lib/greeter

echo "==> Detecting greeter backend..."

COMPOSITOR=""
if command -v niri &>/dev/null; then
    COMPOSITOR="niri"
    GREETD_COMMAND="niri -c /etc/greetd/niri-greeter-config.kdl"
elif command -v cagebreak &>/dev/null; then
    COMPOSITOR="cagebreak"
    GREETD_COMMAND="cagebreak -e -c /etc/greetd/cagebreak-greeter-config"
elif command -v sway &>/dev/null; then
    COMPOSITOR="sway"
    GREETD_COMMAND="sway -c /etc/greetd/sway-greeter-config"
elif command -v Hyprland &>/dev/null || command -v hyprland &>/dev/null; then
    COMPOSITOR="hyprland"
    GREETD_COMMAND="Hyprland -c /etc/greetd/hyprland-greeter-config.conf"
fi

if [ -z "$COMPOSITOR" ]; then
    echo "WARNING: No supported greeter backend detected (niri, cagebreak, sway, hyprland)"
    echo "Please install niri or cagebreak and manually configure /etc/greetd/config.toml"
else
    echo "Detected backend: $COMPOSITOR"

    if [ ! -s /etc/greetd/config.toml ]; then
        echo "==> Configuring greetd for $COMPOSITOR..."
        cat > /etc/greetd/config.toml <<EOF2
[terminal]
vt = 1

[default_session]
command = "$GREETD_COMMAND"
user = "greeter"

[initial_session]
command = "$GREETD_COMMAND"
user = "greeter"
EOF2
        echo "Created /etc/greetd/config.toml"
    else
        echo "Existing /etc/greetd/config.toml found, not modifying"
    fi
fi

echo "==> sysc-greet set up successfully!"
