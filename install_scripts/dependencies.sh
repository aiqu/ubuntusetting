#!/bin/bash

set -e

DEPENDENCIES_DONE=

if [ ! $ROOT ];then
    if [ ! -d 'configurations' ];then
        ROOT=$(pwd)/..
    else
        ROOT=$(pwd)
    fi
fi

. $ROOT/envset.sh

echo "Dependencies installation.. pwd: $PWD, root: $ROOT"

if [ $OS == "ubuntu" ]; then
    PKG_LIST="build-essential \
        cmake \
        libncurses5-dev \
        cscope \
        ctags \
        unzip \
        pkg-config \
        autoconf \
        automake \
        dh-autoreconf \
        autotools-dev \
        debhelper \
        libconfuse-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libexpat1-dev \
        openssh-server \
        asciidoc \
        xmlto \
        docbook2x \
        byobu \
        "
    ${SUDO} apt update
    ${SUDO} apt install -y $PKG_LIST
elif [ $OS == "centos" ];then
    ${SUDO} yum install -y epel-release
    ${SUDO} yum update -y
    ${SUDO} yum groupinstall -y "Development Tools"
    PKG_LIST="\
        cmake \
        ncurses-libs \
        cscope \
        ctags \
        unzip \
        pkgconfig \
        autoconf \
        automake \
        libconfuse-devel \
        openssl-devel openssl-libs \
        curl-devel libcurl \
        expat-devel \
        gettext-devel \
        zlib-devel \
        openssh-server \
        asciidoc \
        xmlto \
        docbook2X \
        perl-ExtUtils-MakeMaker \
        readline \
        bzip2-devel \
        readline-devel \
        libsqlite3x-devel \
        byobu \
        "
    ${SUDO} yum install -y ${PKG_LIST}
elif [ $OS == "mac" ]; then
    set +e
    which -s brew
    if [ $? != 0 ];then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        brew update
    fi
    PKG_LIST="cmake \
        ncurses \
        cscope \
        ctags \
        unzip \
        pkg-config \
        autoconf \
        automake \
        confuse \
        coreutils \
        curl \
        openssl \
        expat \
        openssh \
        gettext \
        asciidoc \
        xmlto \
        docbook2x \
        "
    for pkg in $PKG_LIST;do
        version=`brew ls --versions $pkg`
        if [ $? -eq 1 ];then
            PKG_I+="$pkg "
            echo "Cannot find $pkg"
        else
            PKG_U+="$pkg "
            echo "Found $version"
        fi
    done
    if [ "$PKG_I" ];then
        brew install $PKG_I
    fi
    if [ "$PKG_U" ];then
        brew upgrade $PKG_U
    fi

    brew link --force gettext

    set -e
fi

DEPENDENCIES_DONE=1
