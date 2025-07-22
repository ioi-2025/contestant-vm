#!/bin/bash

set -x
set -e

# Remove/clean up unneeded snaps

snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
	snap remove "$snapname" --revision="$revision"
done

# Remove the snapd packagess
./setup.d/./01-clean-unused-packages.sh
