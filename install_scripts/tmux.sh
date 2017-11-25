#!/bin/bash
#
#    tmux installer
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

bash $ROOT/install_scripts/libevent.sh
bash $ROOT/install_scripts/ncurses.sh
bash $ROOT/install_scripts/newt.sh

TMP_DIR=$ROOT/tmp
REPO_URL=https://github.com/tmux/tmux
TAG=$(git ls-remote --tags $REPO_URL | awk -F/ '{print $3}' | grep -v '{}' | sort -V | tail -n1)
FOLDER="tmux-$(echo $TAG | sed 's/v//')"
INSTALLED_VERSION=$(tmux -V | cut -d' ' -f2)

if [ ! -z $REINSTALL ] || [ -z $INSTALLED_VERSION ] || [ $TAG != $INSTALLED_VERSION ]; then
  echo "tmux $TAG installation.. pwd: $PWD, root: $ROOT"

  mkdir -p $TMP_DIR && cd $TMP_DIR

  curl -LO ${REPO_URL}/archive/${TAG}.zip
  unzip -q ${TAG}.zip
  cd $FOLDER
  ./autogen.sh && ./configure --prefix=$HOME/.local
  make -j$(nproc) && make install

  cd $ROOT && rm -rf $TMP_DIR
else
  echo "tmux $INSTALLED_VERSION is already installed"
fi

cd $ROOT
