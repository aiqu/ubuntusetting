#!/bin/bash

PYTHONE_DONE=

set -e

if [ ! -d configurations ];then
    ROOT=$(pwd)/..
else
    ROOT=$(pwd)
fi

echo "Python installation.. pwd: $PWD, root: $ROOT"

set -i
. "$HOME/.bashrc"
set +i

echo $PATH

function install_python {
  VER=$1
  WORKDIR="/tmp/tmp_$VER"
  mkdir -p $WORKDIR && cd $WORKDIR
  curl -L https://www.python.org/ftp/python/$VER/Python-$VER.tar.xz | tar xJf -
  cd Python-$VER
  ./configure --prefix=$HOME/.local --enable-shared
  make -j$(nproc)
  make install
  rm -rf $WORKDIR
}

PYTHON2_VER='2.7.13'
PYTHON3_VER='3.6.3'

install_python $PYTHON2_VER
install_python $PYTHON3_VER

pip2 install -U pip
pip3 install -U pip

pip install jupyter jupyterthemes
jt -t grade3 -f source -fs 95 -altp -tfs 11 -nfs 115 -cellw 88% -T

echo "---"
echo "Type \"source $ENVFILE\""

PYTHONE_DONE=1
