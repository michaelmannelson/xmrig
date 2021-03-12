# xmrig

Dedicated
```
rm -rf "$HOME/xmrig" && mkdir -p "$HOME/xmrig" && cd "$HOME/xmrig"
wget "https://github.com/michaelmannelson/xmrig/raw/main/install.sh"
wget "https://github.com/michaelmannelson/xmrig/raw/main/config.5.json" -O "config.json"
chmod +x "install.sh"
./install.sh -p "`uname -o`.`uname -s`.`uname -n`.`uname -m`.$(date +%Y%m%d@%H%M%S%z)" -c "$HOME/xmrig/config.json"
```

Normal
```
rm -rf "$HOME/xmrig" && mkdir -p "$HOME/xmrig" && cd "$HOME/xmrig"
wget "https://github.com/michaelmannelson/xmrig/raw/main/install.sh"
wget "https://github.com/michaelmannelson/xmrig/raw/main/config.2.json" -O "config.json"
chmod +x "install.sh"
./install.sh -p "`uname -o`.`uname -s`.`uname -n`.`uname -m`.$(date +%Y%m%d@%H%M%S%z)" -c "$HOME/xmrig/config.json"
```

Idle
```
rm -rf "$HOME/xmrig" && mkdir -p "$HOME/xmrig" && cd "$HOME/xmrig"
wget "https://github.com/michaelmannelson/xmrig/raw/main/install.sh"
wget "https://github.com/michaelmannelson/xmrig/raw/main/config.0.json" -O "config.json"
chmod +x "install.sh"
./install.sh -p "`uname -o`.`uname -s`.`uname -n`.`uname -m`.$(date +%Y%m%d@%H%M%S%z)" -c "$HOME/xmrig/config.json"
```


