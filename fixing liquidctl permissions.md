    lojith@machine ~> sudo groupadd -r liquidctl # -r makes it a system account
    lojith@machine ~> sudo usermod -aG liquidctl lojith
      docsBus 001 Device 009: ID 1e71:300c NZXT NZXT Kraken Elite
    lojith@machine ~ [1]> ls -l /dev/hidraw7
      crw-rw----+ 1 root liquidctl 243, 7 Nov 24 07:53 /dev/hidraw7
    lojith@machine ~> sudo liquidctl status
    [sudo] password for lojith:
      NZXT Kraken 2023 Elite (broken)
      ├── Liquid temperature    24.3  °C
      ├── Pump speed             923  rpm
      ├── Pump duty               20  %
      ├── Fan speed                0  rpm
      └── Fan duty                20  %
    lojith@machine ~> cat /etc/udev/rules.d/71-liquidctl.rules
      SUBSYSTEM=="hidraw", KERNEL=="hidraw*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1e71", ATTRS{idProduct}=="300c", TAG+="uaccess", GROUP="liquidctl", MODE="0660"
    lojith@machine ~ [127]> whoami
      lojith
    lojith@machine ~> id lojith
      uid=1000(lojith) gid=1000(lojith) groups=1000(lojith),998(wheel),1001(plugdev),973(liquidctl)
    lojith@machine ~> newgrp liquidctl
      Welcome to fish, the friendly interactive shell
      Type help for instructions on how to use fish
    lojith@machine ~> ls -l /dev/hidraw7
      crw-rw----+ 1 root liquidctl 243, 7 Nov 24 07:53 /dev/hidraw7
    lojith@machine ~> liquidctl status
      ValueError: The device has no langid (permission issue, no string descriptors supported or device error)
    lojith@machine ~ [1]> sudo setfacl -m u:$(whoami):rw /dev/hidraw7
    lojith@machine ~> liquidctl status
      ValueError: The device has no langid (permission issue, no string descriptors supported or device error)
    lojith@machine ~ [1]> getfacl /dev/hidraw7
      getfacl: Removing leading '/' from absolute path names
      # file: dev/hidraw7
      # owner: root
      # group: liquidctl
      user::rw-
      user:lojith:rw-
      group::rw-
      mask::rw-
      other::---
    
    `sudo nano /etc/udev/rules.d/71-liquidctl.rules` #looks like
    	# hidraw node (already present)
    	SUBSYSTEM=="hidraw", KERNEL=="hidraw*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1e71", ATTRS{idProduct}=="300c", TAG+="uaccess", GROUP="liquidctl", MODE="0660"
    	
    	# usb bus device node (/dev/bus/usb/BBB/DDD)
    	SUBSYSTEM=="usb", ATTR{idVendor}=="1e71", ATTR{idProduct}=="300c", TAG+="uaccess", GROUP="liquidctl", MODE="0660"
    lojith@machine ~> sudo udevadm control --reload
    lojith@machine ~> sudo udevadm trigger
    
    # then reboot
