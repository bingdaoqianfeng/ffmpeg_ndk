
KILL="busybox kill"
PGREP="busybox pgrep"
AWK="busybox awk"
exprB="busybox expr"
LOGCAT="logcat -v time "
logfileSz=" -r 61440"
logfileNm=" -n 100"
logfileSv=" -f /sdcard/log/systemlogcat.log"
BLACKLISTFILE=" --pkg-blacklist-file /data/blacklist.txt "
WHITELISTFILE=" --pkg-whitelist-file /data/whitelist.txt "
TimeF="/sdcard/Monkey/Monkey_log"
hour_distance=0
TargetTest=

TestBeginTime=0

function setup()
{
  `busybox mkdir -p $TimeF`
  process="monkey"
  $KILL -9 `$PGREP $process |$AWK '{print $2}'`
}

function runTime()
{
  Test_begin=$1
  Time_test=`date +%s`

  time_distance=$(( $Time_test - $Test_begin ))
  hour_distance=$(( ${time_distance} / 3600 )) 
  hour_remainder=$(( ${time_distance} % 3600 )) 
  min_distance=$(( ${hour_remainder} / 60 )) 
  min_remainder=$(( ${hour_remainder} % 60 ))
  
  echo "monkey tested ${hour_distance} hour ${min_distance} min ${min_remainder} sec" >> $TimeF/$TestBeginTime.monkeylog

}




#hours
run_time=0.1 

#发送Event数量
events=100000

#插入固定延时
throttle=300

seed=1000

#
pct_trackball=0
#
pct_motion=25
#
pct_anyevent=15
#
pct_flip=0
#
pct_pinchzoom=0

#触摸事件百分比
pct_touch=20

#“基本”导航事件的百分比(导航事件由来自方向输入设备的up/down/left/right组成)
pct_nav=20

#“主要”导航事件的百分比(这些导航事件通常引发图形接口中的动作，如：5-way键盘的中间按键、回退按键、菜单按键)
pct_majornav=15

#“系统”按键事件的百分比(这些按键通常被保留，由系统使用，如Home、Back、Start Call、End Call及音量控制键)。
pct_syskeys=0

#启动Activity的百分比。在随机间隔里，Monkey将执行一个startActivity()调用，作为最大程度覆盖包中全部Activity的一种方法
pct_appswitch=5

eventlist="--pct-majornav $pct_majornav --pct-touch $pct_touch --pct-syskeys $pct_syskeys --pct-appswitch $pct_appswitch --pct-nav $pct_nav --pct-nav $pct_nav --pct-anyevent $pct_anyevent "

disableE="--ignore-crashes --ignore-timeouts --ignore-security-exceptions --kill-process-after-error "

function systemTest()
{
   TestBeginTime=`date +%s`
   monkey -p com.miui.video  -s $seed $disableE $eventlist --throttle $throttle -v -v -v $events > /dev/null 2>&1 &   
}

function Logd()
{
  $LOGCAT $logfileSz $logfileNm $logfileSv &
}

function teardown()
{
  monkeypid=`ps | grep monkey |busybox awk '{print $2}'`
  PIDS=$1
  Logcatfile=$2
  while [ "$monkeypid"x != ""x ]
  do
	sleep 30
    runTime $TestBeginTime
	monkeypid=`ps | grep monkey |busybox awk '{print $2}'`
	if [ $FILESIZE -gt $LIMIT ];then
		kill $PIDS
		sleep 5
		Logcatfile=$logFolder/`date '+%Y%m%d-%H%M%S-logcat.log'`
		sleep 5
		logcat -v time -b system -b main -b events -f $Logcatfile & 
		PIDS=$!
		sleep 30
	fi
	FILESIZE=`$BB stat -c%s $Logcatfile`
  done
}

LIMIT=$((1024*1024*100)) #50M
FILESIZE=0
BB='busybox'
LogcatFile=""
PID=""
logFolder="/sdcard/Monkey/log"


setup
Time_time=`date '+%Y%m%d-%H%M%S'`
End_time=$(($Time_time+$1))
while [ $Time_time -le $End_time ]
do
logcat -v time -b system -b main -b events -f $logFolder/${Time_time}.log &

LogcatFile=$logFolder/${Time_time}.log

PID=$!
systemTest
sleep 5
teardown $PID $LogcatFile
Time_time=`date '+%Y%m%d-%H%M%S'`
sleep 10
kill -9 $PID
done

