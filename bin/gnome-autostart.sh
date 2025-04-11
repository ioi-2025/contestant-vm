#!/bin/bash

source /opt/ioi/misc/config

if [ "$DOSETUP" = "1" ]; then
	if ! /opt/ioi/bin/ioicheckuser -q; then
		/opt/ioi/bin/ioisetup
	fi
fi
