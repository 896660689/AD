#!/bin/sh

mkdir -p /etc/storage/v2ray
cd /etc/storage/v2ray
wget -O config.json https://raw.githubusercontent.com/896660689/AD/master/V2/config.json
cd /etc/storage
rm -rf gfwlist; mkdir -p /etc/storage/gfwlist
cd /etc/storage/gfwlist
wget -O gw-mini.hosts https://raw.githubusercontent.com/896660689/AD/master/V2/gw-mini.hosts
cd /tmp
wget -O v2ray.tar https://raw.githubusercontent.com/896660689/AD/master/V2/v2ray.tar
echo ""
echo "-------[v2ray started.Go google.com and surfing!]-----------"
echo ""
echo ""
echo "#stop v2ray"
echo "sh /tmp/v2ray/stop.sh"
echo ""
echo "#Default config.json use GFW Mode"
echo ""
echo "Chnroute file at /tmp/v2ray/example-config"
echo ""
echo "#Autoruns:"
echo "'Scripts' - 'Run After Firewall Rules Restarted'"
echo "wget -O - d.oo14.com/e7XT | bash"
echo ""
echo "USE 5353 DNS FOR GFWLIST:"
echo "Custom 'dnsmasq.conf'"
echo "conf-dir=/etc/storage/gfwlist/, *.hosts"
echo ""
echo "-------------you can close this Window---------------------"
echo ""
tar -zxvf v2ray.tar.gz
chmod +x v2ray
rm -rf v2ray.tar.gz
sh /tmp/v2ray/start.sh
