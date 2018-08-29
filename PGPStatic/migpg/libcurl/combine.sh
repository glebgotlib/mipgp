#!/bin/sh

LIBS=(libcurl.a)
DEFAULTARCHS=(x86_64 i386 arm64 armv7s armv7)
LIBDIR="libs-arm"
INCDIR="inc"

[[ ! -d ${LIBDIR} ]] && mkdir ${LIBDIR}
rm -f $LIBDIR/*


for i in ${LIBS[@]}; do
    LD=""
    for j in ${DEFAULTARCHS[@]}; do
         LD="${LD} ${j}/lib/${i}"
    done
    echo ${LD}
    lipo -create ${LD} -output $LIBDIR/${i}
done
