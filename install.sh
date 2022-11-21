#!/bin/bash

set -e

GITHUB_REPO=agustinmista/vibrant_deck_cli
API_URL=https://api.github.com/repos/$GITHUB_REPO/contents

BIN=vibrant_deck_cli
BIN_DIR=$HOME/.local/bin

SERVICE=$BIN.service
SYSTEMD_USER_DIR=$HOME/.config/systemd/user

CONFIG_DIR=$HOME/.config/$BIN
DEFAULT_SATURATION=1.5

# ----------------------------------------

echo "Looking up the files we need to download ..."
REPO_CONTENTS=$(curl -s $API_URL)

BIN_URL=$(echo $REPO_CONTENTS | jq -r --arg file $BIN '.[] | select(.name==$file).download_url')
SERVICE_URL=$(echo $REPO_CONTENTS | jq -r --arg file $SERVICE '.[] | select(.name==$file).download_url')

echo "Downloading $BIN_URL into $BIN_DIR/$BIN ..."
mkdir -p $BIN_DIR
curl -sL $BIN_URL --output $BIN_DIR/$BIN
chmod +x $BIN_DIR/$BIN

echo "Creating config file at $CONFIG_DIR/config ..."
mkdir -p $CONFIG_DIR
echo "SATURATION=$DEFAULT_SATURATION" > $CONFIG_DIR/config

echo "Downloading $SERVICE_URL into $SYSTEMD_USER_DIR ..."
curl -sL $SERVICE_URL --output $SYSTEMD_USER_DIR/$SERVICE

echo "Enabling $SERVICE on systemd ..."
systemctl --user enable $SERVICE

echo "Starting $SERVICE ..."
systemctl --user restart $SERVICE

echo "Checking if everything worked ..."

SERVICE_INVOCATION=$(systemctl --user show --value -p InvocationID $SERVICE)
CURRENT_SATURATION=$(journalctl _SYSTEMD_INVOCATION_ID=$SERVICE_INVOCATION -o cat | grep "set to" | awk '{print $5}')

if [ ! -z "$CURRENT_SATURATION" ]; then
  if (( $(awk 'BEGIN{ print "'$CURRENT_SATURATION'"=="'$DEFAULT_SATURATION'" }') == 0 )); then
    echo "Done! The screen saturation is now set to $CURRENT_SATURATION :D"
    echo "The default saturation value can be changed in $CONFIG_DIR/config"
  else
    echo "Error: $BIN_DIR/$BIN $DEFAULT_SATURATION did not succeed. Current screen saturation is $SATURATION."
    exit
  fi
else
  echo "Error: $BIN_DIR/$BIN --status returned nothing"
  exit
fi
