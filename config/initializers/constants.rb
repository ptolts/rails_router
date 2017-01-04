MAIN_INTERFACE = "eth0.200"

TABLE =  "#
# reserved values
#
255 local
254 main
253 default
0 unspec
100 merica
57 usa
#
# local
#
#1  inr.ruhep"

INTERFACES = "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: p37p1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:1d:92:a0:7a:b9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.114/24 brd 192.168.1.255 scope global dynamic p37p1
       valid_lft 83618sec preferred_lft 83618sec
    inet6 fe80::21d:92ff:fea0:7ab9/64 scope link
       valid_lft forever preferred_lft forever
3: p1p1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 00:00:e8:7e:f4:d1 brd ff:ff:ff:ff:ff:ff
4: wlp5s1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN group default qlen 1000
    link/ether 00:11:95:d4:b7:82 brd ff:ff:ff:ff:ff:ff
8: usa: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/none
    inet 10.4.1.6 peer 10.4.1.5/32 scope global usa
       valid_lft forever preferred_lft forever"

ARP_TABLE = "192.168.3.5                      (incomplete)                              wlan0
192.168.1.1              ether   00:1d:7e:46:97:95   C                     eth0
127.0.0.1            ether   20:c9:d0:7e:82:b1   C                     eth0"