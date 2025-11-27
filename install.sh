#!/bin/bash

TARGET_I3_CONFIG="/etc/i3/config"

echo "This install script takes all the files and stuff and moves it onto your system".

read -r -p "Overwrite your i3 config? (y/n) " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        sudo cp "config" "$TARGET_I3_CONFIG"
fi
