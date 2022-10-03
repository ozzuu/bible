#!/bin/bash
server=$1
serverDir=$2

allDbDir=db
serverBackupDir=$allDbDir/backups
allDb=all.db
bakName="$(date '+%Y-%m-%d').db"

echo "SSH server (user@server): $server"
echo "SSH server working dir: $serverDir"
echo "Server's backup dir: $serverBackupDir"
echo "Server's all db: $allDbDir/$allDb"
echo "Backup file name: $bakName"

echo -ne "\nCorrect (press enter)? "; read correct
if [ "$correct" != "" ]; then
  echo "Exiting"
  exit 1
fi

echo -e "\nBackup started for $allDb"

cmds="
echo -e \"\tGoing to dir\" &&
cd $serverDir &&
echo -e \"\tSetup directories and files\" &&
mkdir --parents \"$serverBackupDir\" &&
echo -e \"\tCopying the DB\" &&
cp \"$allDbDir/$allDb\" \"$serverBackupDir/$bakName\" &&
echo -e \"\tCopied! Listing all backups\" &&
ls \"$serverBackupDir\"
echo -e \"\tFinished\"
"

echo -e "\nPreparing to execute commands in $server; Started at '$(date)'"
ssh $server "$cmds" &&
  echo -e "Finished at '$(date)'" ||
  echo -e "Error at '$(date)'"
