#!/bin/bash

#Testing the network
ping -c 3 www.gentoo.orgs

#Creating Partitions
parted /dev/sda << END 
mklabel gpt 
mkpart primary 1 3 
unit mib
set 1 bios_grub on 
mkpart primary 3 131 
name 2 boot 
mkpart primary 131 643
name 3 swap 
mkpart primary 643 -1 
name 4 rootfs
set 2 boot on
;
END
#creating filesystems
mkfs.ext2 /dev/sda2
mkfs.ext4 /dev/sda4

#mounting partitions
mount /dev/sda4 /mnt/gentoo
mkswap /dev/sda3
sleep 2s
swapon /dev/sda3
sleep 2s
chmod 1777 /var/tmp

#stage3
cd /mnt/gentoo 
sleep 1s
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/20190814T214502Z/stage3-amd64-20190814T214502Z.tar.xz
sleep 1s
cd /mnt/gentoo
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
sleep 1s
cd /mnt/gentoo
echo MAKEOPTS='"-j4"' >> etc/portage/make.conf 
sleep 1s
cd /mnt/gentoo

#Chrooting
mirrorselect -i -o -c TURKEY >> /mnt/gentoo/etc/portage/make.conf
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cd
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

#Mounting the necessary filesystems
mount --types proc /proc /mnt/gentoo/proc
sleep 1s
mount --rbind /sys /mnt/gentoo/sys
sleep 1s
mount --make-rslave /mnt/gentoo/sys
sleep 1s
mount --rbind /dev /mnt/gentoo/dev
sleep 1s
mount --make-rslave /mnt/gentoo/dev

#Entering the new environment
chroot /mnt/gentoo /bin/bash << END
sleep 1s
source /etc/profile
sleep 1s

#!bin/bash
sleep 2s
export PS1="(chroot) ${PS1}"
sleep 2s

#Mounting the boot partition
mount /dev/sda2 /boot
sleep 2s
emerge-webrsync

#Choosing the right profile
eselect profile set 1
sleep 2s

#Updating the @world set
emerge --verbose --update --deep --newuse @world
sleep 2s

#Timezone
echo "Europe/Istanbul" > /etc/timezone
emerge --config sys-libs/timezone-data

#Configure locales
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
sleep 2s

#Installing the sources
emerge  sys-kernel/gentoo-sources

#Configuring the USE variable
emerge  sys-kernel/genkernel

#ACCEPT_LICENSE variable
echo "sys-apps/util-linux static-libs" >> /etc/portage/package.use/util-linux
echo "*/*   *" >> /etc/portage/package.license

#Optional:genkernel
emerge --autounmask-write y sys-kernel/genkernel

echo /dev/sda2   /boot        ext2    defaults,noatime     0 2 >> /etc/fstab
echo /dev/sda3   none         swap    sw                   0 0 >> /etc/fstab
echo /dev/sda4   /            ext4    noatime              0 1 >> /etc/fstab
echo /dev/cdrom  /mnt/cdrom   auto    noauto,user          0 0 >> /etc/fstab
sleep 2s 

genkernel all
sleep 4s

#Networking information
echo hostname='"mehmetozdemir"' > /etc/conf.d/hostname

#Configuring the network
emerge --noreplace net-misc/netifrc

#Dhcp
echo config_enp0s3='"dhcp"' > /etc/conf.d/net


#The hosts file
echo 127.0.0.1      mehmetozdemir.online mehmetozdemir > /etc/hosts
echo ::1            localhost >> /etc/hosts

# #System information
echo 'root:asd123asd123' | chpasswd

# #System logger
emerge  app-admin/sysklogd
rc-update add sysklogd default

# #Networking tools
emerge net-misc/dhcpcd

# #Default: GRUB2
emerge --verbose sys-boot/grub:2
grub-install /dev/sda

# #Configure
grub-mkconfig -o /boot/grub/grub.cfg

#User administration
useradd -m -G users,wheel,audio -s /bin/bash mehmetozdemir
echo 'mehmetozdemir:mehmetozdemir123' | chpasswd
END

#Rebooting the system
sleep 2s
cd 
umount -l /mnt/gentoo/dev{/shm,/pts,}
sleep 1s 
umount -R /mnt/gentoo 
sleep 1s
reboot

#Disk cleanup
rm /stage3-*.tar.*
