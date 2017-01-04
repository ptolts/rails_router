pacman -S git mongodb openvpn nodejs htop mtr dhcpd ntp cronie

gem install mechanize nokogiri

iptables -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT