#!/bin/sh
#./ffmpeg -i ../media/XiaomiPhone.mp4 -c:v libx264 -c:a aac -ss 00:00:10 -to 00:00:20 ../output/segment.mp4
export LD_LIBRARY_PATH=/usr/local/lib/

function helpfunc()
{
    echo ""
    echo "-i: input media file"
    echo "-o: ouput directory"
    echo "-s: segment file name"
    echo "-t: media type. f.q: mp4, mkv"
    echo "For example:"
    echo "./transcode.sh -i ./media/XiaomiPhone.mp4 -o output/ -s ./segment_duraton.txt  -t mkv"
    echo "FFMPEG=$FFMPEG, INPUT_FILE=$INPUT_FILE, OUTPUT_DIR=$OUTPUT_DIR, SEGMENT_FILE=$SEGMENT_FILE, MEDIA_TYPE=$MEDIA_TYPE"
    echo ""
}

while getopts "i:o:s:t:h" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        h)
            helpfunc
            exit 0
            ;;
        i)
            INPUT_FILE=$OPTARG
            ;;
        o)
            OUTPUT_DIR=$OPTARG
            ;;
        s)
            SEGMENT_FILE=$OPTARG
            ;;
        t)
            MEDIA_TYPE=$OPTARG
            ;;
        ?)#当有不认识的选项的时候arg为?
            echo "unkonw argument"
            exit 1
            ;;
    esac
done


SHELL_FOLDER=$(dirname "$0")
FFMPEG=$SHELL_FOLDER/ffmpeg-3.3.3/ffmpeg

if [ "$INPUT_FILE" = "" ];then
    helpfunc
    exit 0
fi

if [ "$MEDIA_TYPE" = "" ];then
    MEDIA_TYPE="mkv"
    echo "set default media type to mkv"
fi

if [ "$SEGMENT_FILE" = "" ];then
    SEGMENT_FILE="segment_duraton.txt"
    echo "set default segment file to segment_duraton.txt"
fi

if [ "$OUTPUT_DIR" = "" ];then
    if [ ! -d "output" ]; then
        mkdir output
    fi
    OUTPUT_DIR="output"
    echo "set default output directory is output"
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
            FFMPEG_OPTION="-i $INPUT_FILE -c:v libx264 -c:a aac -c:s copy -ss $START_TIME -to $END_TIME $OUTPUT_DIR/$SEGMENT_NAME.$MEDIA_TYPE"
            echo "$FFMPEG_OPTION"
            $FFMPEG $FFMPEG_OPTION
            ;;
        *)
            ;;
    esac
done

#$FFMPEG -i $INPUT_FILE -c:v libx264 -c:a aac -ss 00:00:10 -to 00:00:20 $OUTPUT_DIR/segment.mp4
