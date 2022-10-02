#!/bin/bash
server=$1
serverDir=$2

echo "SSH server (user@server): $server"
echo "SSH server working dir: $serverDir"

echo -ne "\nCorrect (press enter)? "; read correct
if [ "$correct" != "" ]; then
  echo "Exiting"
  exit 1
fi

echo -e "\nRestarting bible server"

cmds="
echo -e \"\tKilling all process of Ozzuu Bible (Provide remote user pass for sudo)\" &&
sudo -S killall bible &&
echo -e \"\tStarting again\" &&
sh -c 'cd \"$serverDir\"; nohup bible serve > /dev/null 2>&1 &' &&
echo -e \"\tSuccess\"
"

echo -e "\nPreparing to execute commands in $server; Started at '$(date)'"
ssh $server "$cmds" &&
  echo -e "Finished at '$(date)'" ||
  echo -e "Error at '$(date)'"
