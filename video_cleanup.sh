#!/usr/bin/env bash

################################################################################
# Removes Zoneminder event videos older than 1 month.
################################################################################

VIDEO_DIR=$1

find $VIDEO_DIR -mtime +30 -type f -exec rm {} +
find $VIDEO_DIR -mindepth 1 -mtime +30 -type d -empty -delete
