#!/bin/bash

# Backs up a set of important cardano folders. Creates the backup as sibling folders of the folders being backed up. This script assumes a cardano installation done via cntools.
# I did not have snapshots available on the infrastructure level, so the intention of this script was to create a rudimentary backup before installing a new cardano node version, in case the update goes bananas.

echo "Starting script to backup following folders:"
declare -a folders=(
                "$HOME/.cabal"
                "$HOME/.ghcup"
                "$HOME/git"
                "/opt/cardano/cnode/scripts"
                "/opt/cardano/cnode/files"
                "/opt/cardano/cnode/guild-db"
                "/opt/cardano/cnode/sockets"
                "/opt/cardano/cnode/priv"
)
echo

for val in "${folders[@]}"; do
    echo $val
done
echo

# see https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
read -p "Do you want to continue? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

cardanoCliOutput=$(cardano-cli --version)
echo "Cardano CLI output:"
echo $cardanoCliOutput
echo

cardanoCliVersion=$(cardano-cli --version | grep cardano | awk '{print $2}')
read -p "Current node version is: ${cardanoCliVersion}. Is this correct? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# backticks are necessary, seems this is a special construct
currentDate=`date +"%Y%m%d_%H%M%S"`
echo "Backup file name format: x_${cardanoCliVersion}_${currentDate}"
echo

for val in "${folders[@]}"; do
    echo "Backing up folder '${val}' ..."
    newFolderName="${val}_${cardanoCliVersion}_${currentDate}"
    echo "New folder name will be: ${newFolderName}"
    echo "Copying folder..."
    cp -r $val $newFolderName
    echo "Copying done. Parent folder content:"
    ls -a "${val}/.."
    echo "Backup done."
    echo
done
