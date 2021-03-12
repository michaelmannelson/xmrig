#!/bin/bash

#wget "https://github.com/michaelmannelson/xmrig/raw/main/setup.sh"
#chmod +x "setup.sh"
#sudo ./setup.sh

wget https://github.com/michaelmannelson/xmrig/archive/main.zip
unzip main.zip
mkdir -p "$HOME/xmrig"
mv -f xmrig-main/* "$HOME/xmrig"
chmod +x "$HOME/xmrig/install.sh"
read -p "url: " url
read -p "user: " user
echo "$HOME/xmrig/install.sh -o \"$url\" -u \"$user\" -p \"`uname -o`.`uname -s`.`uname -n`.`uname -m`.$(date +%Y%m%d@%H%M%S%z)\" -c \"$HOME/xmrig/config.json\""
rm -rf main.zip
rm -rf setup.sh

