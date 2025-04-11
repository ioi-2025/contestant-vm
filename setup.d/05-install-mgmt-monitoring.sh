#!/bin/bash

set -x
set -e

# Install tools needed for management and monitoring

apt -y install net-tools openssh-server ansible xvfb oathtool imagemagick \
	zabbix-agent
# Use a different config for Zabbix
sed -i '/^Environment=/ s/zabbix_agentd.conf/zabbix_agentd_ioi.conf/' /lib/systemd/system/zabbix-agent.service

# custom Zabbix configuration
cat > /etc/zabbix/zabbix_agentd_ioi.conf <<EOF
PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=staticsvm.ioi2025.bo
ServerActive=staticsvm.ioi2025.bo
HostnameItem=system.hostname
Include=/etc/zabbix/zabbix_agentd.d/*.conf
UnsafeUserParameters=1
EOF

mkdir -p /etc/zabbix/zabbix_agentd.d
cat > /etc/zabbix/zabbix_agentd.d/ioi_custom.conf <<EOF
# Check if a process is running
UserParameter=proc.exists[*],pgrep -x "\$1" > /dev/null && echo 1 || echo 0

# Get process elapsed time in seconds
UserParameter=proc.etime[*],ps -eo comm,etime | grep -w "\$1" | awk '{split(\$2, t, "[:-]"); if(length(t)==3){print t[1]*3600 + t[2]*60 + t[3]} else if(length(t)==2){print t[1]*60 + t[2]} else{print t[1]}}'

# Count syslog errors in the last 10 minutes
UserParameter=log.errors,grep -i error /var/log/syslog | tail -n 100 | wc -l
EOF

systemctl daemon-reexec
systemctl daemon-reload

systemctl enable zabbix-agent
systemctl stop zabbix-agent
