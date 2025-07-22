#!/bin/bash

set -x
set -e

sudo apt install software-properties-common -y
sudo add-apt-repository ppa:mozillateam/ppa -y

echo '
Package: *
Pin: origin ppa.launchpadcontent.net
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1' | tee /etc/apt/preferences.d/mozilla

# Force apt to use http instead of https,
# because the PPA is not available over https
# because we use a proxy to speed up the downloads
sudo sed -i 's|https://|http://|g' /etc/apt/sources.list.d/*

sudo apt update -y

sudo apt install firefox -y
