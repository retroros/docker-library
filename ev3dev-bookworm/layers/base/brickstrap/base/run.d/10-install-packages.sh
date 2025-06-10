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
    alsa-utils \
    avahi-daemon \
    beep \
    bluez \
    bsdmainutils \
    ca-certificates \
    connman \
    console-setup \
    conspy \
    curl \
    dosfstools \
    espeak \
    ethtool \
    evtest \
    fake-hwclock \
    fbcat \
    fbset \
    file \
    firmware-atheros \
    firmware-linux-free \
    firmware-ralink \
    firmware-realtek \
    firmware-zd1211 \
    flash-kernel \
    fontconfig \
    i2c-tools \
    ifupdown \
    iproute2 \
    iptables \
    iputils-ping \
    isc-dhcp-client \
    kmod \
    less \
    libgrx-3.0-2-plugin-linuxfb \
    libnss-mdns \
    libnss-myhostname \
    libnss-resolve \
    libpam-systemd \
    locales \
    nano \
    net-tools \
    netbase \
    netcat-openbsd \
    netpbm \
    ntp \
    parted \
    procps \
    psmisc \
    screen \
    ssh \
    sudo \
    systemd-sysv \
    tree \
    usb-modeswitch \
    usbutils \
    vim \
    wget \
    wpasupplicant \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-base \
    xfonts-efont-unicode \
    xfonts-efont-unicode-ib \
    xfonts-unifont

# work around https://github.com/ev3dev/brickstrap/issues/63
chmod u+s /bin/ping

# Probably more stuff to build from source before the brick* family of packages
#    ev3dev-adduser-config \
#    ev3dev-base-files \
#    ev3dev-bluez-config \
#    ev3dev-connman-config \
#    ev3dev-rules \
#    ev3dev-tools \

# Need to build the following from source as they're not hosted yet:
#    brickd
#    brickman
#    brickrun

# install tools to build dependencies (this should be moved to a docker builder container and copied back into this container)
apt-get install --yes --no-install-recommends \
    git \
    cmake \
    libgudev-1.0-dev \
    libxkbcommon-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype-dev \
    libfontconfig-dev \
    libglib2.0-dev \
    libinput-dev \
    gobject-introspection \
    libgirepository1.0-dev \
    gtk-doc-tools \
    libgtk-3-dev \
    pandoc \
    valabind \
    valadoc \
    valac #libvala-dev
    vala-0.56*
    #libpng-dev
    #libpnglite-dev
    #libspng-dev

# get sources
mkdir /ev3build ; cd /ev3build
git clone --recursive --depth=1 --single-branch --branch=master \
          https://github.com/ev3dev/brickd.git
git clone --recursive --depth=1 --single-branch --branch=master \
          https://github.com/ev3dev/grx.git
# todo
git clone --recursive --depth=1 --single-branch --ev3dev-bullseye \
          https://github.com/Doom4535/ev3devKit.git
git clone --recursive --depth=1 --single-branch --branch=ev3dev-bullseye \
          https://github.com/Doom4535/brickman

# Maybe try to install to /usr instead of /usr/local?
cd brickd ; mkdir build ; cd build ; cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. ; make ; make install ; cd /ev3build 
cd grx ; mkdir build ; cd build ; cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. ; make ; make install ; cd /ev3build 
