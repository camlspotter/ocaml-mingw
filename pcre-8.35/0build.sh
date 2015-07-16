#!/bin/sh

./configure --host=i686-w64-mingw32 --prefix=/cygdrive/c/ocamlmgw/ext/ --disable-static
make clean
make 
make install
