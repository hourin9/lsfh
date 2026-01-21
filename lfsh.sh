#!/bin/bash

make_dir() {
    mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
    for i in bin lib sbin; do
        ln -sv usr/$i $LFS/$i
    done

    mkdir -pv $LFS/{tools,src}

    case $(uname -m) in
        x86_64) mkdir -pv $LFS/lib64 ;;
    esac
}

ready() {
    export LFS=/mnt/lfs
    export LC_ALL=C
    export LFS_TGT=$(uname -m)-lfs-linux-gnu
    export CONFIG_SITE=$LFS/usr/share/config.site
    export MAKEFLAGS=-j$(nproc)
}

_install() {
    if [ -e $LFS/repo/$1 ]; then
        source "$LFS/repo/$1"
    elif [ -e $LFS/repo/$1.sh ]; then
        source "$LFS/repo/$1.sh"
    else
        echo "Package $1 not found"
        exit 1
    fi

    pushd "$LFS/src/" > /dev/null
        if [ -n "$URL" ]; then
            wget -nc $URL
        fi
        ( unpack )
        ( pkg_build )
        ( pkg_install )
    popd > /dev/null
}

install() {
    set -e

    local total=0
    for i in $@; do
        local start=$(date +%s)
        _install "$i"
        local end=$(date +%s)
        local build_time=$(($end - $start))
        total=$(($total+$build_time))
    done

    for i in $@; do
        printf "%s " $i
    done
    printf "took %dm %ds\n" $((total/60)) $((total%60))
}

check() {
    if [ -z "$LFS" ]; then
        exit 1
    fi

    if [ "$EUID" -eq 0 ]; then
        exit 2
    fi

    exit 0
}

mount_vfs() {
    if [ -z "$LFS" ]; then
        exit 1
    fi

    mkdir -pv $LFS/{dev,proc,sys,run}

    mount -v --bind /dev $LFS/dev
    mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
    mount -vt proc proc $LFS/proc
    mount -vt sysfs sysfs $LFS/sys
    mount -vt tmpfs tmpfs $LFS/run

    if [ -h $LFS/dev/shm ]; then
        install -v -d -m 1777 $LFS$(realpath /dev/shm)
    else
        mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
    fi
}

chroot() {
    if [ -z "$LFS" ]; then
        exit 1
    fi

    command chroot "$LFS" /usr/bin/env -i \
        HOME=/root \
        TERM="$TERM" \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/usr/bin:/usr/sbin \
        MAKEFLAGS="-j$(nproc)" \
        TESTSUITEFLAGS="-j$(nproc)" \
        /bin/bash --login
}

func=$1; shift; $func "$@"

