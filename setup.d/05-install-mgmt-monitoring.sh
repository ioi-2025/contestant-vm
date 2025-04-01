#!/bin/bash

set -x
set -e

# Install tools needed for management and monitoring

apt -y install net-tools openssh-server ansible xvfb oathtool imagemagick \
	zabbix-agent

# Use a different config for Zabbix
sed -i '/^Environment=/ s/zabbix_agentd.conf/zabbix_agentd_ioi.conf/' /lib/systemd/system/zabbix-agent.service

systemctl disable zabbix-agent
