#!/usr/bin/env bash

################################################################################
# Removes Zoneminder event videos older than 1 month.
# Supposed to be run daily via a cron job or systemd timer.
################################################################################

VIDEO_DIR=$1

find $VIDEO_DIR -mtime +30 -type f -exec rm {} +
find $VIDEO_DIR -mindepth 1 -type d -atime +30 | xargs rmdir -p --ignore-fail-on-non-empty
