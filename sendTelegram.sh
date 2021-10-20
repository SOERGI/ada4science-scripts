#!/bin/bash

# taken from https://bogomolov.tech/Telegram-notification-on-SSH-login/ and adapted
# this script expects TELEGRAM_CHAT_ID and TELEGRAM_BOT_ID to be environment variables
    
CHAT_ID=$TELEGRAM_CHAT_ID
BOT_TOKEN=$TELEGRAM_BOT_ID

# this 3 checks (if) are not necessary but should be convenient
if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` \"text message\""
  exit 0
fi

if [ -z "$1" ]
  then
    echo "Add message text as second arguments"
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo "You can pass only one argument. For a string with spaces put it in quotes"
    exit 0
fi

curl -s --data "text=$1" --data "chat_id=$CHAT_ID" 'https://api.telegram.org/bot'$BOT_TOKEN'/sendMessage' > /dev/null
