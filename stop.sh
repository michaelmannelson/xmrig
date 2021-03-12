#!/bin/bash

declare -r cwf=${0##*/}
declare -r date=$(date -u +"%Y%m%d%H%M%S%z")
declare -r log="log.dat"
declare -r pre="$date - $cwf - xmrig -"

if [ $(pidof -x xmrig) ]; then
  crontab -l > crontab_new
  grep -v "xmrig" crontab_new > crontab_new_tmp && mv crontab_new_tmp crontab_new
  #echo "*/5 * * * * \"$file\"" >> crontab_new
  crontab crontab_new
  rm crontab_new
  echo "$pre cron removed" >> "$log"
  
  if [ "`uname -o`" == "Android" ]; then sv enable crond; else /etc/init.d/cron restart; fi
  echo "$pre cron restarted" >> "$log"
  
  $(killall -9 xmrig)
  echo "$pre stopped" >> "$log"
fi

