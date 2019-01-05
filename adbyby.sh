#!/bin/sh
## Adaptation Grassland in Lucheng 2019.01.05
username=`nvram get http_username`
ad_home="/etc/storage/adb"

if [ ! -f "$ad_home/bin/adbyby" ]; then
	port=$(iptables -t nat -L | grep 'ports 8118' | wc -l)
	logger -t "adbyby" "找到$port个8118透明代理端口，正在关闭。"
	while [[ "$port" -ge 1 ]]
	do
		iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
		port=$(iptables -t nat -L | grep 'ports 8118' | wc -l)
	done
	echo -e "\e[1;31m 关闭 adbyby 进程，代理端口任务 \e[0m"
	if [ -f "/etc/storage/cron/crontabs/$username" ]; then
		grep "ad_up" "/etc/storage/cron/crontabs/$username"
		if [ $? -eq 0 ]; then
			sed -i '/ad_up/d' /etc/storage/cron/crontabs/$http_username
		else
			echo -e "\e[1;31m 添加定时计划更新任务 \e[0m"
			cat >> /etc/storage/cron/crontabs/$http_username << EOF
5 * * * * /bin/sh /usr/bin/ad_up >/dev/null 2>&1
EOF
		fi

	fi
	if [ -f "/etc/storage/post_iptables_script.sh" ]; then
		grep "8118" "/etc/storage/post_iptables_script.sh"
		if [ $? -eq 0 ]; then
			sed -i '/8118/d' "/etc/storage/post_iptables_script.sh"
		else
			echo -e "\e[1;31m  添加防火墙端口规则 \e[0m"
			cat >> "/etc/storage/post_iptables_script.sh" << EOF
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
EOF
			logger -t "adbyby" "adbyby进程守护已启动。"
		fi

	fi
	touch /tmp/cron_adb.lock
	killall adbyby && logger -t "adbyby" "adbyby进程已成功关闭。"


	if [ "$adbyby_whost" != "" ] ; then
			logger -t "adbyby" "添加过滤白名单地址"
			logger -t "adbyby" "加白地址:$adbyby_whost"
			chmod 777 "$adbybydir/adbb/bin/adhook.ini"
			sed -Ei '/whitehost=/d' $adbybydir/adbb/bin/adhook.ini
			echo whitehost=$adbyby_whost >> $adbybydir/adbb/bin/adhook.ini
			echo @@\|http://\$domain=$(echo $adbyby_whost | tr , \|) >> $adbybydir/adbb/bin/data/user.txt
		else
			logger -t "adbyby" "过滤白名单地址未定义,已忽略。"
		fi
		logger -t "adbyby" "正在启动adbyby进程。"
		chmod 777 "$adbybydir/adbb/bin/adbyby"
		$adbybydir/adbb/bin/adbyby&
		sleep 5
		check=$(ps | grep "$adbybydir/adbb/bin/adbyby" | grep -v "grep" | wc -l)
		if [ "$check" = 0 ]; then
			logger -t "adbyby" "adbyby启动失败。"
			nvram set ad_enable="0"
			exit 0
		else
			logger -t "adbyby" "添加8118透明代理端口。"
			iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
			logger -t "adbyby" "adbyby进程守护已启动。"
		fi
else
	echo -e "\e[1;31m  没有发现 adbyby 程序，没能启动 \e[0m"
fi


		
		
		
		
sed -i '/adbchk/d' /etc/storage/cron/crontabs/$http_username
cat >> /etc/storage/cron/crontabs/$http_username << EOF
5 * * * * /bin/sh /usr/bin/adbchk.sh >/dev/null 2>&1
EOF

if [ -f "/etc/storage/post_iptables_script.sh" ]; then
	echo -e "\e[1;36m 添加防火墙端口转发规则 \e[0m\n"
	sed -i '/DNAT/d' /etc/storage/post_iptables_script.sh
	sed -i '/iptables-save/d' /etc/storage/post_iptables_script.sh
	sed -i '$a /bin/iptables-save' /etc/storage/post_iptables_script.sh
fi


echo "/bin/iptables -t nat -A PREROUTING -p tcp --dport 53 -j DNAT --to $route_vlan" >> /etc/storage/post_iptables_script.sh
echo "/bin/iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to $route_vlan" >> /etc/storage/post_iptables_script.sh
if [ -f "/etc/storage/post_iptables_script.sh" ]; then
	sed -i '/resolv.conf/d' /etc/storage/post_iptables_script.sh
	sed -i '/restart_dhcpd/d' /etc/storage/post_iptables_script.sh
	sed -i '$a cp -f /etc/storage/dnsmasq.d/resolv.conf /tmp/resolv.conf' /etc/storage/post_iptables_script.sh
	sed -i '$a sed -i "/#/d" /tmp/resolv.conf;mv -f /tmp/resolv.conf /etc/resolv.conf' /etc/storage/post_iptables_script.sh
	sed -i '$a restart_dhcpd' /etc/storage/post_iptables_script.sh
fi

	export PATH=/opt/sbin:/opt/bin:/usr/sbin:/usr/bin:/sbin:/bin
	export LD_LIBRARY_PATH=/opt/lib:/lib
	
if [ -s "$adbybydir/adbb/bin/adbyby" ] ;then
		if [ "$adbyby_whost" != "" ] ; then
			logger -t "adbyby" "添加过滤白名单地址"
			logger -t "adbyby" "加白地址:$adbyby_whost"
			chmod 777 "$adbybydir/adbb/bin/adhook.ini"
			sed -Ei '/whitehost=/d' $adbybydir/adbb/bin/adhook.ini
			echo whitehost=$adbyby_whost >> $adbybydir/adbb/bin/adhook.ini
			echo @@\|http://\$domain=$(echo $adbyby_whost | tr , \|) >> $adbybydir/adbb/bin/data/user.txt
		else
			logger -t "adbyby" "过滤白名单地址未定义,已忽略。"
		fi
		logger -t "adbyby" "正在启动adbyby进程。"
		chmod 777 "$adbybydir/adbb/bin/adbyby"
		$adbybydir/adbb/bin/adbyby&
		sleep 5
		check=$(ps | grep "$adbybydir/adbb/bin/adbyby" | grep -v "grep" | wc -l)
		if [ "$check" = 0 ]; then
			logger -t "adbyby" "adbyby启动失败。"
			nvram set ad_enable="0"
			exit 0
		else
			logger -t "adbyby" "添加8118透明代理端口。"
			iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8118
			logger -t "adbyby" "adbyby进程守护已启动。"
		fi
	fi	
sed -i '/adbyby/d' /etc/storage/post_wan_script.sh
cat >> /etc/storage/post_wan_script.sh << EOF
/usr/bin/adbyby.sh&
EOF
#koolproxy处理结束
#守护进程
sleep 2
sed -i '/adbchk/d' /etc/storage/cron/crontabs/$http_username
cat >> /etc/storage/cron/crontabs/$http_username << EOF
5 * * * * /bin/sh /usr/bin/adbchk.sh >/dev/null 2>&1
EOF



	

addir=

ad
mv -f /tmp/hsfq_script_up.sh /tmp/hsfq_script.sh && rm -f hsfq_script_up.txt
cp -f /etc/storage/dnsmasq.d/resolv.conf /tmp/resolv.conf
logger -t "adbyby" "adbyby 安装完成开始运行"

echo -e -n "\033[41;37m 开始构建翻墙平台......\033[0m\n"
sleep 3
if [ ! -d "/etc/storage/dnsmasq.d" ]; then
	mkdir -p -m 755 /etc/storage/dnsmasq.d
	echo -e "\e[1;36m 创建 dnsmasq 规则脚本文件夹 \e[0m\n"
	cp -f /tmp/hsfq_script.sh /etc/storage/dnsmasq.d/hsfq_script.sh
	cp -f /etc/resolv.conf /etc/storage/dnsmasq.d/resolv_bak
fi

if [ -d "/etc/storage/dnsmasq.d" ]; then
	echo -e "\e[1;33m 创建更新脚本 \e[0m\n"
	wget --no-check-certificate -t 30 -T 60 https://raw.githubusercontent.com/896660689/Hsfq/master/tmp_up -qO /tmp/tmp_hsfq_update.sh
	mv -f /tmp/tmp_hsfq_update.sh /etc/storage/dnsmasq.d/hsfq_update.sh && sleep 3
	chmod 755 /etc/storage/dnsmasq.d/hsfq_update.sh
fi


if [ -f $adbyby_plus ]
	then
		sh $adbyby_plus
	else
  	wget --no-check-certificate https://raw.githubusercontent.com/896660689/LS-SSR/master/post_wan_script.sh -O \
  	  	/etc/storage/adb/post_wan_script.sh
  	wget --no-check-certificate https://raw.githubusercontent.com/896660689/LS-SSR/master/adupdate.sh -O \
  	  	$adbyby_plus && chmod 777 $adbyby_plus && sh $adbyby_plus
	wget --no-check-certificate https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/lazy.txt -O \
  	  	/etc/storage/adb/data/lazy.txt && chmod 644 /etc/storage/adb/data/lazy.txt
	wget --no-check-certificate https://coding.net/u/adbyby/p/xwhyc-rules/git/raw/master/video.txt -O \
  	  	/etc/storage/adb/data/video.txt && chmod 644 /etc/storage/adb/data/video.txt
fi

grep "adupdate" /etc/storage/post_wan_script.sh
if [ ! "$?" -eq "0" ]
then
	cp -f /etc/storage/adb/post_wan_script.sh /etc/storage/post_wan_script.sh
fi

grep -q "adupdate" "/etc/storage/cron/crontabs/$username"
if [ ! "$?" -eq "0" ]
then
	sed -i '/adupdate/d' /etc/storage/cron/crontabs/$username
	echo -e "\e[1;33m 添加定时计划更新任务 \e[0m\n"
	sed -i '$a 0 6 * * *    /etc/storage/adb/adupdate.sh &' /etc/storage/cron/crontabs/$username
	sleep 2 && killall crond;/usr/sbin/crond
fi

echo -e "\033[41;37m Adbyby plus 安装完成,开始运行... \e[0m\n"
mtd_storage.sh save
