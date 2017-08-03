#!/bin/bash
#git clone https://github.com/guardianproject/sox.git
#need to install "sudo apt-get install autoconf automake libtool"
. setenv.sh

cd sox

if [[ $DEBUG == 1 ]]; then
    echo "DEBUG = 1"
    DEBUG_FLAG="--disable-stripping"
fi

patch -N -p1 --reject-file=- < ../sox-update-ffmpeg-api.patch
autoreconf --install --force --verbose

confcommon="CC=$CC \
LD=$LD \
STRIP=$STRIP \
--host=$HOST \
--with-sysroot=$SYSROOT \
--enable-static \
--disable-shared \
--with-ffmpeg \
--with-pic \
--without-libltdl"

echo "confcommon:   $confcommon"
./configure $confcommon CFLAGS="-I$LOCAL/include -fPIE -pie" LDFLAGS="-L$LOCAL/lib -L$DESTDIR/x264 -fPIE -pie" LIBS="-lavformat -lavcodec -lavutil -lz -lx264"

make -j4
make STRIP=$STRIP DESTDIR=$DESTDIR prefix=$prefix install-strip
