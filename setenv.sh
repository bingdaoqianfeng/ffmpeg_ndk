#!/bin/bash

# export ANDROID_NDK=
# Detect ANDROID_NDK
if [ -z "$ANDROID_NDK" ]; then
  echo "You must define ANDROID_NDK before starting."
  echo "They must point to your NDK directories.\n"
  exit 1
fi

# Detect OS
OS=`uname`
HOST_ARCH=`uname -m`
export CCACHE=; type ccache >/dev/null 2>&1 && export CCACHE=ccache
if [ $OS == 'Linux' ]; then
  export HOST_SYSTEM=linux-$HOST_ARCH
elif [ $OS == 'Darwin' ]; then
  export HOST_SYSTEM=darwin-$HOST_ARCH
fi
echo "HOST_SYSTEM:  $HOST_SYSTEM"

platform="$1"
TOOLCHAIN=/tmp/ffmpeg
SYSROOT=$TOOLCHAIN/sysroot/

function arm_toolchain()
{
  export CROSS_PREFIX=arm-linux-androideabi-
  $ANDROID_NDK/build/tools/make-standalone-toolchain.sh --toolchain=${CROSS_PREFIX}4.9 \
    --install-dir=$TOOLCHAIN
}

function armv8_toolchain()
{
  export CROSS_PREFIX=aarch64-linux-android-
  $ANDROID_NDK/build/tools/make-standalone-toolchain.sh --toolchain=${CROSS_PREFIX}4.9 \
    --install-dir=$TOOLCHAIN
}

function x86_toolchain()
{
  $ANDROID_NDK/build/tools/make-standalone-toolchain.sh --toolchain=x86-4.9 \
    --install-dir=$TOOLCHAIN
}

function x86_64_toolchain()
{
  export CROSS_PREFIX=x86_64-linux-android-
  $ANDROID_NDK/build/tools/make-standalone-toolchain.sh --toolchain=x86_64-4.9 \
    --install-dir=$TOOLCHAIN
}

function mips_toolchain()
{
  export CROSS_PREFIX=mipsel-linux-android-
  $ANDROID_NDK/build/tools/make-standalone-toolchain.sh --toolchain=${CROSS_PREFIX}4.9 \
    --install-dir=$TOOLCHAIN
}

if [ "$platform" = "x86" ];then
  echo "Build Android x86 ffmpeg\n"
  x86_toolchain
  TARGET="x86"
  HOST=i686-linux-android
else
  echo "Build Android arm ffmpeg\n"
  arm_toolchain
  TARGET="neon"
  HOST=arm-linux-androideabi
#  TARGET="neon armv7 vfp armv6"
fi
echo "HOST:     $HOST"
export PATH=$TOOLCHAIN/bin:$PATH
#export CC="$CCACHE ${CROSS_PREFIX}gcc"
export CC=${CROSS_PREFIX}gcc
export CXX=${CROSS_PREFIX}g++
export LD=${CROSS_PREFIX}ld
export AR=${CROSS_PREFIX}ar
export STRIP=${CROSS_PREFIX}strip
echo "CC:       $CC"
echo "CXX:      $CXX"
echo "LD:       $LD"
echo "AR:       $AR"
echo "STRIP:    $STRIP"
echo "PATH:     $PATH"
echo "TARGET:   $TARGET"

# install root for built files
DESTDIR=`pwd`
PREFIX=$DESTDIR/data/data/info.guardianproject.ffmpeg/app_opt
