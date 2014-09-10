#!/bin/sh

set -e

/bin/rm -rf _build
mkdir _build
cd _build
tar zxf ../ocaml-4.02.0.tar.gz
cd ocaml-4.02.0
cp config/s-nt.h config/s.h
cp config/m-nt.h config.m.h
cp config/Makefile.mingw config/Makefile
# patch -p1 < ../../patch
# patch -p1 < ../../patch-static-libgcc
make -f Makefile.nt world bootstrap opt opt.opt install
