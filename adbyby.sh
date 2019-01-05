#!/bin/sh
## Adaptation Grassland in Lucheng 2019.01.05

ad_home="/tmp/adb"
if [ ! -f /tmp/cron_adb.lock ]; then
	CPULoad=`uptime |sed -e 's/\ *//g' -e 's/.*://g' -e 's/,.*//g' -e 's/\..*//g'`
	if [ $((CPULoad)) -ge "2" ] ; then
		logger -t "adbyby" "CPU 负载拥堵,关闭广告屏蔽程序。"
		if [ "$adchange" -eq 1 ]; then
			touch /tmp/cron_adb.lock
			port=$(iptables -t nat -L | grep 'ports 8118' | wc -l)
			logger -t "adbyby" "找到$port个8118透明代理端口,正在关闭。"
			while [[ "$port" -ge 1 ]]
			do
				iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
				port=$(iptables -t nat -L | grep 'ports 8118' | wc -l)
			done
			logger -t "adbyby" "已关闭全部8118透明代理端口。"
			killall adbyby
			sed -i '/adbyby/d' /etc/storage/post_wan_script.sh
			logger -t "adbyby" "adbyby 进程已成功关闭。"
		fi
		processor=`cat /proc/cpuinfo| grep "processor"| wc -l`
		processor=`expr $processor \* 2`
		while [[ "$CPULoad" -gt "$processor" ]] 
		do
			sleep 62
			CPULoad=`uptime |sed -e 's/\ *//g' -e 's/.*://g' -e 's/,.*//g' -e 's/\..*//g'`
		done
		logger -t "adbyby" "CPU 负载正常"
		rm -f /tmp/cron_adb.lock
	fi
fi
if [ "$adchange" -eq 1 ]; then
	PIDS=$(ps |grep "$ad_home/bin/adbyby" |grep -v "grep" |wc -l)
	if [ $PIDS -eq 0 ]; then
		[ -f $ad_home/bin/adbyby ] && $ad_home/bin/adbyby&
		echo "注意：TMP：adbyby 意外关闭,将重启adbyby!"
		iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
		exit 0
	fi
	if [ $PIDS -gt 6 ]; then
		echo "注意：发现 adbyby 多于6个进程,将重启adbyby!"
		ps |grep "$ad_home/bin/adbyby" | grep -v 'grep' | awk '{print $1}' |xargs kill -9
		$ad_home/bin/adbyby&
		iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
		exit 0
	fi
	port=$(iptables -t nat -L | grep "tcp dpt:www redir ports 8118" | wc -l)
	if [ $port -eq 0 ]; then
		echo "注意：防火墙转发规则丢失,将添加规则！"
		iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
	fi
	while [ $port -gt 1 ]
	do
		echo "注意：发现多条防火墙转发规则,将删除多余规则！"
		iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
		port=$(iptables -t nat -L | grep "tcp dpt:www redir ports 8118" | wc -l)
	done
fi
