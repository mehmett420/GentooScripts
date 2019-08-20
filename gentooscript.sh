#!/bin/bash
VBoxManage createvm  --name "Gentoo1" --register
VBoxManage list ostypes | less
VBoxManage modifyvm "Gentoo1" --memory 2048 --cpus 4 --nic1 nat --acpi on --boot1 dvd  --ostype Gentoo_64

VBoxManage createhd  --filename 'Gentoo1'.vdi --size 16384 --format VDI
VBoxManage modifyvm "Gentoo1" --hda 'Gentoo1'.vdi

VBoxManage storagectl "Gentoo1" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach "Gentoo1" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium 'Gentoo1'.vdi
cd
VBoxManage storagectl "Gentoo1" --name "IDE Controller" --add ide
VBoxManage storageattach "Gentoo1" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium Downloads/install-amd64-minimal-20190728T214502Z.iso

VBoxManage startvm Gentoo1
VBoxManage controlvm Gentoo1  --vrde on

VBoxManage snapshot Gentoo1 take Gentoo1 snapshot
VBoxManage snapshot Gentoo1 restore Gentoo1 snapshot

#echo "gentoo dopcmcia"
