#!/bin/bash

set -x
set -e

# Create IOI account
/opt/ioi/sbin/mkioiuser.sh

# Set IOI user's initial password
echo "ioi:ioi" | chpasswd

# Fix permission and ownership
chown ioi:ioi /opt/ioi/store/submissions
chown ansible:syslog /opt/ioi/store/log
chmod 770 /opt/ioi/store/log
