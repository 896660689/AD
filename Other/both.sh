#!/bin/sh
mkdir -p /etc/storage/v2ray
cd /etc/storage/v2ray
wget -O config.json http://3322d.f3322.net:16999/v2/config.json
mkdir -p /etc/storage/dnsmasq-gwlist
cd /etc/storage/dnsmasq-gwlist
wget -O gw-mini.hosts http://3322d.f3322.net:16999/v2/gw-mini.hosts
cd /tmp
wget -O v2ray.tar http://3322d.f3322.net:16999/v2/v2ray.tar
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
echo "conf-dir=/etc/storage/dnsmasq-gwlist/, *.hosts"
echo ""
echo "-------------you can close this Window---------------------"
echo ""
tar xvf v2ray.tar
chmod +x v2ray
rm -rf v2ray.tar
sh /tmp/v2ray/start.sh