#!/bin/bash
#git clone git://git.sv.gnu.org/freetype/freetype2.git
#Or download stable release from https://www.freetype.org/download.html.
#need to install "sudo apt-get install autoconf automake libtool"
checkfail()
{
    if [ ! $? -eq 0 ];then
        echo "$1"
        exit 1
    fi
}
. setenv.sh

if [ ! -d "freetype2" ]; then
    echo "freetype2 source not found, cloning"
    git clone git://git.sv.gnu.org/freetype/freetype2.git
    checkfail "freetype2 source: git clone failed"
else
    echo "freetype2 source found"
fi

cd freetype2

./autogen.sh

confcommon="CC=$CC \
LD=$LD \
--host=$HOST \
--with-sysroot=$SYSROOT \
--prefix=$PREFIX \
--enable-static \
--disable-shared \
--with-pic \
--without-bzip2"

echo "confcommon:   $confcommon"
./configure $confcommon CFLAGS="-std=gnu99 -mcpu=cortex-a8 -marm -mfloat-abi=softfp -mfpu=neon -fPIE -pie"

make -j4
make install
