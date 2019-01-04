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
