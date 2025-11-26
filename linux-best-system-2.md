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

    Reboot into live environment

    sudo su

# Enable network manager on boot

    ping google.com
    
    # enable network manager is no network connection
    s6-rc -u change NetworkManager
    # enable all services so they're enabled on boot
    s6-rc-bundle add default NetworkManager elogind

# Setup packet manager

    su admin
    pacman -S artix-archlinux-support
    pacman-key --populate archlinux
    pacman -S archlinux-mirrorlist

    # uncomment UseSyslog, Color, VerbosepkgLists, ParallelDownloads, [galaxy], [world] and [lib32]

    # add the following
        # Arch
        [extra]
        Include = /etc/pacman.d/mirrorlist-arch
        [multilib]
        Include = /etc/pacman.d/mirrorlist-arch
    # finally...
    sudo pacman -Sy
    
# Back the fuck up, it's about to go down.

    pacman -S timeshift
    timeshift --create

# Update, install, and set shell
    
    sudo pacman -Sy 
    sudo pacman -S fish
    sudo chsh -s /usr/bin/fish admin # set shell

# install graphics drivers

    sudo pacman https://archive.artixlinux.org/packages/n/nvidia-utils/nvidia-utils-570.144-1-x86_64.pkg.tar.zst
    sudo pacman https://archive.artixlinux.org/packages/n/nvidia/nvidia-570.144-2-x86_64.pkg.tar.zst
    sudo pacman https://archive.artixlinux.org/packages/n/nvidia-settings/nvidia-settings-570.144-1-x86_64.pkg.tar.zst

# install display server

    sudo pacman -S xlibre-xserver xlibre-xserver-{common,devel,xvfb} xlibre-xf86-input-{libinput.evdev,vmmouse}
    Removed: xlibre-xf86-video-{amdgpu,vesa,fbdev,ati,dummy}
    sudo pacman -S xorg-{xinit,xmodmap,xrandr,xsetroot,xprop} --ignore xorg-server-dxmx
    
    # don't know if I'll need it but `xorg --ignore xorg-server-dxmx`

# install login manager

    sudo pacman sddm sddm-s6
    s6-rc-bundle-update add default sddm
    
# install goodies

    sudo pacman -S plasma kitty librewolf ranger

    reboot
