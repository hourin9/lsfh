#!/bin/bash

echo 'int main(){}' |
    "$LFS/tools/bin/$LFS_TGT-gcc" -x c - -v -Wl,--verbose &> \
    dummy.log

echo "Interpreter"
readelf -l a.out | grep ': /lib'
echo

echo "Start files used"
grep -E -o "$LFS/lib.*/S?crt[1in].*succeeded" dummy.log
echo

echo "Is compiler searching for correct header files"
grep -B3 "^ $LFS/usr/include" dummy.log
echo

echo "Is linker using the correct search paths"
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
echo

echo "Checking lib"
grep "/lib.*/libc.so.6 " dummy.log
echo

echo "Dynamic linker:"
grep found dummy.log
echo

echo "Consult https://www.linuxfromscratch.org/lfs/view/stable/chapter05/glibc.html \
to check the output results"
rm -v a.out dummy.log

