This is an installation guide for what I hope will be the best possible linux system.
It's meant to be extremely low resource demanding while being able to pack all the punches of high-end systems.

    OS: Artix x86_64
    Init Sys: runit
    Kernel: Linux
    Shell: Fish
    WM: csm (calm window manager)
    Display Server: XLibre
    Terminal: stw

## Partition
    
    Send `dfdisk /dev/sda` them specify gpt.
    Select [New], set the size to 1G and confirm.
    Move down to create a second.
    Select [New] again and confirm the default size, which is the remainder of the drive.
    Navigate right to [Write] and confirm.
    We'll set up SWAP later.

## Encryption

    Send `cryptsetup -v luksFormat /dev/sda2`
    Send `YES`
    Specify a password

    Send `cryptsetup open /dev/sda2 cryptroot`
    Enter password

    confirm with `lsblk. Should look something like this.

    ❯ lsblk
    NAME           MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    loop 0           7:0    0 782.3M  1 loop /run/artix/sfs/rootfs
    sda              8:0    0    83G  0 disk 
    ├──sda1          8:1    0     1G  0 part
    └──sda2          8:2    0    82G  0 part
      └──cryptroot 254:0    0    82G  0 crypt
    sr0             11:0    1 992.1M  0 rom   /run/artix/bootmnt

    Finally, send `mkfs.ext4 /dev/mapper/cryptroot

## Mounting file systems

    mount /dev/mapper/cryptroot /mnt
    mkdir /mnt/boot
    mkfs.far -F 32 /dev/sda1
    mount /dev/sda1 /mnt/boot
    
    confirm with `lsblk. Should look something like this.

    ❯ lsblk
    NAME           MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    loop 0           7:0    0 782.3M  1 loop /run/artix/sfs/rootfs
    sda              8:0    0    83G  0 disk 
    ├──sda1          8:1    0     1G  0 part /mnt/boot
    └──sda2          8:2    0    82G  0 part
      └──cryptroot 254:0    0    82G  0 crypt /mnt
    sr0             11:0    1 992.1M  0 rom   /run/artix/bootmnt

## Begin installing system

    basestrap /mnt base base_devel s6-base elogind-s6
    [Enter]
    Wait a while...
    basestrap /mnt linux linux-firmware sof-firmware grub efibootmgr networkmanager networkmanager-s6 nano neofetch 
    [Enter]
    Wait a while...
    Congrats, Linux is officially installed.
    basestrap /mnt lvm2 cryptsetup
    [Enter]
    Make the mount permanent with `fstabgen -U /mnt >> /mnt/etc/fstab`
    artix-chroot /mnt

## Setting up system

    ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
    Confirm by sending `date`.
    hwclock --systohc
    nano /etc/locale.gen
    Uncomment `en_GB.UTF-8`.
    Send `locale-gen`
    echo 'LANG="en_GB.UTF-8"' >> /etc/locale.conf

    Confirm with `cat /etc/locale.conf`.

    nano /etc/hostname
    lojith

    nano /etc/hosts
    127.0.0.1        localhost
    ::1              localhost
    127.0.1.1        lojith.localdomain  lojith

    pacman -S dhclient

## User account stuff

    passwd: <new password>
    useradd -m -G wheel -s /bin/bash lojith
    passwd lojith
    <password>

    Send `EDITOR=nano visudo`
    Uncomment out `%wheel ALL=(ALL:ALL) ALL` and save.

## Add support for encrypted root partitions and local volume management

    nano /etc/mkinitcpio.conf
    Modify the line `HOOKS=(base udev autodetect microcode modconf cms keyboard meymap consolefont block filesystems fsck)`, adding `encrypt` and `lvm2` after block.
    Conclude by sending `sudo mkinitcpio -P`.


## Install bootloader

    grub-install --efi-directory=/boot --bootloader-id=artix /dev/sda

## Modify GRUB to handle encrypted device at boot

    nano /etc/default/grub
    Next we'll add a placeholder for a UUID we'll insert afterwards
    modify line near top `GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet", to "loglevel=3 quiet cryptdevice=UUID=LUKS_UUID_HERE:cryptroot root=UUID=ROOT_UUID_HERE"

    set -i "s|LUKS_UUID_HERE|$(blkid -o value -s UUID /dev/sda2)|" /etc/default/grub
    sed -i "s|ROOT_UUID_HERE|$(blkid -o value -s UUID /dev/mapper/cryptroot)|" /etc/default/grub

    confirm everything looks alright by looking at `nano /etc/default/grub`.

    
    
