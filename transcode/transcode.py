#!/usr/bin/python
import os
import os.path
import sys
import getopt

def help():
    print \
    '''
    -----------------------------------------------------------------
    -i: input media file
    ------------------------------------------------------------------
    -o: ouput directory
    ------------------------------------------------------------------
    -s: segment file name
    ------------------------------------------------------------------
    -t: media type. f.q: mp4, mkv
    ------------------------------------------------------------------
    For example:
    ./transcode.sh -i ./media/XiaomiPhone.mp4 -o output/ -s ./segment_duraton.txt  -t mkv
    ------------------------------------------------------------------
    '''

def main():
    reload(sys)
    sys.setdefaultencoding('utf-8')
    opts, args = getopt.getopt(sys.argv[1:], "i:o:l:h")
    for op, value in opts:
        if op == '-i':
            input_file_name = value
        elif op == '-o':
            output_dir = value
        elif op == '-s':
            configure_file_name = value
        elif op == '-t':
            file_type = value
        elif op == "-h":
            help()
            sys.exit()
    help()
if __name__ == '__main__':
    main()

