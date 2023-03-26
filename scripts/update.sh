#!/bin/bash
server=$1

echo "SSH server (user@server): $server"

echo -ne "\nCorrect (press enter)? "
read correct
if [ "$correct" != "" ]; then
  echo "Exiting"
  exit 1
fi

echo -e "\nUpdate started"

cmds="
echo \"Installing latest version\" &&
nimble install -y https://git.ozzuu.com/ozzuu/bible &&
echo \"Killing bible process with sudo...\" &&
sudo -S killall bible &&
echo \"Opening it again\" &&
cd /home/admin/web/bible.ozzuu.com/server &&
nohup bible serve > /dev/null 2>&1 &
exit
"

echo -e "\nPreparing to execute thr commands in $server; Started at '$(date)'"
cat $localBuildFile | ssh $server "$cmds" &&
  echo -e "Finished at '$(date)'" ||
  echo -e "Error at '$(date)'"
