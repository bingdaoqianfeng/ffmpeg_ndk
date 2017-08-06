checkfail()
{
    if [ ! $? -eq 0 ];then
        echo "$1"
        exit 1
    fi
}

. setenv.sh

if [ ! -d "x264" ]; then
    echo "X264 source not found, cloning"
        git clone git://git.videolan.org/x264.git
        checkfail "x264 source: git clone failed"
else
    echo "x264 source found"
fi

cd ./x264

SOURCE=`pwd`
DEST=$SOURCE/build/android
echo "SOURCE:   $SOURCE"
echo "DEST:     $DEST"

./configure --cross-prefix=$CROSS_PREFIX \
--sysroot="$SYSROOT" \
--host=arm-linux \
--prefix=$PREFIX \
--enable-pic \
--enable-static \
--extra-cflags="-fPIE -pie" \
--extra-ldflags="-fPIE -pie" \
--disable-cli

make -j4
#make DESTDIR=$DESTDIR prefix=$PREFIX install
make  install
