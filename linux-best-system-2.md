# Parititon

    cfdisk /dev/nvme0n1
    
      200M EFI System
      16G Linux swap
      [All] Linux filesystem

    lsblk
    mkfs.fat -F32 /dev/nvme0n1p1
    mkswap        /dev/nvme0n1p2
    swapon        /dev/nvme0n1p2
    mkfs.ext4     /dev/nvme0n1p3

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

    # Set system time
    ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
    Confirm by sending `date`.
    hwclock --systohc
    nano /etc/locale.gen
        Uncomment `en_GB.UTF-8`.
    locale-gen
    echo 'LANG="en_GB.UTF-8"' >> /etc/locale.conf
    
    Confirm with `cat /etc/locale.conf`.

    # Specify the keyboard layout for the console
    nano /etc/vconsole.conf
        KEYMAP=uk
        FONT=ter-d14b

    pacman -S nano terminus-font grub efibootmgr networkmanager networkmanager-s6
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=artix

    nano /etc/default/grub
    GRUB_TIMEOUT=0 #modify this from 5 to 0
    grub-mkconfig -o /boot/grub/grub.cfg
    
    nano /etc/hostname
        machine
    
    nano /etc/hosts
        127.0.0.1        localhost
        ::1              localhost
        127.0.1.1        machine.localdomain  machine

# User account stuff

    useradd -mG wheel admin
    passwd admin
    <password>
    EDITOR=nano visudo
    # Uncomment out `%wheel ALL=(ALL:ALL) ALL` and save
    passwd root
    <password>

# Enable network manager on boot

    touch /etc/s6/adminsv/default/contents.d/networkmanager
    touch /etc/s6/adminsv/default/contents.d/elogind

    s6-db-reload

    s6-rc-bundle add default NetworkManager elogind

# Setup packet manager

    su admin # the-machine

    sudo nano /etc/pacman.conf
    # uncomment UseSyslog, Color, VerbosepkgLists, ParallelDownloads, [galaxy], [world] and [lib32]

# Back the fuck up, it's about to go down.

    pacman -S timeshift
    timeshift --create

# All down hill from here
    
    sudo pacman -Sy 
    sudo pacman -S git librewolf fish
    sudo chsh -s /usr/bin/fish admin # set shell
