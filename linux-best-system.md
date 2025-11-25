This is an installation guide for what I hope will be the best possible linux system.
It's meant to be extremely low resource demanding while being able to pack all the punches of high-end systems.

    OS: Artix x86_64
    Init Sys: runit
    Kernel: Linux
    Shell: Fish
    WM: dwm
    Display Server: XLibre
    Terminal: st

## Partition
    
    Send `cfdisk /dev/nvme0n1` them specify gpt.
    Select [New], set the size to 1G and confirm.
    Move down to create a second.
    Select [New] again and confirm the default size, which is the remainder of the drive.
    Navigate right to [Write] and confirm.
    We'll set up SWAP later.

## Encryption

    Send `cryptsetup -v luksFormat /dev/nvme0n1p2`
    Send `YES`
    Specify a password

    Send `cryptsetup open /dev/nvme0n1p2 cryptroot`
    Enter password

    confirm with `lsblk. Should look something like this.

    ❯ lsblk
    NAME           MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    loop 0           7:0    0 782.3M  1 loop /run/artix/sfs/rootfs
    nvme0n1              8:0    0    83G  0 disk 
    ├──nvme0n1p1          8:1    0     1G  0 part
    └──nvme0n1p2          8:2    0    82G  0 part
      └──cryptroot 254:0    0    82G  0 crypt
    sr0             11:0    1 992.1M  0 rom   /run/artix/bootmnt

    Finally, send `mkfs.ext4 /dev/mapper/cryptroot

## Mounting file systems

    mount /dev/mapper/cryptroot /mnt
    mkdir /mnt/boot
    mkfs.fat -F 32 /dev/nvme0n1p1
    mount /dev/nvme0n1p1 /mnt/boot
    
    confirm with `lsblk. Should look something like this.

    ❯ lsblk
    NAME           MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    loop 0           7:0    0 782.3M  1 loop /run/artix/sfs/rootfs
    nvme0n1              8:0    0    83G  0 disk 
    ├──nvme0n1p1          8:1    0     1G  0 part /mnt/boot
    └──nvme0n1p2          8:2    0    82G  0 part
      └──cryptroot 254:0    0    82G  0 crypt /mnt
    sr0             11:0    1 992.1M  0 rom   /run/artix/bootmnt

## Begin installing system

    # if you find you don't have internet send `s6-rc -u change dhcpcd-srv`

    basestrap /mnt base base-devel s6-base elogind-s6
    [Enter]
    Wait a while...
    basestrap /mnt linux linux-firmware sof-firmware grub efibootmgr networkmanager networkmanager-s6 network-manager-applet dosfstools linux-headers nano 
    [Enter]
    Wait a while...
    Congrats, Linux is officially installed.
    basestrap /mnt lvm2 cryptsetup
    [Enter]
    Make the mount permanent with `fstabgen -U /mnt >> /mnt/etc/fstab`
    artix-chroot /mnt

## adding swap file

    dd if=/dev/zero of=/swapfile bs=1G count=2 status=progress
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    nano /etc/fstab
    add `/swapfile none swap default 0 0` at the bottom of the file.

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
    the-machine

    nano /etc/hosts
    127.0.0.1        localhost
    ::1              localhost
    127.0.1.1        the-machine.localdomain  the-machine

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

    grub-install --efi-directory=/boot --bootloader-id=artix /dev/nvme0n1

## Install setup GRUB to handle encrypted device at boot

    nano /etc/default/grub
    Next we'll add a placeholder for a UUID we'll insert afterwards
    modify line near top `GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet", to "loglevel=3 quiet cryptdevice=UUID=LUKS_UUID_HERE:cryptroot root=UUID=ROOT_UUID_HERE"

    set -i "s|LUKS_UUID_HERE|$(blkid -o value -s UUID /dev/nvme0n1p2)|" /etc/default/grub
    sed -i "s|ROOT_UUID_HERE|$(blkid -o value -s UUID /dev/mapper/cryptroot)|" /etc/default/grub

    confirm everything looks alright by looking at `nano /etc/default/grub`.

    grub-mkconfig -o /boot/grub/grub.cfg

## Enable network manager now (if for whatever reason it's not active)

    s6-rc -u change NetworkManager

## Enable network manager on boot

    sudo pacman -S iproute2 ethtool openvpn networkmanager-openvpn networkmanager-vpn-plugin-openvpn
    # Don't panic if this doesn't work.
    touch /etc/s6/adminsv/default/contents.d/networkmanager
    touch /etc/s6/adminsv/default/contents.d/elogind
    s6-db-reload
    # alternatively, do on local user
    s6-rc-bundle add default NetworkManager elogind

## Unlocking goodies

    su lojith # the-machine

    sudo nano /etc/pacman.conf
    uncomment UseSyslog, Color, VerbosepkgLists, ParallelDownloads. Add ILoveCandy

    # UseSyslos is self explanatory
    # Color adds color, making the terminal more readable
    # VerbosePkgLists makes pacman show full list of dependencies and associations
    # ParallelDownloads is self explanatory
    # ILoveCandy adds a little candy graphic in loading bars

    scroll down and make sure [galaxy], [world] and [lib32] is uncommented working.

    sudo pacman -Sy 
    sudo pacman -S git librewolf git fish nvidia nvidia-utils nvidia-settings ` to unlock all the goodies.
    sudo chsh -s /usr/bin/fish lojith # set shell
    
## Display server stuff

    sudo pacman -S xlibre-xserver xlibre-xserver-{common,devel,xvfb} xlibre-xf86-video-{amdgpu,vesa,fbdev,ati,dummy} xlibre-xf86-input-{libinput.evdev,vmmouse}

    #err, you sure?
    #sudo pacman -S xorg-{xinit,xmodmap,xrandr,xsetroot,xprop}

## Window Manager stuff

    cd ~/
    mkdir artix-dotfiles
    cd artix-dotfiles/

    git clone git://git.suckless.org/dwm dwm #second dwm appears intentional
    git clone git://git.suckless.org/st
    git clone git://git.suckless.org/dmenu

    cd dwm
    sudo make clean install
    cd ../st
    sudo make clean install
    cd ../dmenu
    sudo make clean install

    cd ~

    # set dwm startup on boot
    touch .xinitrc
    echo 'exec dwm' >> .xinitrc

    exit # exit lojith
    exit # exit into live cd
    lsblk
    unmount -a
    reboot

    login
    sudo startx # to start wm
    # s6-svc -u ~/.s6/services/dwm

    # Create the directory for the service
    SERVICE_DIR="/etc/s6/services/$SERVICE_NAME"
    sudo mkdir -p "$SERVICE_DIR"
    
    # Create the run script for the service
    sudo tee "$SERVICE_DIR/run" > /dev/null <<'EOF'
    #!/bin/sh
    exec startx
    EOF
    
    # Make the run script executable
    sudo chmod +x "$SERVICE_DIR/run"
    
    # Start the s6 service if it's not already running
    sudo s6-svscan /etc/s6/services &
