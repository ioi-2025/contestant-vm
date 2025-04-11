#!/bin/bash

# We no longer use the schedule
# TODO: refactor or remove this script entirely

source /opt/ioi/config.sh


# if [ -f /opt/ioi/misc/schedule2.txt.firstrun ]; then
# 	logger -p local0.info "SCHEDULE: first run"
# 	/opt/ioi/sbin/atrun.sh schedule
# 	rm /opt/ioi/misc/schedule2.txt.firstrun
# fi
# 
# # Check for new contest schedule
# SCHEDFILE=$(mktemp)
# wget --timeout=3 --tries=3 -O $SCHEDFILE "https://${POP_SERVER}/config/schedule2.txt" > /dev/null 2>&1
# if [ $? -eq 0 -a -f $SCHEDFILE ]; then
# 	diff -q /opt/ioi/misc/schedule2.txt $SCHEDFILE > /dev/null
# 	if [ $? -ne 0 ]; then
# 		logger -p local0.info "SCHEDULE: Setting up new contest schedule"
# 		cp $SCHEDFILE /opt/ioi/misc/schedule2.txt
# 		/opt/ioi/sbin/atrun.sh schedule
# 	fi
# fi
# rm $SCHEDFILE

