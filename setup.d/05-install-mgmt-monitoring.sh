#!/bin/bash

set -x
set -e

apt -y install openssh-server rsyslog snmpd

cat > /etc/snmp/snmpd.conf <<EOF
agentAddress udp:16161
rocommunity lepublicagent
sysLocation "Polideportivo Garcilazo, Sucre, Bolivia [-19.045968, -65.239440]"
sysContact "IOI HTC"
defaultMonitors yes
master agentx
EOF

# TODO: syslog, firewall
