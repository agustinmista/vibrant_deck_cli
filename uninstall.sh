#!/bin/bash

set -e

BIN=vibrant_deck_cli
BIN_DIR=$HOME/.local/bin

SERVICE=$BIN.service
SYSTEMD_USER_DIR=$HOME/.config/systemd/user

CONFIG_DIR=$HOME/.config/$BIN

# ----------------------------------------

echo "Stopping $SERVICE ..."
systemctl --user stop $SERVICE

echo "Disabling $SERVICE ..."
systemctl --user disable $SERVICE

echo "Removing $SYSTEMD_USER_DIR/$SERVICE ..."
rm $SYSTEMD_USER_DIR/$SERVICE

echo "Removing $BIN_DIR/$BIN ..."
rm $BIN_DIR/$BIN

echo "Removing $CONFIG_DIR"
rm $CONFIG_DIR/config
rmdir $CONFIG_DIR
