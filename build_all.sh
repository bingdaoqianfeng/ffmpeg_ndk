#!/bin/bash

function die {
    echo "$1 failed" && exit 1
}

./build_ffmpeg.sh || die "build ffmpeg"

./build_x264.sh || die "build x264"

./build_freetype2.sh || die "build freetype2"

./build_sox.sh || die "build sox"
