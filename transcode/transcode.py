#!/usr/bin/python
#import os
#import os.path
import sys
import getopt
import shlex
import datetime
import subprocess
import time

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

def execute_command(cmdstring, cwd=None, timeout=None, shell=False):
    """执行一个SHELL命令
            封装了subprocess的Popen方法, 支持超时判断，支持读取stdout和stderr
           参数:
        cwd: 运行命令时更改路径，如果被设定，子进程会直接先更改当前路径到cwd
        timeout: 超时时间，秒，支持小数，精度0.1秒
        shell: 是否通过shell运行
    Returns: return_code
    Raises:  Exception: 执行超时
    """
    if shell:
        cmdstring_list = cmdstring
    else:
        cmdstring_list = shlex.split(cmdstring)
    if timeout:
        end_time = datetime.datetime.now() + datetime.timedelta(seconds=timeout)

    #没有指定标准输出和错误输出的管道，因此会打印到屏幕上；
    sub = subprocess.Popen(cmdstring_list, cwd=cwd, stdin=subprocess.PIPE,shell=shell,bufsize=4096)

    #subprocess.poll()方法：检查子进程是否结束了，如果结束了，设定并返回码，放在subprocess.returncode变量中 
    while sub.poll() is None:
        time.sleep(0.1)
        if timeout:
            if end_time <= datetime.datetime.now():
                raise Exception("Timeout：%s"%cmdstring)
    return str(sub.returncode)

def main():
    reload(sys)
    sys.setdefaultencoding('utf-8')
    opts, args = getopt.getopt(sys.argv[1:], "i:o:l:(hH)",["help","cmd=","sendfile=","localpath=","remotepath="])
    for op, value in opts:
        if op == '-i':
            input_file_name = value
        elif op == '-o':
            output_dir = value
        elif op == '-s':
            configure_file_name = value
        elif op == '-t':
            file_type = value
        elif op in ("-h","-H","--help"):
            help()
            sys.exit()
        else:
            print "input error"
            help()
            sys.exit()
#    help()
if __name__ == '__main__':
    main()

