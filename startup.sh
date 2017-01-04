#!/bin/sh
# modprobe 8188eu --force
# systemctl start mongodb.service
# systemctl start dhcpd.service
# systemctl start ntpd.service
# systemctl start hostapd.service
# systemctl start openvpn@australia.service
# systemctl start openvpn@usa.service
# systemctl start cronie.service
su phil <<EOF
bash --login
cd /home/phil/router
rails s -d -p 3000
EOF