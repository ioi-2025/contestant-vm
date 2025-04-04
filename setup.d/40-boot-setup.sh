#!/bin/bash

set -x
set -e

sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/splash//' /etc/default/grub
update-grub2

echo "boot-setup: works, but disabled due to inconveniences"
echo "- snapshot can be found by Ubuntu's sidebar, which is annoying"
echo "- Rethink logic:"
echo "  - is 15 sec enough?"
exit 0

cat <<'EOM' >/etc/initramfs-tools/hooks/zerofree
#!/bin/sh
PREREQ=""
prereqs()
{
   echo "$PREREQ"
}

case $1 in
prereqs)
   prereqs
   exit 0
   ;;
esac

. /usr/share/initramfs-tools/hook-functions

if [ ! -x "/sbin/zerofree" ]; then
  exit 1
fi

copy_exec /sbin/zerofree /sbin
exit 0
EOM
chmod 755 /etc/initramfs-tools/hooks/zerofree

cat <<'EOM' >/etc/initramfs-tools/scripts/local-premount/prompt
#!/bin/sh
PREREQ="lvm"
prereqs()
{
   echo "$PREREQ"
}

case $1 in
prereqs)
   prereqs
   exit 0
   ;;
esac

# Source: thicc-boiz repository from KSZK

set -e

# functions

panic()
{
  echo ""
  echo "ERROR!!!"
  echo "AUTO ROLLBACK FAILED: ${@}"
  exit 1
}

banner()
{
  echo ""
  echo "=== ${@} ==="
  echo ""
  sleep 2
}

create_snapshot()
{
  dd bs=1048576 if=/dev/nvme0n1p2 of=/diskimage/image.img
  touch /diskimage/snapshot.created
}

rollback_snapshot()
{
  dd bs=1048576 if=/diskimage/image.img of=/dev/nvme0n1p2
}

mkdir /diskimage
mount /dev/nvme0n1p3 /diskimage


if [ -f "/diskimage/snapshot.created" ]; then
  echo ""
  echo "  ==================================================="
  echo "             Snapshot creation disabled,"
  echo "               snapshot already exists!"
  echo "  ==================================================="
  echo ""

else
  echo ""
  echo "  ==================================================="
  echo "                   Creating snapshot!"
  echo "  ==================================================="
  echo ""

  banner "Creating snapshot"
  create_snapshot
  umount  /diskimage
  mount /dev/nvme0n1p2 /diskimage
  touch /diskimage/prevent.rollback
  umount  /diskimage
  banner "Successfully created snapshot, press any key to shutdown"
  read -n 1
  banner "Shutting down"
  poweroff -f
fi

umount  /diskimage
mount /dev/nvme0n1p2 /diskimage

if [ -f "/diskimage/prevent.rollback" ]; then
  umount  /diskimage
  banner "Rollback disabled!"
else
  umount  /diskimage
  echo ""
  echo "  ==================================================="
  echo "           Press any key to attempt rollback!"
  echo "                Booting up in 15 seconds"
  echo "  ==================================================="
  echo ""

  if ! read -t 15 -n 1; then

    banner "Rollback aborted! The filesystem contents will be preserved!"
    exit 0
  else
    mount /dev/nvme0n1p3 /diskimage
    banner "Rolling back"
    rollback_snapshot
    umount  /diskimage
    mount /dev/nvme0n1p2 /diskimage
    touch /diskimage/prevent.rollback
    umount  /diskimage
    banner "Successfull rollback, press any key to reboot"
    read -n 1
    banner "Rebooting"
    reboot -f
  fi
fi
EOM
chmod 755 /etc/initramfs-tools/scripts/local-premount/prompt

update-initramfs -uv
