#!/bin/sh
## Adaptation Grassland in Lucheng 2019.01.05
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
		grep "ad_up" /etc/storage/cron/crontabs/$username
		if [ $? -eq 0 ]; then
			echo "YES"
		else
			sed -i '$a 5 * * * * /bin/sh /tmp/adb/ad_gz >/dev/null 2>&1' /etc/storage/cron/crontabs/$username
		fi
	fi
	if [ -f "$Firewall_rules" ]; then
		grep "8118" $Firewall_rules
		if [ $? -eq 0 ]; then
			#sed -i '/8118/d' $Firewall_rules
			echo "YES"
		else
			echo -e "\e[1;31m  添加防火墙端口规则 \e[0m"
			sed -i '$a iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118' $Firewall_rules
			restart_dhcpd && logger -t "adbyby" "adbyby 进程守护已启动..."
		fi

	fi
	if [ -f "$Run_script" ]; then
		grep "adbyby" $Run_script
		if [ $? -eq 0 ]; then
			echo "YES"
		else
			echo -e "\e[1;31m  添加开机启动脚本 \e[0m"
			sed -i '$a /usr/bin/adbyby.sh&' $Run_script
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
	[ -f /tmp/7620n.tar.gz ] && rm -f /tmp/7620n.tar.gz
	[ -f /tmp/Ad_Install ] && rm -f /tmp/Ad_Install
	[ -f /tmp/ad_an ] && rm -f /tmp/ad_an
	logger -t "adbyby" "adbyby 开始运行..."
	chmod 777 "$ad_home/bin/adbyby" && /tmp/adb/bin/adbyby && exit 0
	echo -e "\033[41;37m adbyby 开始运行... \e[0m\n"
	sleep 5 && mtd_storage.sh save
	check=$(ps |grep "$ad_home/bin/adbyby" |grep -v "grep" | wc -l)
	if [ "$check" = 0 ]; then
		logger -t "adbyby" "adbyby启动失败。"
		exit 0
	fi
else
	echo -e "\e[1;31m  没有发现 adbyby 程序，没能启动 \e[0m"	 
fi
sleep 8 && rm -f /tmp/cron_adb.lock
