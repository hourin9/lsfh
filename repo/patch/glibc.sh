#!/bin/bash
NAME=glibc
VERSION=2.42
URL="https://www.linuxfromscratch.org/patches/lfs/12.4/glibc-2.42-fhs-1.patch"

unpack() {
    :
}

pkg_build() {
    :
}

pkg_install() {
    mkdir -pv patches
    mv -v glibc-2.42-fhs-1.patch patches/
}

