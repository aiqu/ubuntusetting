#!/usr/bin/env bash
#
#    LAPACK installer
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
PWD=$(pwd)
. $ROOT/envset.sh

if [ -z $SKIPDEPS ];then
  . $ROOT/install_scripts/openblas.sh
fi

PKG_NAME="lapack"
FOLDER="$PKG_NAME*"
REPO_URL="https://github.com/Reference-LAPACK/lapack-release"
DOWN_URL="http://www.netlib.org/lapack"
TAG=$(git ls-remote $REPO_URL | grep 'heads' | awk -F/ '{print$3}' | sort -V | tail -n1)
CUSTOMTAGNAME="${PKG_NAME}TAG"
TAG=${!CUSTOMTAGNAME:-$TAG}
VER=$(echo $TAG | sed 's/lapack-//')
VERFILE=""
INSTALLED_VERSION=
if $(pkg-config --exists $PKG_NAME);then
  INSTALLED_VERSION=$(pkg-config --modversion $PKG_NAME)
fi

if ([ ! -z $REINSTALL ] && [ $LEVEL -le $REINSTALL ]) || [ -z $INSTALLED_VERSION ] || $(compare_version $INSTALLED_VERSION $VER); then
  iecho "$PKG_NAME $VER installation.. install location: $LOCAL_DIR"

  mkdir -p $TMP_DIR && cd $TMP_DIR
  curl --retry 10 -L $DOWN_URL/$TAG.tar.gz | tar xz
  cd $FOLDER
  mkdir -p build && cd build
  CMAKE_OPTIONS=" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR} \
    -DUSE_OPTIMIZED_BLAS=ON \
    -DCBLAS=ON \
    "
  BUILDSTATIC="${PKG_NAME}STATIC"
  if [ ! -z ${!BUILDSTATIC} ];then
    CMAKE_OPTIONS="$CMAKE_OPTIONS -DBUILD_SHARED_LIBS=OFF -DBLA_STATIC=ON"
  else
    CMAKE_OPTIONS="$CMAKE_OPTIONS -DBUILD_SHARED_LIBS=ON"
  fi
  cmake $CMAKE_OPTIONS ..
  make -s -j${NPROC}
  make -s install 1>/dev/null

  cd $ROOT && rm -rf $TMP_DIR
else
  gecho "$PKG_NAME $VER is already installed"
fi

LEVEL=$(( ${LEVEL}-1 ))
cd $ROOT
