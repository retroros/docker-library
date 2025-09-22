#!/bin/bash

set -e
shopt -s nullglob # Disable litteral matching
shopt -s extglob  # Enable extended globbing features

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

debconf-set-selections << EOF
locales         locales/locales_to_be_generated         multiselect     en_US.UTF-8 UTF-8
locales         locales/default_environment_locale      select          en_US.UTF-8
EOF


apt-get update --yes
apt-get install --yes --no-install-recommends \
  cmake \
  config-package-dev \
  debhelper \
	git \
	gir1.2-glib-2.0 \
	gobject-introspection \
	gtk-doc-tools \
	libfontconfig1-dev \
	libfreetype6-dev \
	libgirepository1.0-dev \
	libglib2.0-dev \
	libglib2.0-doc \
	libgtk-3-dev \
	libgudev-1.0-dev \
	libinput-dev \
	libjpeg-dev \
	libpng-dev \
	libudev-dev \
	libxkbcommon-dev \
	pandoc \
	pkg-config \
	valac \
	valadoc

# Build packages from source
# Probably update the dockerfile to create a tmpfs mount
# to run the build in
# TODO: Update these to exclude the debug symbol builds (or provide a way to enable/disable them) string contains 'dbgsym'
# Using bash dictionary till all on same branch
declare -A PCKG_SOURCE
PCKG_SOURCE["https://github.com/retroros/grx.git"]="ev3dev-bullseye"
PCKG_SOURCE["https://github.com/retroros/grx-widgets.git"]="ev3dev-stretch"
PCKG_SOURCE["https://github.com/retroros/console-runner.git"]="ev3dev-stretch"
PCKG_SOURCE["https://github.com/retroros/brickd.git"]="master"
PCKG_SOURCE["https://github.com/retroros/brickrun.git"]="ev3dev-stretch"
PCKG_SOURCE["https://github.com/retroros/ev3devKit.git"]="ev3dev-bookworm"
PCKG_SOURCE["https://github.com/retroros/brickman.git"]="ev3dev-bookworm"
PCKG_SOURCE["https://github.com/retroros/ev3dev-base-files.git"]="ev3dev-bookworm"
PCKG_SOURCE["https://github.com/retroros/ev3dev-rules.git"]="ev3dev-stretch"
PCKG_SOURCE["https://github.com/retroros/ev3dev-tools.git"]="ev3dev-stretch"
PCKG_SOURCE["https://github.com/retroros/ev3dev-bluez-config.git"]="ev3dev-jessie"
PCKG_SOURCE["https://github.com/retroros/ev3dev-connman-config.git"]="ev3dev-buster"
PCKG_SOURCE["https://github.com/retroros/ev3dev-adduser-config.git"]="ev3dev-jessie"

# Used to maintain package order as hashtable lookup alone will not install all packages in order
declare -a RETROROS_PKGS=( "grx" "grx-widgets" "console-runner" "brickd" "brickrun"
                           "ev3devKit" "brickman" "ev3dev-base-files" "ev3dev-rules"
                           "ev3dev-tools" "ev3dev-bluez-config" "ev3dev-connman-config"
                           "ev3dev-adduser-config" )

BUILDDIR="/build"
mkdir -p "$BUILDDIR"
rm -rf "$BUILDDIR"/* # Cleanup if we're running multiple times manually
pushd "$BUILDDIR"
for PKG in "${RETROROS_PKGS[@]}" ; do
	PKG_URL="https://github.com/retroros/${PKG}.git"
	PKG_BRANCH="${PCKG_SOURCE[$PKG_URL]}"
	echo "Building $PKG from $PKG_URL on branch $PKG_BRANCH in builddir $BUILDDIR"
	git -C "$BUILDDIR" clone --recursive --depth=1 --single-branch --branch="$PKG_BRANCH" "$PKG_URL" src
	cd src
	dpkg-buildpackage --build=full -uc -us
	if ! [ "${INCLUDE_DEBUG}" ] ; then
		apt install --yes $(find "${BUILDDIR}" -maxdepth 1 -type f ! -iname '*dbgsym*' -iname '*.deb')
	else
		apt install --yes $(find "${BUILDDIR}" -maxdepth 1 -type f -iname '*.deb') # Include optional debug symbols
	fi
	cd "$BUILDDIR"
	rm -rf "$BUILDDIR/src"
done
popd
# Cleanup
rm -rf "$BUILDDIR"

# Extra languages to consider installing
# https://www.ev3dev.org/docs/programming-languages/

# work around https://github.com/ev3dev/brickstrap/issues/63
chmod u+s /bin/ping
