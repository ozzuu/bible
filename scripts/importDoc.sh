#!/bin/bash
docFile=$1
doc=$2
docName=$3
server=$4
serverDir=$5
setup=$6

serverDocName=$doc.db
allDbDir=db
allDb=all.db
serverImportDir=$allDbDir/import

echo "Document file: $docFile"
echo "Document abbreviation: $doc"
echo "Document full name: $docName"
echo "SSH server (user@server): $server"
echo "SSH server working dir: $serverDir"
echo "Setup enabled: $setup"

echo -ne "\nCorrect (press enter)? "; read correct
if [ "$correct" != "" ]; then
  echo "Exiting"
  exit 1
fi

setupCmd=""

if [ "$setup" != "yes" ]; then
  if [ "$setup" != "no" ]; then
    echo "Setup needs to be [yes|no]"
    exit 1
  fi
else
  setupCmd="
echo -e \"\tSetup directories and files\" &&
mkdir --parents \"$serverImportDir/$allDbDir\" &&
cp .env \"$serverImportDir\" &&
cp \"$allDbDir/$allDb\" \"$serverImportDir/$allDbDir\"
"
fi

echo -e "\nImporting \"$docName\" from $docFile"


cmds="
echo -e \"\tGoing to dir\" &&
cd $serverDir &&
$setupCmd
cd \"$serverImportDir\" &&
echo -e \"\tCopying DB\" &&
cat > \"$serverDocName\" &&
echo -e \"\tStarting import\" &&
bible add -d \"$serverDocName\" -n \"$doc\" -f \"$docName\" -s \"$allDbDir/status.json\" &&
bible update_chapters_quantity -d \"$doc\" &&
echo -e \"\tDeleting DB\" &&
rm \"$serverDocName\"
"

echo -e "\nPreparing to execute commands in $server; Started at '$(date)'"
cat $docFile | ssh $server "$cmds" &&
  echo -e "Finished at '$(date)'" ||
  echo -e "Error at '$(date)'"
