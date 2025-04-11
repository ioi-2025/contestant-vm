#!/bin/bash

source /opt/ioi/config.sh

case "$1" in
	start)
		# TODO update
		cat /opt/ioi/misc/iptables.save | \
			sed -e 's/{BACKUP_SERVER}/'${BACKUP_SERVER}'/g' | \
			sed -e 's/{CMS_PUBLIC_DOMAIN}/'${CMS_PUBLIC_DOMAIN}'/g' | \
			sed -e 's#{SUBNET}#'${SUBNET}'#g' | iptables-restore
		ip6tables-restore < /opt/ioi/misc/ip6tables.save
		logger -p local0.info "FIREWALL: started"
		;;
	stop)
		iptables -P INPUT ACCEPT
		iptables -P OUTPUT ACCEPT
		iptables -F
		ip6tables -P INPUT ACCEPT
		ip6tables -P OUTPUT ACCEPT
		ip6tables -F
		logger -p local0.info "FIREWALL: stopped"
		;;
	*)
		echo Must specify start or stop
		;;
esac

# vim: ft=sh ts=4 noet
