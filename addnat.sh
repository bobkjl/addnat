#!/usr/bin/env bash
echo -e "Please input your server main ip"
		stty erase '^H' && read -p "(such as 8.8.8.8):" main_ip
		[[ -z "${main_ip}" ]] && echo -e "cancel..." && exit 1
echo -e "Please input how many /24 you want to use, max is 5"
		stty erase '^H' && read -p "(such as 1):" user_ip_num
		[[ -z "${user_ip_num}" ]] && echo -e "cancel..." && exit 1
iptables -t nat -F >/dev/null
iptables -t nat -A POSTROUTING -o br0 -s 10.0.0.0/8 -j SNAT --to ${main_ip} 
user_ip_head="10.0.2."
for (( d = 100; d <= 200; d++ ));do
		user_ip=${user_ip_head}${d}
			ssh_port=${d}"00"
			user_port_first=${d}"01"
			user_port_last=${d}"99"

		iptables -t nat -A PREROUTING -i br0 -d ${main_ip} -p tcp -m tcp --dport ${ssh_port} -j DNAT --to-destination ${user_ip}:22 
		iptables -t nat -A PREROUTING -i br0 -d ${main_ip} -p tcp -m tcp --dport ${user_port_first}:${user_port_last} -j DNAT --to-destination ${user_ip} 
		iptables -t nat -A PREROUTING -i br0 -d ${main_ip} -p udp -m udp --dport ${user_port_first}:${user_port_last} -j DNAT --to-destination ${user_ip} 
done
service iptables save
service iptables restart
echo -e "It seems done"
