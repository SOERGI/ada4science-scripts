#!/bin/bash

# Run this script 1.5 days before the end of the epoch to get the leaderlog details for the current or next epoch. 
# Based on an example from https://github.com/AndrewWestberg/cncli/tree/develop/scripts
# Replace the placeholders in <...>

PORT=<YOUR_PORT>              # can be found in your cnode env file
POOL_ID=<YOUR_POOL_ID>        # can be found e.g. on pooltool.io
POOL_NAME="<YOUR_POOL_NAME>"  # your pool name in cnode
LOC_VRF_SKEY="${CNODE_HOME}/priv/pool/${POOL_NAME}/vrf.skey"
BYRON_GENESIS="${CNODE_HOME}/files/byron-genesis.json"
SHELLEY_GENESIS="${CNODE_HOME}/files/shelley-genesis.json"

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` [current|next]"
  exit 0
fi

if [ -z "$1" ]; then
    echo "Usage: `basename $0` [current|next]"
    exit 0
fi

LEDGER_SET="current"
POOL_STAKE_ATTR="poolStakeSet"
ACTIVE_STAKE_ATTR="activeStakeSet"

if [ "$1" == "next" ]; then
  LEDGER_SET="next"
  POOL_STAKE_ATTR="poolStakeMark"
  ACTIVE_STAKE_ATTR="activeStakeMark"
fi

export CARDANO_NODE_SOCKET_PATH=${CNODE_HOME}/sockets/node0.socket

echo "Starting sync..."
"$HOME"/.cargo/bin/cncli sync --host 127.0.0.1 --port $PORT --no-service
echo "Getting snapshot..."
SNAPSHOT=$("$HOME"/.cabal/bin/cardano-cli query stake-snapshot --stake-pool-id $POOL_ID --mainnet)
POOL_STAKE=$(echo "$SNAPSHOT" | grep -oP "(?<=    \"${POOL_STAKE_ATTR}\": )\d+(?=,?)")
ACTIVE_STAKE=$(echo "$SNAPSHOT" | grep -oP "(?<=    \"$ACTIVE_STAKE_ATTR\": )\d+(?=,?)")
echo "active stake:" $ACTIVE_STAKE
echo "Getting leaderlog for $1 epoch..."
LEADER_LOG=`"$HOME"/.cargo/bin/cncli leaderlog --pool-id $POOL_ID --pool-vrf-skey $LOC_VRF_SKEY --byron-genesis $BYRON_GENESIS --shelley-genesis $SHELLEY_GENESIS --pool-stake $POOL_STAKE --active-stake $ACTIVE_STAKE --ledger-set $LEDGER_SET`
EPOCH=`jq .epoch <<< $LEADER_LOG`
echo "Epoch $EPOCH 🧙🔮:"

SLOTS=`jq .epochSlots <<< $LEADER_LOG`
IDEAL=`jq .epochSlotsIdeal <<< $LEADER_LOG`
PERFORMANCE=`jq .maxPerformance <<< $LEADER_LOG`
echo "Slots: $SLOTS 🎰, $PERFORMANCE% 🍀max, $IDEAL: 🧱ideal"
