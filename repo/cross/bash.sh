NAME=bash
VERSION=5.3
URL="https://ftp.gnu.org/gnu/$NAME/$NAME-$VERSION.tar.gz"

unpack() {
    tar xf "$NAME-$VERSION.tar.gz"
}

pkg_build() {
    cd $NAME-$VERSION

    mkdir -pv build && cd build
    ../configure --prefix=/usr \
            --build=$(sh ../support/config.guess) \
            --host=$LFS_TGT \
            --without-bash-malloc

    make
}

pkg_install() {
    cd "$NAME-$VERSION/build"
    make DESTDIR=$LFS install
    ln -sv bash $LFS/bin/sh
}

