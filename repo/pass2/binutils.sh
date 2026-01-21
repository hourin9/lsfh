#!/bin/bash
NAME=binutils
VERSION=2.45
URL="https://ftp.gnu.org/gnu/binutils/$NAME-$VERSION.tar.gz"

unpack() {
    tar xzf "$NAME-$VERSION.tar.gz"

    cd "$NAME-$VERSION"
    sed '6031s/$add_dir//' -i ltmain.sh
}

pkg_build() {
    cd "$NAME-$VERSION"
    mkdir -pv build && cd build
    ../configure \
        --prefix=/usr \
        --build=$(../config.guess) \
        --host=$LFS_TGT \
        --disable-nls \
        --enable-shared \
        --enable-gprofng=no \
        --disable-werror \
        --enable-64-bit-bfd \
        --enable-new-dtags \
        --enable-default-hash-style=gnu

    make
}

pkg_install() {
    cd "$NAME-$VERSION"/build/
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
}

