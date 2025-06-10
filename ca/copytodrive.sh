#!/bin/bash
# Script to copy the contents of the ca folder to a specified flash drive path
# Usage: ./copytodrive.sh [destination_path]

SRC_DIR="$(pwd)"
DEST_DIR="${1:-/media/sparks/BAA1-3D07/}"

if [ ! -d "$DEST_DIR" ]; then
  echo "Destination path $DEST_DIR does not exist."
  exit 1
fi

rsync -av --progress "$SRC_DIR/" "$DEST_DIR/ca/"

echo "CA folder copied to $DEST_DIR/ca/"