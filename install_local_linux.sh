#!/bin/bash

# # Check if the script is run as root
# if [ "$(id -u)" -ne 0 ]; then
#     echo "Please run this script as root"
#     exit 1
# fi

flutter build linux --release
cp -r build/linux/x64/release/bundle/* ~/.local/bin/mpt
rm ~/.local/bin/MPT
ln -s ~/.local/bin/mpt/meeting_planning_tool ~/.local/bin/MPT
