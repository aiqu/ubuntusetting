#!/usr/bin/env bash
#
#    Boost installer
#
#    Copyright (C) 2017 Gwangmin Lee
#    
#    Author: Gwangmin Lee <gwangmin0123@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

FILENAME=`basename ${BASH_SOURCE[0]}`
FILENAME=${FILENAME%%.*}
DONENAME="DONE$FILENAME"
if [ ! -z ${!DONENAME+x} ];then
  return 0
fi
let DONE$FILENAME=1

ROOT=$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)

source $ROOT/envset.sh

PWD=$(pwd)
WORKDIR=$HOME/.lib

_R=$REINSTALL
unset REINSTALL
bash $ROOT/install_scripts/xz.sh
bash $ROOT/install_scripts/cmake.sh
REINSTALL=$_R
unset _R

PKG_NAME="boost"
mkdir -p $WORKDIR && cd $WORKDIR
VER='1.65.1'
VERSTR='1_65_1'
SRCFILE="boost_$VERSTR.tar.bz2"
VERFILE=${LOCAL_DIR}/include/boost/version.hpp
if [ -r $VERFILE ];then
  INSTALLED_VERSION=$(grep 'BOOST_LIB_VERSION "' $VERFILE | cut -d'"' -f2)
fi

if ([ $LEVEL = 0 ] && [ ! -z $REINSTALL ]) || [ $VERSTR != "$INSTALLED_VERSION" ];then
  iecho "$PKG_NAME $VER installation.. install location: $LOCAL_DIR"
  if [ ! -d boost_$VERSTR ];then
    if [ ! -f $SRCFILE ]; then
      iecho "Downloading Boost $VER"
      curl -L https://dl.bintray.com/boostorg/release/$VER/source/$SRCFILE | tar xjf -
    fi
  fi
  cd boost_$VERSTR
  ./bootstrap.sh --prefix=${LOCAL_DIR} --libdir=${LOCAL_DIR}/lib64 --without-libraries=python
  ./b2 -j${NPROC}
  ./b2 install
else
  gecho "$PKG_NAME $VER is already installed"
fi

LEVEL=$(( ${LEVEL}-1 ))
cd $ROOT
