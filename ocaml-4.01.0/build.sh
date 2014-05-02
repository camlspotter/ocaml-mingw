#!/bin/sh

set -e

/bin/rm -rf _build
mkdir _build
cd _build
tar jxf ../ocaml-4.01.0.tar.bz2
cd ocaml-4.01.0
patch -p1 < ../../patch
patch -p1 < ../../patch-static-libgcc
make -f Makefile.nt world opt opt.opt install
