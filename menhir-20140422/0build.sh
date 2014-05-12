#!/bin/sh
export PREFIX=`cygpath -m $PREFIX`
make
ocamlfind remove menhirLib
rm $PREFIX/bin/mehir.exe
make install
