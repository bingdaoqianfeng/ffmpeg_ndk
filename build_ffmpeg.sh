#!/bin/bash
. setenv.sh
cd ./ffmpeg-2.3.6

CFLAGS="-std=c99 -O3 -Wall -pipe -fpic \
  -fstrict-aliasing -Werror=strict-aliasing \
  -Wno-psabi -Wa,--noexecstack \
  -DANDROID -DNDK_BUILD -DNDEBUG "
LDFLAGS="-lm -lz -llog -fPIC -Wl,--no-undefined -Wl,-z,noexecstack -Wl,--warn-shared-textrel"

FFMPEG_FLAGS_COMMON="--target-os=linux \
    --enable-cross-compile \
    --cross-prefix=$CROSS_PREFIX \
    --prefix=$PREFIX \
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
    --disable-protocol=xlvx \
    --disable-armv5te \
    --enable-vfp"

FFMPEG_FLAGS="$FFMPEG_FLAGS_COMMON"

case $TARGET in
    armv8)
        FFMPEG_FLAGS="--arch=aarch64 \
          --disable-runtime-cpudetect \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-march=armv8-a"
        ;;
    neon)
        FFMPEG_FLAGS="--arch=armv7-a \
          --cpu=cortex-a8 \
          --disable-runtime-cpudetect \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=softfp -mvectorize-with-neon-quad -fpic"
        EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
        ;;
    armv7)
        FFMPEG_FLAGS="--arch=armv7-a \
          --cpu=cortex-a8 \
          --enable-openssl \
          --disable-runtime-cpudetect \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp"
        EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
        ;;
    vfp)
        FFMPEG_FLAGS="--arch=arm \
          --disable-runtime-cpudetect \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-march=armv6 -mfpu=vfp -mfloat-abi=softfp"
        EXTRA_LDFLAGS=""
        ;;
    armv6)
        FFMPEG_FLAGS="--arch=arm \
          --disable-runtime-cpudetect \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-march=armv6 -msoft-float"
        EXTRA_LDFLAGS=""
        ;;
    x86)
        FFMPEG_FLAGS="--arch=x86 \
          --cpu=i686 \
          --enable-runtime-cpudetect
          --enable-openssl \
          --enable-yasm \
          --disable-amd3dnow \
          --disable-amd3dnowext \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-march=atom -msse3 -ffast-math -mfpmath=sse"
        ;;
    x86_64)
        FFMPEG_FLAGS="--arch=x86_64 \
          --cpu=amd64 \
          --enable-runtime-cpudetect
          --enable-openssl \
          --enable-yasm \
          --disable-amd3dnow \
          --disable-amd3dnowext \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-march=atom -msse3 -ffast-math -mfpmath=sse"
        ;;
    mips)
        FFMPEG_FLAGS="--arch=mips \
          --cpu=mips32r2 \
          --enable-runtime-cpudetect \
          --enable-openssl \
          --enable-yasm \
          --disable-mipsfpu \
          --disable-mipsdspr1 \
          --disable-mipsdspr2 \
          $FFMPEG_FLAGS"
        EXTRA_CFLAGS="-fno-strict-aliasing -fmessage-length=0 -fno-inline-functions-called-once -frerun-cse-after-loop -frename-registers"
        ;;
    *)
        FFMPEG_FLAGS=""
        EXTRA_CFLAGS=""
        EXTRA_LDFLAGS=""
        ;;
esac

rm -rf $PREFIX && mkdir -p $PREFIX
./configure $FFMPEG_FLAGS --extra-cflags="$CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$LDFLAGS $EXTRA_LDFLAGS" 
make clean
find . -name "*.o" -type f -delete
make -j4 || exit 1
#make DESTDIR=$DESTDIR prefix=$PREFIX install
make install
#rm libavcodec/log2_tab.o libavformat/log2_tab.o libswscale/log2_tab.o libavformat/golomb_tab.o

LD_SONAME="-Wl,-soname,libffmpeg-miplayer.so"

case $CROSS_PREFIX in
    aarch64-*)
          $CC -o $PREFIX/libffmpeg.so -shared $LDFLAGS $LD_SONAME $EXTRA_LDFLAGS \
          libavutil/*.o libavutil/aarch64/*.o libavcodec/*.o libavcodec/aarch64/*.o libavcodec/neon/*.o libavformat/*.o libavresample/*.o libavresample/aarch64/*.o libswscale/*.o compat/*.o -lssl_static -lcrypto_static
        ;;
    arm-*)
    $CC -o $PREFIX/libffmpeg.so -shared $LDFLAGS $LD_SONAME $EXTRA_LDFLAGS \
          libavutil/*.o libavutil/arm/*.o libavcodec/*.o libavcodec/arm/*.o libavformat/*.o libavresample/*.o libavresample/arm/*.o libswscale/*.o compat/*.o
        ;;
    i686-*)
        $CC -o $PREFIX/libffmpeg.so -shared $LDFLAGS $LD_SONAME $EXTRA_LDFLAGS \
          libavutil/*.o libavutil/x86/*.o libavcodec/*.o libavcodec/x86/*.o libavformat/*.o libswscale/*.o libswscale/x86/*.o compat/*.o -lssl_static -lcrypto_static
        ;;
    x86_64-*)
        $CC -o $PREFIX/libffmpeg.so -shared $LDFLAGS $LD_SONAME $EXTRA_LDFLAGS \
          libavutil/*.o libavutil/x86/*.o libavcodec/*.o libavcodec/x86/*.o libavformat/*.o libswscale/*.o libswscale/x86/*.o compat/*.o -lssl_static -lcrypto_static
        ;;
    mipsel-*)
        $CC -o $PREFIX/libffmpeg.so -shared $LDFLAGS $LD_SONAME $EXTRA_LDFLAGS \
          libavutil/*.o libavutil/mips/*.o libavcodec/*.o libavcodec/mips/*.o libavformat/*.o libswscale/*.o compat/*.o -lssl_static -lcrypto_static
        ;;
esac

cp $PREFIX/libffmpeg.so $PREFIX/libffmpeg-unstrip.so
${STRIP} --strip-unneeded $PREFIX/libffmpeg.so
mv $PREFIX/libffmpeg.so $PREFIX/libffmpeg-miplayer.so

echo "----------------------$TARGET -----------------------------"

