. setenv.sh
cd ./x264

SOURCE=`pwd`
DEST=$SOURCE/build/android
echo "SOURCE:   $SOURCE"
echo "DEST:     $DEST"

./configure --cross-prefix=$CROSS_PREFIX \
--sysroot="$SYSROOT" \
--host=arm-linux \
--enable-pic \
--enable-static \
--extra-cflags="-fPIE -pie" \
--extra-ldflags="-fPIE -pie" \
--disable-cli

make -j4
#make DESTDIR=$DEST prefix=$prefix install
