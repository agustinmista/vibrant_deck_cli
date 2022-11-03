#!/bin/bash

BIN=vibrant_deck_cli
SERVICE=vibrant_deck_cli.service

BIN_DEST_DIR=$HOME/.local/bin
SYSTEMD_USER_DIR=$HOME/.config/systemd/user

echo "Copying $BIN to $BIN_DEST_DIR"
mkdir -p $BIN_DEST_DIR
cp $BIN $BIN_DEST_DIR
chmod +x $BIN_DEST_DIR/$BIN

echo "Copying $SERVICE to $SYSTEMD_USER_DIR"
cp $SERVICE $SYSTEMD_USER_DIR

echo "Copying $TIMER to $SYSTEMD_USER_DIR"
cp $TIMER $SYSTEMD_USER_DIR

echo "Enabling $SERVICE on systemd"
systemctl --user enable $SERVICE

