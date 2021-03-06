#!/bin/sh
## Adaptation Grassland in Lucheng 2019.1.8

ad_home="/tmp/adb"

logger -t "adbyby" "路由重启,开始重新构建 Adbyby..."


if [ -f "/tmp/ad_an" ]; then
	sleep 3 && logger -t "adbyby" "开始安装 Adbyby..."
	sh /tmp/ad_an
else
	logger -t "adbyby" "开始下载 Adbyby 并安装..."
	wget --no-check-certificate -t 15 -T 50 https://raw.githubusercontent.com/896660689/AD/master/ad_an -O /tmp/ad_an && sleep 2
fi
chmod 777 /tmp/ad_an; sh /tmp/ad_an
[ -f /tmp/ad_an ] && rm -f /tmp/ad_an
exit 0
