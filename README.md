this readme is a bit out of date

#

    Kernel:          artix
    Init:            s6
    WM:              cinnamon-session-cinammon2d
    Dispay:          xlibre
    Shell:           fish
    Terminal:        kitty

# Parititon

    swapoff -a
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
    
    mount    /dev/nvme0n1p3 /mnt
    mkdir -p /mnt/boot/efi
    mount    /dev/nvme0n1p1 /mnt/boot/efi

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

    echo "setxkbmap uk &" >> ~/.xinitrc

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
    # s6-rc-bundle add default NetworkManager elogind
    
    s6-service add default NetworkManager-srv
    s6-db-reload
    
# Setup packet manager

    su admin
    pacman -S artix-archlinux-support
    pacman-key --populate archlinux
    pacman -S archlinux-mirrorlist

    # uncomment UseSyslog, Color, VerbosepkgLists, ParallelDownloads, [galaxy], [world] and [lib32]

    sudo nano /etc/pacman.conf

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

# install shell
    
    sudo pacman -S fish
    sudo chsh -s /usr/bin/fish admin # set shell

# install graphics drivers

    sudo pacman -S nvidia-utils nvidia nvidia-settings

# install display server

    sudo pacman -S xlibre-xserver xlibre-xserver-{common,devel,xvfb} xlibre-xf86-input-{libinput.evdev,vmmouse} xlibre-xf86-video-{vesa,fbdev,ati,dummy} xorg-{xinit,xmodmap,xrandr,xsetroot,xprop} --ignore xorg-server-dxmx

# install

    sudo pacman -S st feh numlockx file-roller udisks2 thunar steam pulseaudio pavucontrol

    echo "numlockx on &" >> ~/.xinitrc

# install window manager

    sudo pacman -S xfwm4 xfwm4-themes picom
    echo "exec xfwm4" >> ~/.xinitrc
    
# Install 

    reboot

# customizing thunar

    edit -> configure custom actions -> edit open terminal here -> erase everything in Command and replace it with "st" and nothing else.

# xrandr

    exec --no-startup-id xrandr --output HDMI-0 --off --output DP-0 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output DP-2 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output DP-3 --off --output DP-4 --mode 1920x1080 --pos 3840x0 --rotate normal --output DP-5 --off --output HDMI-1-1 --off --output DP-1-1 --off --output DP-1-2 --off --output DP-1-3 --off

# helper functions

    for bundle in (s6-rc-db list bundles); echo "=== $bundle ==="; s6-rc-db contents $bundle; echo; end
    s6-service del default sddm-srv
    s6-service add default sddm-srv
    s6-db-reload

    List of every s6 command: ls /usr/bin/s6* 2>/dev/null || ls /bin/s6* 2>/dev/null

# fix trizen permissions if faulty

    sudo chown -R $USER:$USER ~/.cache/trizen
    sudo chown -R $USER:$USER ~/.config/trizen
