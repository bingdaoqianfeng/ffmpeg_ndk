#!/bin/bash

FFMPEG_ROOT=`pwd`

# Detect OS
OS=`uname`
HOST_ARCH=`uname -m`
export CCACHE=; type ccache >/dev/null 2>&1 && export CCACHE=ccache
if [ $OS == 'Linux' ]; then
  export HOST_SYSTEM=linux-$HOST_ARCH
elif [ $OS == 'Darwin' ]; then
  export HOST_SYSTEM=darwin-$HOST_ARCH
fi

platform="$1"
version_type="$2"

SOURCE=`pwd`
DEST=$SOURCE/build/android

TOOLCHAIN=/tmp/ffmpeg
SYSROOT=$TOOLCHAIN/sysroot/

function arm_toolchain()
{
  export CROSS_PREFIX=arm-linux-androideabi-
  $ANDROID_NDK/build/tools/make-standalone-toolchain.sh --toolchain=${CROSS_PREFIX}4.9 \
    --install-dir=$TOOLCHAIN
}


if [ "$platform" = "armv8" ];then
  echo "Build Android armv8 ffmpeg\n"
  armv8_toolchain
  TARGET="armv8"
else
  echo "Build Android arm ffmpeg\n"
  arm_toolchain
  TARGET="neon"
#  TARGET="neon armv7 vfp armv6"
fi
export PATH=$TOOLCHAIN/bin:$PATH
export CC="$CCACHE ${CROSS_PREFIX}gcc"
export CXX=${CROSS_PREFIX}g++
export LD=${CROSS_PREFIX}ld
export AR=${CROSS_PREFIX}ar
export STRIP=${CROSS_PREFIX}strip


CFLAGS="-std=c99 -O3 -Wall -pipe -fpic \
  -fstrict-aliasing -Werror=strict-aliasing \
  -Wno-psabi -Wa,--noexecstack \
  -DANDROID -DNDK_BUILD -DNDEBUG "

LDFLAGS="-lm -lz -llog -fPIC -Wl,--no-undefined -Wl,-z,noexecstack -Wl,--warn-shared-textrel"

FFMPEG_FLAGS_COMMON="--target-os=linux \
    --enable-cross-compile \
    --cross-prefix=$CROSS_PREFIX \
    --prefix=$FFMPEG_ROOT\build \
    --enable-version3 \
    --disable-shared \
 --enable-static \
 --disable-debug \
 --disable-ffplay \
 --disable-ffprobe \
 --disable-ffserver \
 --enable-avfilter \
 --enable-decoders \
 --enable-demuxers \
 --enable-encoders \
 --enable-filters \
 --enable-indevs \
 --enable-network \
 --enable-parsers \
 --enable-protocols \
 --enable-swscale \
 --enable-avresample \
 --enable-gpl \
 --enable-nonfree \
--enable-protocols \
--disable-doc \
--disable-demuxer=bluray \
--disable-decoder=opus \
--disable-armv5te
    --disable-protocol=xlvx \
    --enable-vfp"

    cd $SOURCE

    FFMPEG_FLAGS="$FFMPEG_FLAGS_COMMON"

        FFMPEG_FLAGS="--arch=armv7-a \
          --cpu=cortex-a8 \
          --disable-runtime-cpudetect \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=softfp -mvectorize-with-neon-quad -fpic"
        EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"

    PREFIX="$DEST/$version" && rm -rf $PREFIX && mkdir -p $PREFIX
    FFMPEG_FLAGS="$FFMPEG_FLAGS --prefix=$PREFIX"

    ./configure $FFMPEG_FLAGS --extra-cflags="$CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$LDFLAGS $EXTRA_LDFLAGS" | tee $PREFIX/configuration.txt
    cp config.* $PREFIX
    [ $PIPESTATUS == 0 ] || exit 1

    make clean
    find . -name "*.o" -type f -delete
    make -j4 || exit 1

    make install

    rm libavcodec/log2_tab.o libavformat/log2_tab.o libswscale/log2_tab.o libavformat/golomb_tab.o

    LD_SONAME="-Wl,-soname,libffmpeg-miplayer.so"

    $CC -o $PREFIX/libffmpeg.so -shared $LDFLAGS $LD_SONAME $EXTRA_LDFLAGS \
          libavutil/*.o libavutil/arm/*.o libavcodec/*.o libavcodec/arm/*.o  compat/*.o libavformat/*.o libavresample/*.o libavresample/arm/*.o libswscale/*.o

    cp $PREFIX/libffmpeg.so $PREFIX/libffmpeg-unstrip.so
    ${STRIP} --strip-unneeded $PREFIX/libffmpeg.so
    mv $PREFIX/libffmpeg.so $PREFIX/libffmpeg-miplayer.so

    echo "----------------------$version -----------------------------"

