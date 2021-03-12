# xmrig

Step 1 - Clean up any previous install and create new folder
```

rm -rf "$HOME/xmrig" && mkdir -p "$HOME/xmrig" && cd "$HOME/xmrig"

```

Step 2 - Get install script
```

rm -f "install.sh"
wget "https://github.com/michaelmannelson/xmrig/raw/main/install.sh"
chmod +x "install.sh"

```

Step 3 - Pick desired processing intensity level from least to greatest. 0 = Idle, 2 = Normal, 5 = Dedicated
```

rm -f "config.json"

wget "https://github.com/michaelmannelson/xmrig/raw/main/config.0.json" -O "config.json"

wget "https://github.com/michaelmannelson/xmrig/raw/main/config.2.json" -O "config.json"

wget "https://github.com/michaelmannelson/xmrig/raw/main/config.5.json" -O "config.json"

```

Step 4 - Run the install script
```

./install.sh -p "`uname -o`.`uname -s`.`uname -n`.`uname -m`.$(date +%Y%m%d@%H%M%S%z)" -c "$HOME/xmrig/config.json"

```

Step 5 - When prompted for url, paste in your favorite pool address.

Step 6 - When prompted for user, put in whatever the pool requires for that, probably your public wallet address

Step 7 - Run the generated run script
```

./run.sh

```

Step 8 - Profit

Step 9 - Donate - 43cKyCmpH6zi8x2vJDakvaaZZU9j929o5Y2VvhbTX9cGHQNtGAEzrRw9A6vJDM4KSi7QSThqQNcKog73hckRVGBsEjmkdjf
