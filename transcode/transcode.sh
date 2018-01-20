#!/bin/sh
#./ffmpeg -i ../media/XiaomiPhone.mp4 -c:v libx264 -c:a aac -ss 00:00:10 -to 00:00:20 ../output/segment.mp4
export LD_LIBRARY_PATH=/usr/local/lib/

SHELL_FOLDER=$(dirname "$0")
FFMPEG=$SHELL_FOLDER/ffmpeg-3.3.3/ffmpeg
INPUT_FILE=$1
OUTPUT_DIR=$2
#SEGMENT_FILE=segment_duraton.txt
SEGMENT_FILE=$3

function helpfunc()
{
    echo ""
    echo "Please input filename, output direoctry and segment file"
    echo "For example:"
    echo "./transcode.sh ./media/XiaomiPhone.mp4 output/ ./segment_duraton.txt"
    echo "FFMPEG=$FFMPEG, INPUT_FILE=$INPUT_FILE, OUTPUT_DIR=$OUTPUT_DIR, SEGMENT_FILE=$SEGMENT_FILE"
    echo ""
}

if [ "$INPUT_FILE" = "" ] || [ "$OUTPUT_DIR" = "" ] || [ "$SEGMENT_FILE" = "" ];then
    helpfunc
    exit 0
fi

echo "FFMPEG=$FFMPEG, INPUT_FILE=$INPUT_FILE, OUTPUT_DIR=$OUTPUT_DIR, SEGMENT_FILE=$SEGMENT_FILE"

for item in `cat segment_duraton.txt | awk '{print $1" "$2" "$3}'`
#for item in `cat segment_duraton.txt | awk '{print $0}'`
do
    echo "$item"
    INPUT_ARGUMENTS=$INPUT_ARGUMENTS"  "$item
done

echo "SINPUT_ARGUMENTS=$INPUT_ARGUMENTS"
FLAG=1
START_TIME=0
END_TIME=0
SEGMENT_NAME="test"
for item in $INPUT_ARGUMENTS
do
    echo "$FLAG  $item"
    case $FLAG in
        1)
            START_TIME=$item
            FLAG=2
            ;;
        2)
            END_TIME=$item
            FLAG=3
            ;;
        3)
            SEGMENT_NAME=$item
            FLAG=1
            echo "$START_TIME   $END_TIME $SEGMENT_NAME $INPUT_FILE"
            FFMPEG_OPTION="-i $INPUT_FILE -c:v libx264 -c:a aac -ss $START_TIME -to $END_TIME $OUTPUT_DIR/$SEGMENT_NAME.mp4"
            echo "$FFMPEG_OPTION"
            $FFMPEG $FFMPEG_OPTION
            ;;
        *)
            ;;
    esac
done

#$FFMPEG -i $INPUT_FILE -c:v libx264 -c:a aac -ss 00:00:10 -to 00:00:20 $OUTPUT_DIR/segment.mp4
