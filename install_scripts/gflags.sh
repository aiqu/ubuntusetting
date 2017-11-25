#!/bin/bash
#
#    Gflags installer
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

ROOT=$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)

source $ROOT/envset.sh

PWD=$(pwd)
WORKDIR=$HOME/.lib

cd $WORKDIR
if [ ! -d gflags ]; then
  git clone https://github.com/gflags/gflags
fi
cd gflags
TAG=$(git tag | sort -V | tail -n1)
#TAG='v2.1.2'
git checkout $TAG && mkdir -p build && cd build && \
cmake -DCMAKE_INSTALL_PREFIX=$HOME/.local .. && \
make -j$(nproc) && make install
