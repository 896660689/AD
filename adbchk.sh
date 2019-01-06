#!/bin/sh

if [ -f "/tmp/adb/bin/adbybyupdate.sh" ];then
	touch /tmp/adbyby.mem
	wget -s -q -T 3 www.baidu.com
	touch /tmp/lazy.txt && wget --no-check-certificate http://git.oschina.net/halflife/list/raw/master/ad.txt -O /tmp/lazy.txt
	touch /tmp/video.txt && wget --no-check-certificate https://coding.net/u/adbyby/p/xwhyc-rules/git/raw/master/video.txt -O /tmp/video.txt
	touch /tmp/local-md5.json && md5sum /tmp/lazy.txt /tmp/video.txt > /tmp/local-md5.json
	touch /tmp/md5.json && wget --no-check-certificate https://coding.net/u/adbyby/p/xwhyc-rules/git/raw/master/md5.json -O /tmp/md5.json
	lazy_local=$(grep 'lazy' /tmp/local-md5.json | awk -F' ' '{print $1}')
	video_local=$(grep 'video' /tmp/local-md5.json | awk -F' ' '{print $1}')  
	lazy_online=$(sed  's/":"/\n/g' /tmp/md5.json  |  sed  's/","/\n/g' | sed -n '2p')
	video_online=$(sed  's/":"/\n/g' /tmp/md5.json  |  sed  's/","/\n/g' | sed -n '4p')
	chmod -R 644 /tmp/adb/bin/data
	if [ "$lazy_online"x == "$lazy_local"x -a "$video_online"x == "$video_local"x ]; then
		echo "adbyby rules MD5 OK!"
		mv -f /tmp/lazy.txt /tmp/adb/bin/data/lazy.txt
		mv -f /tmp/video.txt /tmp/adb/bin/data/video.txt
		echo $(date +%F) > /tmp/adb/bin/adbybyupdate.sh
		logger "adbyby mem mode rules updated!"
	else
		mv -f /tmp/lazy.txt /tmp/adb/bin/data/lazy.txt
	fi
	rm -f /tmp/adbyby.mem /tmp/lazy.txt /tmp/video.txt /tmp/local-md5.json /tmp/md5.json
	rm -f /tmp/adb/data/*.bak
	sleep 5 && /tmp/adb/ad_gz >> /var/log/ad_gz.log 2>&1 &
fi
[ -f "/tmp/adbyby.mem" ] rm -f /tmp/adbyby.mem
