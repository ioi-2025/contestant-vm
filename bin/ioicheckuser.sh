#!/bin/bash

# Disabled: we no longer use tinc VPN
# TODO: refactor or remove this script entirely

source /opt/ioi/config.sh

QUIET=0
ZENARG='--width=300'
ZENTITLE='--title=IOI Check User'

USERID=

main()
{
	if [ $QUIET -eq 1 ]; then
		if check_user; then
			echo $USERID
			exit 0
		fi
		exit 1
	fi

	if check_user; then
		# --- VPN and Zenity message (disabled) ---
		# if check_vpn; then
		#     read -d '' -r MSG<<-EOM
		#         This system is configured for: <b>$USERID</b>\n
		#         If this is incorrect, please run 'ioisetup' from Terminal.
		#     EOM
		#     zenity --title="IOI Confirm User" $ZENARG --info \
		#         --text "$MSG"
		#     echo $USERID
		#     exit 0;
		# else
		#     read -d '' -r MSG<<-EOM
		#         This system is configured for: <b>$USERID</b>\n
		#         VPN connection is not working.
		#         Contact HTC for help.
		#     EOM
		#     zenity "$ZENTITLE" $ZENARG --error  \
		#         --text "$MSG"
		#     exit 1;
		# fi
		# --- VPN and Zenity message ---

		# Minimal output to stdout if no VPN check or Zenity
		echo $USERID
		exit 0
	fi

	exit 1
}

check_user()
{
	USERID=
	if ! test -f /etc/tinc/vpn/tinc.conf; then
		return 1
	fi
	USERID=$(cat /etc/tinc/vpn/tinc.conf | grep Name | cut -d\  -f3)
	if [ -z "$USERID" ]; then
		return 1
	fi
	return 0
}

check_vpn()
{
	# --- VPN connectivity check (disabled) ---

	# Try one ping
	# if ping -W 1 -c 1 $POP_SERVER -q > /dev/null; then
	#     return 0
	# fi

	# Then try 3 pings before we declare fail
	# if ping -W 1 -c 3 $POP_SERVER -q > /dev/null; then
	#     return 0
	# fi

	# return 1

	# --- VPN connectivity check ---

	# VPN disabled, always return success for now
	return 0
}

if [ "$1" = "-q" ]; then
	QUIET=1
fi

main "$@"; exit

# vim: ft=sh ts=4 sw=4 noet
