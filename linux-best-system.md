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

    basestrap /mnt base base_devel openrc elogind-openrc
    [Enter]

    Wait a while...

    basestrap /mnt linux linux-firmware sof-firmware grub efibootmgr networkmanager networkmanager-openrc nano neofetch 
