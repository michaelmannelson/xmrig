#!/bin/bash

declare -r cwf=${0##*/}
declare -r date=$(date -u +"%Y%m%d%H%M%S%z")
declare -r log="log.dat"
declare -r pre="$date - $cwf - xmrig -"

declare -r level=$1

if   [ "$level" != "" ]; then 
  cp -f "$HOME/xmrig/config.$level.json" "$HOME/xmrig/config.json"
fi

if [ -z $(pidof -x xmrig) ]; then
  crontab -l > crontab_new
  grep -v "xmrig" crontab_new > crontab_new_tmp && mv crontab_new_tmp crontab_new
  echo "*/5 * * * * \"$HOME/xmrig/start.sh\"" >> crontab_new
  crontab crontab_new
  rm crontab_new
  echo "$pre cron added" >> "$log"
  
  if [ "`uname -o`" == "Android" ]; then sv enable crond; else /etc/init.d/cron restart; fi
  echo "$pre cron restarted" >> "$log"

  "$HOME/xmrig/xmrig/build/xmrig" --config "$HOME/xmrig/config.json"
  echo "$pre started" >> "$log"
fi


