#!/bin/bash

set -x
set -e

hostnamectl set-hostname ""

cat >/etc/NetworkManager/conf.d/50-dynamic-hostname.conf <<EOF
[connection]
ipv4.dhcp-hostname=yes
EOF