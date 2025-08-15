# Configure build arguments
ARG XZ_DEFAULTS="-T0"

# Consider adding pypy for folks who wish to try to improve performance

# Consider 'double' building python a second time after a 'distclean'
# without the shared library so that it runs with a static library by
# default for better performance while preserving the shared libraries
# if they are needed by other programs

# Consider using temp mounts of downloaded source files to reduce size

# Install older version of OpenSSL for Python2.7
#ADD https://ftp.openssl.org/source/old/1.0.2/openssl-1.0.2d.tar.gz .
#ADD https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_1u/openssl-1.0.1u.tar.gz .
#ADD https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_2d/openssl-1.0.2d.tar.gz .
ADD https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_2u/openssl-1.0.2u.tar.gz .
#ADD https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_0l/openssl-1.1.0l.tar.gz .
#ADD https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz .
RUN tar -xf openssl-1.*.tar.gz && rm openssl-1.*.tar.gz
# build with no-asm for arm (maybe make it detect if arm vs x86? and auto apply?)
#./config -t --prefix=/usr/local --openssldir=/usr/local --libdir=lib no-asm shared zlib-dynamic &&\
# ./config -t may incorrectly try to combine linux-armv4 with -march=armv7-a ? not sure on what this means
# the ev3 is using an armv5tej (gcc may drop the 'j' support so, armv5et) processor
# linux-armv4 -march=armv5tej
# ./Configure linux-armv4 -march=armv5tej
RUN cd openssl-1* &&\
    export KERNEL_BITS=$(getconf LONG_BIT) &&\
    export LINUX_ARCH=$(echo "linux-armv4") &&\
    export CPU_ARCH=$(echo "armv5tej") &&\
    ./Configure "$LINUX_ARCH" -march="$CPU_ARCH" \
                --prefix=/usr/local --openssldir=/usr/local --libdir=lib \
                shared zlib-dynamic &&\
    make -j 1 &&\
    make install -j 1 &&\
    ldconfig
# RUN cp /tmp/openssl-arm/include/openssl/* include/openssl/

# Adding in Python2.7 for possible legacy use case
# See: https://gist.github.com/lukaslundgren/2659457
ADD http://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz .

# Arm builds segfault with SSL? If we disable SSL will it work?
# Do we also need to install SSL 1? How do we do that on Debian 12?

# Possibly want to set `--build=?(target architecture)`

# Maybe there is a better way to extract without emulation running?
RUN tar -xf Python-2.7.18.tar.xz && rm Python-2.7.18.tar.xz
RUN cd Python-2.7.18 &&\
    export KERNEL_BITS=$(getconf LONG_BIT) &&\
    ./configure --prefix=/usr/local --enable-shared \
                --enable-optimizations --with-lto \
                --with-ensurepip=install \
                --with-openssl=/usr/local \
                --enable-ipv6 \
                LDFLAGS="-Wl,--rpath=/usr/local/lib -Wl,--rpath=/usr/local,--rpath=\$\$ORIGIN,--rpath=\$\$ORIGIN/../lib" &&\
    make -j 1 &&\
    make altinstall altmaninstall -j $(nproc) &&\
    ldconfig &&\
    /usr/local/bin/python2.7 -m ensurepip --default-pip &&\
    update-alternatives --install /usr/bin/python python /usr/bin/python3 90 &&\
    update-alternatives --install /usr/bin/python python /usr/local/bin/python2.7 10
#RUN /usr/local/bin/python2.7/bin/pip install --upgrade setuptools pip
