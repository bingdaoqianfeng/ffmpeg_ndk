#!/bin/bash
. setenv.sh

echo "-----------------------clean sox-------------------"
cd sox
make clean
cd ..

echo "----------------------clean x264------------------"
cd x264
cd ..

echo "----------------------clean freetype2-------------------"
cd freetype2
cd ..

echo "----------------------clean ffmpeg-2.3.6-------------------"
cd ffmpeg-2.3.6
cd ..

echo "-------------------clean end---------------------"
