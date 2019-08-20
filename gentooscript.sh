#!/bin/bash
VBoxManage createvm  --name "Gentoo" --register
VBoxManage list ostypes | less
VBoxManage modifyvm "Gentoo" --memory 2048 --cpus 4 --nic1 nat --acpi on --boot1 dvd  --ostype Gentoo_64

VBoxManage createhd  --filename 'Gentoo'.vdi --size 16384 --format VDI
VBoxManage modifyvm "Gentoo" --hda 'Gentoo'.vdi

VBoxManage storagectl "Gentoo" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach "Gentoo" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium 'Gentoo'.vdi
cd
VBoxManage storagectl "Gentoo" --name "IDE Controller" --add ide
VBoxManage storageattach "Gentoo" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium Downloads/install-amd64-minimal-20190728T214502Z.iso

VBoxManage startvm Gentoo
VBoxManage controlvm Gentoo  --vrde on

VBoxManage snapshot Gentoo take Gentoo snapshot
VBoxManage snapshot Gentoo restore Gentoo snapshot

#echo "gentoo dopcmcia"
