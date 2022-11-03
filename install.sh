#!/bin/bash

set -e

GITHUB_REPO=agustinmista/vibrant_deck_cli
API_URL=https://api.github.com/repos/$GITHUB_REPO/contents

BIN=vibrant_deck_cli
BIN_DIR=$HOME/.local/bin

SERVICE=$BIN.service
SYSTEMD_USER_DIR=$HOME/.config/systemd/user

CONFIG_DIR=$HOME/.config/$BIN
DEFAULT_SATURATION=4

# ----------------------------------------

echo "Looking up the files we need to download ..."
REPO_CONTENTS=$(curl -s $API_URL)

BIN_URL=$(echo $REPO_CONTENTS | jq -r --arg file $BIN '.[] | select(.name==$file).download_url')
SERVICE_URL=$(echo $REPO_CONTENTS | jq -r --arg file $SERVICE '.[] | select(.name==$file).download_url')

echo "Downloading $BIN_URL into $BIN_DIR/$BIN ..."
mkdir -p $BIN_DIR
curl -sL $BIN_URL --output $BIN_DIR/$BIN
chmod +x $BIN_DIR/$BIN

echo "Creating config file at to $CONFIG_DIR/config ..."
mkdir -p $CONFIG_DIR
echo "SATURATION=$DEFAULT_SATURATION" > $CONFIG_DIR/config

echo "Downloading $SERVICE_URL into $SYSTEMD_USER_DIR ..."
curl -sL $SERVICE_URL --output $SYSTEMD_USER_DIR/$SERVICE

echo "Enabling $SERVICE on systemd ..."
systemctl --user enable $SERVICE

echo "Done! Try restarting your Steam Deck now :D"
echo "The default screen saturation can be changed in $CONFIG_DIR/config"