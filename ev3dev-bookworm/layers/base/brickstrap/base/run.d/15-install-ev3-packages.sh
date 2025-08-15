#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

debconf-set-selections << EOF
locales         locales/locales_to_be_generated         multiselect     en_US.UTF-8 UTF-8
locales         locales/default_environment_locale      select          en_US.UTF-8
EOF


apt-get update --yes
apt-get install --yes --no-install-recommends \
	git

# Build packages from source
# Probably update the dockerfile to create a tmpfs mount
# to run the build in
# TODO: Update these to exclude the debug symbol builds (or provide a way to enable/disable them)
# TODO: Missing gir1.2-grx-3.0
# Using bash dictionary till all on same branch
declare -A PCKGS
PCKGS["https://github.com/retroros/grx.git"]="ev3dev-bullseye"
PCKGS["https://github.com/retroros/grx-widgets.git"]="ev3dev-stretch"
PCKGS["https://github.com/retroros/console-runner.git"]="ev3dev-stretch"
PCKGS["https://github.com/retroros/brickd.git"]="master"
PCKGS["https://github.com/retroros/brickrun.git"]="ev3dev-stretch"
PCKGS["https://github.com/retroros/ev3devKit.git"]="ev3dev-bookworm"
PCKGS["https://github.com/retroros/brickman.git"]="ev3dev-bookworm"
PCKGS["https://github.com/retroros/ev3dev-base-files.git"]="ev3dev-bookworm"
PCKGS["https://github.com/retroros/ev3dev-rules.git"]="ev3dev-stretch"
PCKGS["https://github.com/retroros/ev3dev-tools.git"]="ev3dev-stretch"
PCKGS["https://github.com/retroros/ev3dev-bluez-config.git"]="ev3dev-jessie"
PCKGS["https;//github.com/retroros/ev3dev-connman-config.git"]="ev3dev-buster"
PCKGS["https://github.com/retroros/ev3dev-adduser-config.git"]="ev3dev-jessie"
BUILDDIR="/build"
mkdir -p "$BUILDDIR"
for PKG in "${!PCKGS[@]}" ; do
	PKG_BRANCH="${PCKGS[$PKG]}"
	git -C "$BUILDDIR" clone --recursive --depth=1 --single-branch --branch="$PKG_BRANCH" "$PKG" src
	cd src
	dpkg-buildpackage --build=full -uc -us
	apt install --yes ./*.deb # How to exclude debug packages and how to match arch?
	cd "$BUILDDIR"
	rm -rf "$BUILDDIR/*"
done

# Extra languages to consider installing
# https://www.ev3dev.org/docs/programming-languages/

# work around https://github.com/ev3dev/brickstrap/issues/63
chmod u+s /bin/ping
