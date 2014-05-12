#!/bin/sh

set -e
cd omake-0.9.8.6-svn-13270
make bootstrap
rm -f .config
PREFIX=c:/ocamlmgw make all install



