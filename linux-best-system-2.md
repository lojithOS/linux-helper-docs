# Parititon

    cfdisk /dev/nvme0n1
    
      200M EFI System
      16G Linux swap
      [All] Linux filesystem

    lsblk
    mkfs.fat -F32 /dev/nvme0n1p1
    mkswap /dev/nvme0n1p2
    swapon /dev/nvme0n1p2
    mkfs.ext4 /dev/nvme0n1p3

# Mounting file system
    
    mount /dev/nvme0n1p3 /mnt
    mkdir /mnt/boot
    mkdir /mnt/boot/efi
    mount /dev/nvme0n1p1 /mnt/boot/efi

    lsblk
        ❯ lsblk
        NAME           MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
        nvme0n1              8:0    0    83G  0 disk 
        ├──nvme0n1p1          8:1    0   200M  0 part /mnt/boot/efi
        └──nvme0n1p2          8:2    0    15G  0 part [SWAP]
        └──nvme0n1p3          8:3    0   782G  0 part /mnt

# Begin installing system

    basestrap /mnt base base-devel linux linux-firmware s6 elogind-s6
    fstabgen -U /mnt >> /mnt/etc/fstab

    artix-chroot /mnt

# Setting up system

    pacman -S nano terminus-font grub efibootmgr networkmanager networkmanager-s6 
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

    
