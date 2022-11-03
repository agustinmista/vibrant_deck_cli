#!/bin/bash

set -e

GITHUB_REPO=agustinmista/vibrant_deck_cli

DEFAULT_SATURATION=4

BIN=vibrant_deck_cli
SERVICE=$BIN.service

BIN_DIR=$HOME/.local/bin
CONFIG_DIR=$HOME/.config/$BIN

SYSTEMD_USER_DIR=$HOME/.config/systemd/user

# ----------------------------------------

BIN_URL=$(curl -s 'https://api.github.com/repos/$GITHUB_REPO/contents' | jq -r '.[] | select(.name=="$BIN").download_url')
SERVICE_URL=$(curl -s 'https://api.github.com/repos/$GITHUB_REPO/contents' | jq -r '.[] | select(.name=="$SERVICE").download_url')

echo "Downloading $BIN to $BIN_DIR/$BIN"
mkdir -p $BIN_DIR
curl -L $BIN_URL --output $BIN_DIR/$BIN
chmod +x $BIN_DIR/$BIN

echo "Creating config file at to $CONFIG_DIR/config"
mkdir -p $CONFIG_DIR
echo "SATURATION=$DEFAULT_SATURATION" > $CONFIG_DIR/config

echo "Copying $SERVICE to $SYSTEMD_USER_DIR"
curl -L $SERVICE_URL --output $SYSTEMD_USER_DIR/$SERVICE

echo "Enabling $SERVICE on systemd"
systemctl --user enable $SERVICE

echo "Done! Try restarting your Steam Deck now :D"