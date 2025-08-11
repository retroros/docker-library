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
    brickd \
    brickman \
    brickrun \
    ev3dev-adduser-config \
    ev3dev-base-files \
    ev3dev-bluez-config \
    ev3dev-connman-config \
    ev3dev-rules \
    ev3dev-tools

# work around https://github.com/ev3dev/brickstrap/issues/63
chmod u+s /bin/ping
