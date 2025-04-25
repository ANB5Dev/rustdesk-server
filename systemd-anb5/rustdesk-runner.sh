#!/bin/bash
INSTANCE_NAME=$1
CONFIG_FILE="/etc/rustdesk.json"

if [ -z "$INSTANCE_NAME" ]; then
    echo "Instance name is required"
    exit 1
fi

# Extract JSON values for the instance
INSTANCE_JSON=$(jq -r --arg name "$INSTANCE_NAME" '.servers[] | select(.name == $name)' "$CONFIG_FILE")

if [ -z "$INSTANCE_JSON" ]; then
    echo "No configuration found for instance: $INSTANCE_NAME"
    exit 1
fi

SELF=$(jq -r '.self' "$CONFIG_FILE")
KEY=$(echo "$INSTANCE_JSON" | jq -r '.private_key')
PORT=$(echo "$INSTANCE_JSON" | jq -r '.port')
SINGLE_BANDWIDTH=$(echo "$INSTANCE_JSON" | jq -r '.single_bandwidth')
TOTAL_BANDWIDTH=$(echo "$INSTANCE_JSON" | jq -r '.total_bandwidth')
LIMIT_SPEED=$(echo "$INSTANCE_JSON" | jq -r '.limit_speed')
RUST_LOG=$(echo "$INSTANCE_JSON" | jq -r '.rust_log')
LOGURL=$(echo "$INSTANCE_JSON" | jq -r '.logurl')
LOGVERBOSE=$(echo "$INSTANCE_JSON" | jq -r '.logverbose')
ALWAYS_USE_RELAY=$(echo "$INSTANCE_JSON" | jq -r '.always_use_relay')

DB_URL="rustdesk.${INSTANCE_NAME}.sqlite3"
HBBS_PORT="$PORT"
HBBR_PORT=$((PORT + 1))

export RUST_LOG
export KEY
export PORT="$HBBS_PORT"
export ALWAYS_USE_RELAY
export DB_URL
export SERVERNAME="$INSTANCE_NAME"
export LOGURL
export LOGVERBOSE
export SINGLE_BANDWIDTH
export TOTAL_BANDWIDTH
export LIMIT_SPEED

# Start hbbs and hbbr
hbbr &
hbbs --rendezvous-servers "$SELF:$HBBS_PORT" --relay-servers "$SELF:$HBBR_PORT"
