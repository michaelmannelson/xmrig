#!/bin/bash

: '

rm -rf "$HOME/xmrig" && mkdir -p "$HOME/xmrig" && cd "$HOME/xmrig"
wget "https://github.com/michaelmannelson/xmrig/raw/main/install.sh"
wget "https://github.com/michaelmannelson/xmrig/raw/main/config.5.json" -O "config.json"
chmod +x "install.sh"
./install.sh -p "`uname -o`.`uname -s`.`uname -n`.`uname -m`.$(date +%Y%m%d@%H%M%S%z)" -c "$HOME/xmrig/config.json"

'

declare -r args=("$@")
declare argHelp=0
declare argUrl=""
declare argUser=""
declare argPass=""
declare argConfig=""

declare param=""
for arg in ${args[@]}; do
    if   [ "$arg" == "-h" ] || [ "$arg" == "--help"   ]; then argHelp=1 && param=""; continue
    elif [ "$arg" == "-o" ] || [ "$arg" == "--url"    ]; then param="url";           continue
    elif [ "$arg" == "-u" ] || [ "$arg" == "--user"   ]; then param="user";          continue
    elif [ "$arg" == "-p" ] || [ "$arg" == "--pass"   ]; then param="pass";          continue
    elif [ "$arg" == "-c" ] || [ "$arg" == "--config" ]; then param="config";        continue
    fi

    if   [ "$param" == "url"    ]; then argUrl="$arg" && param=""; continue
    elif [ "$param" == "user"   ]; then argUser="$arg" && param=""; continue
    elif [ "$param" == "pass"   ]; then argPass="$arg" && param=""; continue    
    elif [ "$param" == "config" ]; then argConfig="$arg" && param=""; continue    
    elif [ "$param" == ""       ]; then printf "ERROR: Invalid argument or flags missing!"; exit 1
    fi
done

if [ $argHelp -eq 1 ]; then
    echo "Usage: ./xmrig-setup [OPTION]...                   | REQUIRES SUDO PRIVILEGES"
    echo "Helper script for installing and setting up xmrig"
    echo "All parameters required and if not supplied script will prompmt user for input" 
    echo
    echo "  -h, --help                Shows this text"
    echo "  -o, --url                 Pool url to mine from"    
    echo "  -u, --user                Username, usually public wallet address"
    echo "  -p, --pass      Password or a worker name"
    echo "  -c, --config    Configuration file path"
    echo
    echo "For example config files see the following links:"
    echo "  https://xmrig.com/wizard"
    echo "  https://github.com/xmrig/xmrig/blob/master/src/config.json"
    echo
    exit 0
fi

if [ "`uname -o`" == "Android" ]; then # https://github.com/cmxhost/xmrig/blob/master/README.md
    apt-get update && apt-get upgrade -y
    apt-get install git -y
    apt-get install build-essential -y
    apt-get install cmake -y
    apt-get install libuv1-dev -y
    apt-get install libssl-dev -y
    apt-get install libhwloc-dev -y
    apt-get install wget -y
    apt-get install proot -y
    apt-get install libmicrohttpd-dev -y
    apt-get install openssl -y
    apt-get install jq -y
    #https://www.reddit.com/r/termux/comments/i27szk/how_do_i_crontab_on_termux/
    apt-get install cronie -y
    apt-get install runit -y
    apt-get install termux-services -y
else # https://xmrig.com/docs/miner/build/ubuntu
    sudo apt-get update && apt-get upgrade -y
    sudo apt-get install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y
    sudo apt-get install wget proot libmicrohttpd-dev -y
    sudo apt-get install jq -y
fi

while [ ! -f "$argConfig" ]; do read -p "config: " argConfig; done
if [ "$argUrl" == "" ]; then argUrl=`jq ".pools[].url" "$argConfig" | sed -e 's/^"//' -e 's/"$//'`; fi
while [ "$argUrl" == "null" ] || [ "$argUrl" == "" ] || [ "$argUrl" == "TODO" ]; do read -p "url: " argUrl; done
`jq ".pools[].url = \"$argUrl\"" "$argConfig" > "$argConfig.tmp"` && mv -f "$argConfig.tmp" "$argConfig"
if [ "$argUser" == "" ]; then argUser=`jq ".pools[].user" "$argConfig" | sed -e 's/^"//' -e 's/"$//'`; fi
while [ "$argUser" == "null" ] || [ "$argUser" == "" ] || [ "$argUser" == "TODO" ]; do read -p "user: " argUser; done
`jq ".pools[].user = \"$argUser\"" "$argConfig" > "$argConfig.tmp"` && mv -f "$argConfig.tmp" "$argConfig"
if [ "$argPass" == "" ]; then argPass=`jq ".pools[].pass" "$argConfig" | sed -e 's/^"//' -e 's/"$//'`; fi
while [ "$argPass" == "null" ] || [ "$argPass" == "" ] || [ "$argPass" == "TODO" ]; do read -p "pass: " argPass; done
`jq ".pools[].pass = \"$argPass\"" "$argConfig" > "$argConfig.tmp"` && mv -f "$argConfig.tmp" "$argConfig"

if [ ! -d "$HOME/xmrig" ]; then mkdir -p "$HOME/xmrig"; fi

if [ "`jq ".cuda.enabled" "$argConfig"`" == "true" ] && [ "`uname -o`" != "Android" ] && [ "`lspci | grep -i nvidia`" != "" ]; then
    #https://developer.nvidia.com/cuda-downloads
    wget "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin"
    sudo mv "cuda-ubuntu2004.pin" "/etc/apt/preferences.d/cuda-repository-pin-600"
    sudo apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub"
    sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
    sudo apt-get update
    sudo apt-get -y install cuda -y
    
    #https://xmrig.com/docs/miner/build/ubuntu
    if [ -d "$HOME/xmrig/xmrig-cuda" ]; then rm -rf "$HOME/xmrig/xmrig-cuda"; fi
    cd "$HOME/xmrig" && git clone https://github.com/xmrig/xmrig-cuda.git
    mkdir -p "$HOME/xmrig/xmrig-cuda/build" && cd "$HOME/xmrig/xmrig-cuda/build"
    cmake .. -DCUDA_LIB=/usr/local/cuda/lib64/stubs/libcuda.so -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda
    make -j$(nproc)
    
    `jq ".cuda.loader = \"$HOME/xmrig/xmrig-cuda/build/libxmrig-cuda.so\"" "$argConfig" > "$argConfig.tmp"` && mv "$argConfig.tmp" "$argConfig"
else
    `jq ".cuda.enabled = false" "$argConfig" > "$argConfig.tmp"` && mv -f "$argConfig.tmp" "$argConfig"
fi

if [ "`jq ".opencl" "$argConfig"`" == "true" ] && [ "`uname -o`" != "Android" ] && [ "`lspci | grep -i amd`" != "" ]; then
    echo "OpenCl is good"
else
    `jq ".opencl = false" "$argConfig" > "$argConfig.tmp"` && mv -f "$argConfig.tmp" "$argConfig"
fi

declare cmakeTarget="" 
if   [ "`uname -m`" == "armv7l" ]; then cmaketarget="-DARM_TARGET=7";
elif [ "`uname -m`" == "armv8l" ]; then cmaketarget="-DARM_TARGET=8";
fi

declare cmakeHwloc=""
if [ "`uname -o`" == "Android" ]; then cmakeHwloc="-DWITH_HWLOC=OFF"; fi

if [ -d "$HOME/xmrig/xmrig" ]; then rm -rf "$HOME/xmrig/xmrig"; fi
cd "$HOME/xmrig" && git clone https://github.com/xmrig/xmrig.git
mkdir -p "$HOME/xmrig/xmrig/build" && cd "$HOME/xmrig/xmrig/build"
sed -i 's/constexpr const int kDefaultDonateLevel = .*;/constexpr const int kDefaultDonateLevel = 0;/' "$HOME/xmrig/xmrig/src/donate.h"
sed -i 's/constexpr const int kMinimumDonateLevel = .*;/constexpr const int kMinimumDonateLevel = 0;/' "$HOME/xmrig/xmrig/src/donate.h"
cmake .. $cmakeTarget $cmakeHwloc
#make -j$(nproc)

file="$HOME/xmrig/run.sh"
if [ ! -f $file ]; then install -Dv /dev/null "$file"; fi
truncate -s 0 $file
echo -e "#!/bin/bash" | tee -a "$file" &> /dev/null
echo -e "declare -r cwf=\${0##*/}" | tee -a "$file" &> /dev/null
echo -e "declare -r date=\$(date -u +\"%Y%m%d%H%M%S%z\")" | tee -a "$file" &> /dev/null
echo -e "declare -r log=\"\$cwf.log\"" | tee -a "$file" &> /dev/null
echo -e "declare -r pre=\"\$date - \$cwf -\"" | tee -a "$file" &> /dev/null
echo -e "if [ -z \$(pidof -x xmrig) ]; then" | tee -a "$file" &> /dev/null
echo -e "  \"\$HOME/xmrig/xmrig/build/xmrig\" --config \"$argConfig\"" | tee -a "$file" &> /dev/null
echo -e "  echo \"\$pre xmrig started\" \>\> \"\$log\"" | tee -a "$file" &> /dev/null
echo -e "else" | tee -a $file &> /dev/null
echo -e "  echo \"\$pre xmrig running\" \>\> \"\$log\"" | tee -a "$file" &> /dev/null
echo -e "fi" | tee -a "$file" &> /dev/null

crontab -l > crontab_new
grep -v "xmrig" crontab_new > crontab_new_tmp && mv crontab_new_tmp crontab_new
echo "*/5 * * * * \"$file\"" >> crontab_new
crontab crontab_new
rm crontab_new

if [ "`uname -o`" == "Android" ]; then
    echo "Termux must be restarted so manually re-execute this command when you return..."
    echo "sv enable crond"
else
    /etc/init.d/cron restart
fi
