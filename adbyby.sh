#!/bin/sh
## Adaptation Grassland in Lucheng 2019.01.08

username=`nvram get http_username`
Firewall_rules="/etc/storage/post_iptables_script.sh"
Run_script="/etc/storage/post_wan_script.sh"
ad_home="/tmp/adb"

if [ -f "$ad_home/bin/adbyby" ]; then
	port=$(iptables -t nat -L | grep 'ports 8118' | wc -l)
	logger -t "adbyby" "找到$port个8118透明代理端口，正在关闭。"
	while [[ "$port" -ge 1 ]]
	do
		iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
		port=$(iptables -t nat -L | grep 'ports 8118' | wc -l)
	done
	echo -e "\e[1;31m 关闭 adbyby 进程，代理端口任务 \e[0m"
	touch /tmp/cron_adb.lock
	if [ -n "`pidof adbyby`" ] ; then
		kill -9 "`pidof adbyby`"
	fi
	logger -t "adbyby" "adbyby进程已成功关闭。"
	if [ -f "/etc/storage/cron/crontabs/$username" ]; then
		grep "adbchk" /etc/storage/cron/crontabs/$username
		if [ $? -eq 0 ]; then
			echo "YES"
		else
			sed -i '$a 30 5 * * * /bin/sh /tmp/adb/adbchk.sh >/dev/null 2>&1' /etc/storage/cron/crontabs/$username
		fi
	fi
	export PATH=/opt/sbin:/opt/bin:/usr/sbin:/usr/bin:/sbin:/bin
	export LD_LIBRARY_PATH=/opt/lib:/lib
	sleep 2
	if [ -f "$ad_home/bin/adhook.ini" ]; then
		ad_whost=$ad_home/ad_whost
		if [ "$ad_whost" != "" ] ; then
			logger -t "adbyby" "添加过滤白名单地址"
			echo -e "\e[1;31m  添加过滤白名单地址 \e[0m"
			chmod 777 "$ad_home/bin/adhook.ini"
			sed -Ei '/whitehost=/d' "$ad_home/bin/adhook.ini"
			echo whitehost=$ad_whost >> "$ad_home/bin/adhook.ini"
			echo @@\|http://\$domain=$(echo $ad_whost | tr , \|) >> $ad_home/bin/data/user.txt
		else
			echo -e "\e[1;31m 过滤白名单地址未定义,已忽略 \e[0m"
		fi
	fi
	logger -t "adbyby" "adbyby 开始运行..."
	chmod 777 "$ad_home/bin/adbyby" && /tmp/adb/bin/stopadb; /tmp/adb/bin/startadb
	echo -e "\033[41;37m adbyby 开始运行... \e[0m\n"
	/tmp/adb/ad_gz >> /var/log/ad_gz.log 2>&1 &
	sleep 3
	check=$(ps |grep "$ad_home/bin/adbyby" |grep -v "grep" | wc -l)
	if [ "$check" = 0 ]; then
		logger -t "adbyby" "adbyby启动失败。"
		exit 0
	else
		logger -t "adbyby" "添加8118透明代理端口。"
		iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
		logger -t "adbyby" "adbyby进程守护已启动。"
	fi
else
	echo -e "\e[1;31m  没有发现 adbyby 程序，没能启动 \e[0m"	 
fi
sleep 3 && /tmp/adb/adbchk.sh
