#/bin/bash
logname=logdir/lyx.log
rm $logname
adb logcat -c
sleep 1
adb logcat -v threadtime >$logname

#grep -RnE "MiPlayer|VLC|ffmpeg|ANR|XiaomiPlayerJNI|DuoKanVideoView|MediaPlayerWrapper|DuoKanPlayer|"
#adb logcat -v threadtime| grep -E "MiPlayer|VLC|ffmpeg|XiaomiPlayerJNI|DuoKanVideoView|MediaPlayerWrapper|DuoKanPlayer"
#adb logcat -v threadtime| grep -E "MiPlayer|MiCore|ffmpeg|XiaomiPlayerJNI|DuoKanVideoView|MediaPlayerWrapper|DuoKanPlayer"
#adb logcat -v threadtime| grep -E "MiPlayer|MiCore|ffmpeg"


#sh -x SystemMonkeyDeviceTest.sh 72000 &
