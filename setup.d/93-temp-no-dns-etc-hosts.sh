#!/bin/bash

set -x
set -e

cat <<EOM >>/etc/hosts
172.16.1.1 cms.ioi2025.bo
172.16.2.1 backup.ioi2025.bo
EOM

sudo resolvectl flush-caches
