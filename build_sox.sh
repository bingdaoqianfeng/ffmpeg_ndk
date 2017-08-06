#!/bin/bash
#git clone https://github.com/guardianproject/sox.git
#need to install "sudo apt-get install autoconf automake libtool"
eckfail()
{
    if [ ! $? -eq 0 ];then
        echo "$1"
        exit 1
    fi
}

if [ ! -d "sox" ]; then
    echo "sox source not found, cloning"
    git clone https://github.com/guardianproject/sox.git
    checkfail "sox source: git clone failed"
else
    echo "sox source found"
fi

. setenv.sh
cd sox

#patch -N -p1 --reject-file=- < ../sox-update-ffmpeg-api.patch
autoreconf --install --force --verbose

confcommon="CC=$CC \
LD=$LD \
STRIP="$STRIP" \
--prefix=$PREFIX \
--host=$HOST \
--with-sysroot=$SYSROOT \
--enable-static \
--disable-shared \
--with-ffmpeg \
--with-pic \
--without-libltdl"

echo "confcommon:   $confcommon"
./configure $confcommon CFLAGS="-I$PREFIX/include -fPIE -pie" LDFLAGS="-L$PREFIX/lib -L$DESTDIR/x264 -fPIE -pie" LIBS="-lavformat -lavcodec -lavutil -lz -lx264"

make -j4
#make STRIP=$STRIP DESTDIR=$DESTDIR prefix=$prefix install-strip
make install
