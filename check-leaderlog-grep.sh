#!/bin/bash

# Checks the syslog for a leader log entry and sends them as telegram messages. Requires sendTelegram.sh to be configured. It will not send a message if there is not entry.
# Replace <PATH_TO_SENDTELEGRAM.SH>
# Usage: I put this script into /etc/cron.hourly to get notified about the slot leader schedule for the next epoch.

echo 'Checking leader log...'
grep -i "cnode-cncli-leaderlog.*epoch" /var/log/syslog | sed 's/\(.*\)/"\1"/' | xargs -I {} <PATH_TO_SENDTELEGRAM.SH> {}
echo 'Done checking leader log'