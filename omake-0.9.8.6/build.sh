#!/bin/sh

set -e
export CC=i686-w64-mingw32-gcc
tar zxf omake-0.9.8.6-svn-13270.tgz
cd omake-0.9.8.6-svn-13270
patch -p1 < ../patch-aa.github.com_fdopen_godi-repo
make bootstrap
rm -f .config
PREFIX=c:/ocamlmgw make all install



