#!/bin/sh
#For example:
#./disassembling.sh libanw.21.so 00000928

TOOLSPATH="./android-ndk-r11c/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin"
export PATH=$PATH:$TOOLSPATH
#OBJPATH="./6.9.30.90/$1"
#OBJPATH="/home/user/source/ndk/miplayer_9_18/jni/libs/armeabi-v7a/$1"
#OBJPATH="/home/user/source/ndk/miplayer_9_18/jni/obj/local/armeabi-v7a/$1"
#OBJPATH="/home/user/source/ndk/miplayer_12_29/jni/obj/local/armeabi-v7a/$1"
#OBJPATH="/home/user/source/ndk/7.8.11.465/symbol/$1"
OBJPATH="/home/user/source/ndk/miplayer_latest/jni/obj/local/armeabi-v7a/$1"

echo "$OBJPATH $2"
arm-linux-androideabi-addr2line -Cfe $OBJPATH $2
