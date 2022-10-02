#!/bin/bash
docFile=$1
doc=$2
docName=$3
server=$4
serverDir=$5

serverDocName=$doc.db
allDbDir=db
allDb=all.db
serverImportDir=$allDbDir/import

echo "Document file: $docFile"
echo "Document abbreviation: $doc"
echo "Document full name: $docName"
echo "SSH server (user@server): $server"
echo "SSH server working dir: $serverDir"

echo -ne "\nCorrect (press enter)? "; read correct
if [ "$correct" != "" ]; then
  echo "Exiting"
  exit 1
fi

echo -e "\nImporting \"$docName\" from $docFile"

cmds="
echo -e \"\tGoing to dir\" &&
cd $serverDir &&
echo -e \"\tSetup directories and files\" &&
mkdir --parents \"$serverImportDir/$allDbDir\" &&
cp .env \"$serverImportDir\" &&
cp \"$allDbDir/$allDb\" \"$serverImportDir/$allDbDir\" &&
cd \"$serverImportDir\" &&
echo -e \"\tCopying DB\" &&
cat > \"$serverDocName\" &&
echo -e \"\tStarting import\" &&
nohup bible add -d \"$serverDocName\" -n \"$doc\" -f \"$docName\" -s \"$allDbDir/status.json\" &&
nohup bible update_chapters_quantity -d \"$doc\" &&
echo -e \"\tDeleting DB\" &&
rm \"$serverDocName\"
"

echo -e "\nPreparing to execute commands in $server; Started at '$(date)'"
cat $docFile | ssh $server "$cmds" &&
  echo -e "Finished at '$(date)'" ||
  echo -e "Error at '$(date)'"
