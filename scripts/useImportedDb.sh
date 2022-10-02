#!/bin/bash
server=$1
serverDir=$2

allDbDir=db
allDb=all.db
serverImportDir=$allDbDir/import

echo "SSH server (user@server): $server"
echo "SSH server working dir: $serverDir"
echo "Server's import dir: $serverImportDir"
echo "Server's all db: $allDbDir/$allDb"

echo -ne "\nCorrect (press enter)? "; read correct
if [ "$correct" != "" ]; then
  echo "Exiting"
  exit 1
fi

echo -e "\nUsing imported DB"

cmds="
echo -e \"\tGoing to dir\" &&
cd $serverDir &&
echo -e \"\tCopying DB\" &&
cp \"$serverImportDir/$allDbDir/$allDb\" \"$allDbDir/$allDb\" &&
echo -e \"\tFinished\"
"

echo -e "\nPreparing to execute commands in $server; Started at '$(date)'"
ssh $server "$cmds" &&
  echo -e "Finished at '$(date)'" ||
  echo -e "Error at '$(date)'"
