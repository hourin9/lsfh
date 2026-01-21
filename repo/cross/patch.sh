NAME=patch
VERSION=2.8
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
        --build=$(../build-aux/config.guess)

    make
}

pkg_install() {
    cd "$NAME-$VERSION/build"
    make DESTDIR=$LFS install
}

