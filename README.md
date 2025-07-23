# IOI Contestant VM

A reference VM setup for IOI contestants, based on Ubuntu 24.04 Server.

---

## Quick Start: Automated Setup (QEMU-based)
### Requirements
Install KVM

For automated VM creation and installation (useful for testing or development):

```bash
cd autoinstall
./start-autoinstall.sh
```
- This script creates a VM disk, downloads the Ubuntu ISO, serves files via HTTP, and launches QEMU with the correct parameters.

---

## Manual Setup

1. **Create a VM**
   - Specs: 2 VCPU, 4 GB RAM, 25 GB disk.
   - *Important:* During Ubuntu installation, uncheck "Set up this disk as an LVM group".
   - Create a user account named `ansible`.

2. **Clone and Configure the Repository**
   ```bash
   git clone https://github.com/ioi-2025/contestant-vm
   sudo -s
   cd contestant-vm
   cp config.local.sh.sample config-.local.sh   # Edit as needed
   cp config.sh.sample config.sh               # Edit as needed
   ./setup.sh
   ./cleanup.sh
   cd ..
   rm -rf contestant-vm
   ```

3. **Power Off the VM**
   - Shut down the VM after installation and cleanup.

---

## Finalizing the VM Image

1. **Zero-out Free Space**
   - Boot from install/rescue CDROM (change boot order if needed).
   - Open a shell (`Ctrl+Alt+F2`) and run:
     ```bash
     sudo zerofree -v /dev/sda2
     ```
   - Shut down the VM.

2. **Prepare for Export**
   - Remove all CD-ROM and floppy drives from VM settings.
   - Compact the hard disk.
   - Export to OVF/OVA format (e.g., `File > Export to OVF`, use `.ova` extension).

---

## Exporting to .ova with VMware OVF Tool (Mac Example)

```bash
NAME="vm-name"
VM_LOCATION="$HOME/Virtual Machines.localized/$NAME.vmwarevm/$NAME.vmx"
OVA_FILEPATH="$(pwd)/$NAME.ova"

cd "/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool"
./ovftool --acceptAllEulas "$VM_LOCATION" "$OVA_FILEPATH"
```

---

## Disabling Side Channel Mitigations

Reference: [VMware KB 79832](https://kb.vmware.com/s/article/79832)

If you lack VMware Pro, manually edit the `.ovf` file:

```bash
old_pwd=$(pwd)
tempdir=$(mktemp -d)

tar --same-owner -xvf $OVA_FILEPATH -C "$tempdir"
cd "$tempdir"

# Insert or edit lines in *.ovf:
# <vmw:ExtraConfig ovf:required="false" vmw:key="ulm.disableMitigations" vmw:value="TRUE"/>
# <vmw:Config ovf:required="false" vmw:key="tools.syncTimeWithHost" vmw:value="false"/>

openssl sha256 $NAME.ovf $NAME.vmdk > $NAME.mf

chown 64:64 $NAME*.ovf $NAME*.mf $NAME*.vmdk
tar -cvf "$OVA_FILEPATH" $NAME*.ovf $NAME*.mf $NAME*.vmdk

cd "$old_pwd"
rm -rf "$tempdir"
```

---

## Project Structure

- `setup.sh` – Runs all provisioning scripts in `setup.d/` using settings from `config.sh` and `config.local.sh`.
- `cleanup.sh` – Cleans logs, caches, swap, and histories to prepare the VM for export.
- `autoinstall/start-autoinstall.sh` – Automates VM creation and installation using QEMU.
- `config.sh` / `config.local.sh` – Configuration files for customizing the VM setup.
