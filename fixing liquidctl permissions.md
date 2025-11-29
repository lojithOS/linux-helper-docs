in sudoers `(sudo EDITOR=nano sudoers)`, add `<username> ALL=(ALL) NOPASSWD: /usr/bin/liquidctl *`. Make sure it's underneath the line `%wheel ALL=(ALL:ALL) ALL` else it'll just overwrite it.

in your shell config file, you'll want something like `sudo  -n /usr/bin/liquidctl --match kraken set pump speed 90`.
