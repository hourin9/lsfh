NAME=coreutils
VERSION=9.7
URL="https://ftp.gnu.org/gnu/$NAME/$NAME-$VERSION.tar.xz"

unpack() {
    tar xf "$NAME-$VERSION.tar.xz"
}

pkg_build() {
    cd $NAME-$VERSION

    mkdir -pv build && cd build
    ../configure \
        --prefix=/usr \
        --host=$LFS_TGT \
        --build=$(../build-aux/config.guess) \
        --enable-install-program=hostname \
        --enable-no-install-program=kill,uptime

    make
}

pkg_install() {
    cd "$NAME-$VERSION/build"
    make DESTDIR=$LFS install

    mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1 \
        $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
}

