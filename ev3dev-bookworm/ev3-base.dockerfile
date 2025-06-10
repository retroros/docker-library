# Minimal base image for ev3dev on LEGO MINDSTORMS EV3 hardware

# consider changing this up to use docker multiplatform builds
# see how the process was done with ev3dev-docker-cross
FROM arm32v5/debian:bookworm

# Enable additional software source
# Shouldn't be needed with updated debian.source file
#RUN sed -i 's|main|main contrib non-free non-free-firmware|' \
#           /etc/apt/sources.list.d/debian.sources
RUN apt-get update ; apt-get upgrade -y

# Provision ev3dev layers
COPY layers/debian/ /
COPY layers/base/ /
RUN /brickstrap/base/run
COPY layers/ev3/ /
RUN /brickstrap/ev3/run
