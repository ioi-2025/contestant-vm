#!/bin/bash

source /opt/ioi/config.sh

check_ip()
{
    local IP=$1

    if expr "$IP" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
        return 0
    else
        return 1
    fi
}

logger -p local0.info "IOICONF: invoke $1"

case "$1" in
    fwstart)
        if [ -e /opt/ioi/run/lockdown ]; then
            echo Not allowed to control firewall during lockdown mode
        else
            /opt/ioi/sbin/firewall.sh start
        fi
        ;;
    fwstop)
        if [ -e /opt/ioi/run/lockdown ]; then
            echo Not allowed to control firewall during lockdown mode
        else
            /opt/ioi/sbin/firewall.sh stop
        fi
        ;;
    settz)
        tz=$2
        if [ -z "$2" ]; then
            cat - <<EOM
No timezone specified. Run tzselect to learn about the valid timezones
available on this system.
EOM
            exit 1
        fi
        if [ -f "/usr/share/zoneinfo/$2" ]; then
            cat - <<EOM
Your timezone will be set to $2 at your next login.
*** Please take note that all dates and times communicated by the IOI 2024 ***
*** organisers will be in America/La_Paz timezone (GMT-4), unless it is     ***
*** otherwise specified.                                                   ***
EOM
            echo "$2" > /opt/ioi/config/timezone
        else
            cat - <<EOM
Timezone $2 is not valid. Run tzselect to learn about the valid timezones
available on this system.
EOM
            exit 1
        fi
        ;;
    setautobackup)
        if [ "$2" = "on" ]; then
            touch /opt/ioi/config/autobackup
            echo Auto backup enabled
        elif [ "$2" = "off" ]; then
            if [ -f /opt/ioi/config/autobackup ]; then
                rm /opt/ioi/config/autobackup
            fi
            echo Auto backup disabled
        else
            cat - <<EOM
Invalid argument to setautobackup. Specify "on" to enable automatic backup
of home directory, or "off" to disable automatic backup. You can always run
"ioibackup" manually to backup at any time. Backups will only include
non-hidden files less than 100KB in size.
EOM
        fi
        ;;
    setscreenlock)
        if [ "$2" = "on" ]; then
            touch /opt/ioi/config/screenlock
            sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.screensaver lock-enabled true
            echo Screensaver lock enabled
        elif [ "$2" = "off" ]; then
            if [ -f /opt/ioi/config/screenlock ]; then
                rm /opt/ioi/config/screenlock
            fi
            sudo -Hu ioi dbus-run-session gsettings set org.gnome.desktop.screensaver lock-enabled false
            echo Screensaver lock disabled
        else
            cat - <<EOM
Invalid argument to setscreenlock. Specify "on" to enable screensaver lock,
or "off" to disable screensaver lock.
EOM
        fi
        ;;
    getpubkey)
        echo "No public key fetch needed."
        exit 0
        ;;
    keyscan)
        echo "No keyscan required."
        ;;
    *)
        echo Not allowed
        ;;
esac

# vim: ft=sh ts=4 sw=4 noet
