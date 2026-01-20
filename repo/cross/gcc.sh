#!/bin/bash
NAME=gcc
VERSION=15.2.0
URL="https://ftp.gnu.org/gnu/gcc/gcc-$VERSION/gcc-$VERSION.tar.xz"

unpack() {
    tar xf "$NAME-$VERSION.tar.xz"

    cd "$NAME-$VERSION"

    # Set default directory name for 64bit libraries to lib.
    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' \
                -i.orig gcc/config/i386/t-linux64
        ;;
    esac
}

pkg_build() {
    cd "$NAME-$VERSION"

    # If I extract then copy then mpfr will fail
    # due to autoconf something something, so I have
    # to extract it here and rename.
    tar -xf ../mpfr-4.2.2.tar.xz
    mv -v mpfr-4.2.2 mpfr
    tar -xf ../gmp-6.3.0.tar.xz
    mv -v gmp-6.3.0 gmp
    tar -xf ../mpc-1.3.1.tar.gz
    mv -v mpc-1.3.1 mpc

    mkdir -pv build && cd build
    ../configure \
        --target=$LFS_TGT \
        --prefix=$LFS/tools \
        --with-sysroot=$LFS \
        --with-glibc-version=2.42 \
        --with-newlib \
        --without-headers \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-nls \
        --disable-shared \
        --disable-multilib \
        --disable-threads \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libvtv \
        --disable-libstdcxx \
        --enable-languages=c,c++

    make
}

pkg_install() {
    cd "$NAME-$VERSION"/build/
    make install
}

