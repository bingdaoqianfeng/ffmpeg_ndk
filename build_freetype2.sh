#!/bin/bash
#git clone git://git.sv.gnu.org/freetype/freetype2.git
#Or download stable release from https://www.freetype.org/download.html.
#need to install "sudo apt-get install autoconf automake libtool"
. setenv.sh

cd freetype2
#cd freetype-2.8

./autogen.sh

confcommon="CC=$CC \
LD=$LD \
--host=$HOST \
--with-sysroot=$SYSROOT \
--enable-static \
--disable-shared \
--with-pic \
--without-bzip2"

echo "confcommon:   $confcommon"
./configure $confcommon CFLAGS="-std=gnu99 -mcpu=cortex-a8 -marm -mfloat-abi=softfp -mfpu=neon -fPIE -pie"

make -j4
