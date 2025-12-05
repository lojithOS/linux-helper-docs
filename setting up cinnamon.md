# Uninstalling bullcrap

    sudo pacman -Rsn cachyos-micro-settings micro \
                     cachyos-zsh-config vim \
                     cachyos-kernel-manager \
                     cachyos-packageinstaller \
                     alacritty \
                     meld \
                     btrfs-assistant

# Installing preferred software

    sudo pacman -S gnome-calculator xed brave steam
    
    sudo pacman -S flatpak
    flatpak install flathub com.discordapp.Discord
    
# Setting up keyboard shortcuts

    === Windows ===
    SUPER+f        toggle fullscreen state
    SUPER+Escape   close window 

    === System ===
    SHIFT+ALT+r    restart Cinnamon
    SHIFT+ALT+q    log out
    
    === Launchers ===
    SUPER+q        terminal
    SUPER+e        nemo
    
    === Custom shortcuts ===
    SUPER+t        telegram
    SUPER+b        brave / browser
    SUPER+v        vscode
    SUPER+s        steam

# Fans

    sudo pacman -S liquidctl
    sudo liquidctl --match kraken set pump speed 79

    git clone https://github.com/lojithOS/thimblefans.git
    cd thimblefans
    ./install.sh
    
# Startup Applications

    add fan_control_speed, duh.
    
    Getting brave (kick) to auto start: git clone https://github.com/lojithOS/chrome-extension-start-with-sound.git

# Menu

    Edit menu or move it to the top just to show the clock.

# Monitors

    Right-click desktop -> display, set refresh rate to 144 and middle monitor to primary

    
