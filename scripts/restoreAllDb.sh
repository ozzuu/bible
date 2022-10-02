#!/bin/bash
server=$1
serverDir=$2

allDbDir=db
serverBackupDir=$allDbDir/backups
allDb=all.db

echo "SSH server (user@server): $server"
echo "SSH server working dir: $serverDir"
echo "Server's backup dir: $serverBackupDir"
echo "Server's all db: $allDbDir/$allDb"

echo -ne "\nCorrect (press enter)? "; read correct
if [ "$correct" != "" ]; then
  echo "Exiting"
  exit 1
fi

echo -e "\nRestore for $allDb was started"

cmds="
echo -e \"\tGoing to dir\" &&
cd $serverDir &&
echo -e \"\tSetup directories and files\" &&
mkdir --parents \"$serverBackupDir\" &&
echo -e \"\tListing the available DBs:\" &&
ls \"$serverBackupDir\"
echo -ne \"\\tBackup name: \"; read selected
cp \"$serverBackupDir/\$selected\" \"$allDbDir/$allDb\" &&
echo -e \"\tFinished\"
"

echo -e "\nPreparing to execute commands in $server; Started at '$(date)'"
ssh $server "$cmds" &&
  echo -e "Finished at '$(date)'" ||
  echo -e "Error at '$(date)'"
