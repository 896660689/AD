#!/bin/sh
## Adaptation Grassland in Lucheng 2019.01.11

username=`nvram get http_username`
Firewall_rules="/etc/storage/post_iptables_script.sh"
Run_script="/etc/storage/post_wan_script.sh"
ad_home="/tmp/adb"

if [ -f "$ad_home/bin/adbyby" ]; then
	port=$(iptables -t nat -L | grep 'ports 8118' | wc -l)
	if [[ "$port" -ge 1 ]]; then
		logger "adbyby" "找到$port个 8118 透明代理端口,正在关闭..."
		iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
		port=$(iptables -t nat -L | grep 'ports 8118' | wc -l)
	fi
	PIDS=$(ps |grep "$ad_home/bin/adbyby" |grep -v "grep" |wc -l)
	if [ $PIDS -eq 0 ]; then
		echo -e "\e[1;31m 没发现 adbyby 程序进程... \e[0m"
	else
		if [ -n "`pidof adbyby`" ] ; then
			kill -9 "`pidof adbyby`"
			logger "adbyby 进程已成功关闭..."
		fi
	fi
	if [ -f "/etc/storage/cron/crontabs/$username" ]; then
		grep "adb" /etc/storage/cron/crontabs/$username
		if [ $? -eq 0 ]; then
			echo "存在 adbyby 定时更新计划任务"
		else
			sed -i '$a 30 5 * * * /bin/sh /tmp/adb/ad_up >/dev/null 2>&1' /etc/storage/cron/crontabs/$username
			logger "adbyby 添加定时更新任务..."
		fi
	fi
	export PATH=/opt/sbin:/opt/bin:/usr/sbin:/usr/bin:/sbin:/bin
	export LD_LIBRARY_PATH=/opt/lib:/lib
	sleep 2
	if [ -f "$ad_home/bin/adhook.ini" ]; then
		ad_whost=$ad_home/ad_whost
		if [ "$ad_whost" != "" ] ; then
			logger "adbyby" "添加过滤白名单地址"
			echo -e "\e[1;31m  添加过滤白名单地址 \e[0m"
			chmod 777 "$ad_home/bin/adhook.ini"
			sed -Ei '/whitehost=/d' "$ad_home/bin/adhook.ini"
			echo whitehost=$ad_whost >> "$ad_home/bin/adhook.ini"
			echo @@\|http://\$domain=$(echo $ad_whost | tr , \|) >> $ad_home/bin/data/user.txt
		else
			echo -e "\e[1;31m 过滤白名单地址未定义,已忽略 \e[0m"
		fi
	fi
	logger "adbyby" "adbyby 开始运行..."
	chmod 777 "$ad_home/bin/adbyby" && /tmp/adb/bin/stopadb; /tmp/adb/bin/startadb
	echo -e "\033[41;37m adbyby 开始运行... \e[0m\n"
	sleep 3
	check=$(ps |grep "$ad_home/bin/adbyby" |grep -v "grep" | wc -l)
	if [ "$check" = 0 ]; then
		logger "adbyby" "adbyby 启动失败..."
		exit 0
	else
		port=`iptables -t nat -L |grep 'ports 8118' |wc -l`
		[ $port -eq 0 ] && iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
	fi
	logger "adbyby" "adbyby 进程守护已启动..."
	nohup /tmp/adb/ad_gz >> /var/log/adbyby_watchdog.log 2>&1 &
	echo -e "\e[1;31m adbyby 开始更新规则... \e[0m" && logger "adbyby 开始更新规则..."
	/tmp/adb/ad_up && sleep 3; exit 0
else
	echo -e "\e[1;31m 没有发现 adbyby 程序,没能启动... \e[0m"
	exit 0
fi
