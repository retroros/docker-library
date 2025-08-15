# Configure build arguments
ARG XZ_DEFAULTS="-T0"


# Consider 'double' building python a second time after a 'distclean'
# without the shared library so that it runs with a static library by
# default for better performance while preserving the shared libraries
# if they are needed by other programs

# Adding in the latest Python3
ARG PYTHON_VERSION=3.13.7
ADD http://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz .
RUN tar -xf Python-${PYTHON_VERSION}.tar.xz && rm Python-${PYTHON_VERSION}.tar.xz
RUN INSTALL_VERSION=$(cut -d '.' -f 1,2 <<< ${PYTHON_VERSION} &&\
    cd Python-${PYTHON_VERSION} &&\
    export KERNEL_BITS=$(getconf LONG_BIT) &&\
    ./configure --prefix=/usr/local --enable-shared \
                --enable-optimizations --with-lto=full \
                --enable-bolt \
                --disable-gil \
                --enable-experimental-jit=yes \
                --with-ensurepip=install \
                LDFLAGS="-Wl,--rpath=/usr/local/lib -Wl,--rpath=/usr/local,--rpath=\$\$ORIGIN,--rpath=\$\$ORIGIN/../lib" &&\
    make -j $(nproc) &&\
    make altinstall altmaninstall -j $(nproc) &&\
    ldconfig &&\
    /usr/local/bin/python${INSTALL_VERSION} -m ensurepip --default-pip
RUN INSTALL_VERSION=$(cut -d '.' -f 1,2 <<< ${PYTHON_VERSION} &&\
    update-alternatives --install /usr/bin/python python /usr/local/bin/python${INSTALL_VERSION} 70
#    --slave /usr/share/man/man1/python.1.gz python.1.gz /usr/share/man/man1/python.1.gz
#    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3 90 \
#    update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.13 70
#RUN /usr/local/bin/python3.13/bin/pip install --upgrade setuptools pip
