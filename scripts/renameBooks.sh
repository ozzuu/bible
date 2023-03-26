#!/bin/bash
document=$1
server=$2
serverDir=$3
alwaysYes=$4

allDbDir=db
allDb=all.db

echo "Document: $document"
echo "SSH server (user@server): $server"
echo "SSH server working dir: $serverDir"
echo "Server's all db: $allDbDir/$allDb"
echo "Always yes: $alwaysYes"

if [ "$alwaysYes" != "-y" ]; then
  echo -ne "\nCorrect (press enter)? "; read correct
  if [ "$correct" != "" ]; then
    echo "Exiting"
    exit 1
  fi
fi

echo -e "\nRename started for $document in $allDb"

cmds="
echo -e \"\tGoing to dir\" &&
cd $serverDir &&
echo -e \"\tRenaming...\" &&
bible renameBookNames -d $document &&
echo -e \"\tFinished\"
"

echo -e "\nPreparing to execute commands in $server; Started at '$(date)'"
ssh $server "$cmds" &&
  echo -e "Finished at '$(date)'" ||
  echo -e "Error at '$(date)'"
