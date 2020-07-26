#!/usr/bin/env bash

LOG=/var/log/zoneminder/movevideo.log
EXT=mp4
VIDEO_DIR_NAME=video

# $1 is the directory of an event (e.g. $ZONEMINDER_DATA_DIR/events/$MONITOR_ID/$DATE/$EVENT_NUMBER)
EVENT_DIR=$1
echo "DEBUG: EVENT_DIR=$EVENT_DIR" >> $LOG
EVENT_NUMBER=$(basename $EVENT_DIR)
echo "DEBUG: EVENT_NUMBER=$EVENT_NUMBER" >> $LOG

if [ "$EVENT_DIR" != "" ]
then
    # file with the generated video is expected to be at $EVENT_DIR/$(EVENT_NUMBER)-video.mp4
    VIDEO=$EVENT_DIR/$EVENT_NUMBER-video.$EXT
    if [ -f "$VIDEO" ]
    then
        # the video will be moved into $ZONEMINDER_DATA_DIR/video/$DATE/$MONITOR_ID
        DATE=$(basename $(dirname $EVENT_DIR))
        MONITOR_ID=$(basename $(dirname $(dirname $EVENT_DIR)))
        ZONEMINDER_DATA_DIR=$(dirname $(dirname $(dirname $(dirname $EVENT_DIR))))
        DEST_DIR=$ZONEMINDER_DATA_DIR/$VIDEO_DIR_NAME/$DATE/$MONITOR_ID
        echo  "INFO: `date '+%F %T'` Moving from $VIDEO to $DEST_DIR" >> $LOG
        mkdir -p $DEST_DIR

        # zero-pad the event number which will be used in the video file name to make sorting easier
        printf -v ZERO_PADDED_EVENT_NUMBER "%07g" $EVENT_NUMBER
        # use the date of the last status update of the original video file as an acceptable
        # approximation of the video creation timestamp
        CREATION_DATE=$(date -d "$(stat -c '%z' $VIDEO)" +"%Y-%m-%d-%H:%M:%S.%N")
        DEST_FILE_NAME_WITHOUT_EXTENSION="$CREATION_DATE"_"$ZERO_PADDED_EVENT_NUMBER"
        DEST_FILE=$DEST_DIR/$DEST_FILE_NAME_WITHOUT_EXTENSION.mp4
        echo "DEBUG: DEST_FILE=$DEST_FILE" >> $LOG
        ffmpeg -i $VIDEO -metadata title=$DEST_FILE_NAME_WITHOUT_EXTENSION -codec copy $DEST_FILE
    else
        # if it is a one-off error, probably the filter was running when the video had not been generated yet
        # else, zoneminder devs may have changed the location for the generated videos
        echo  "`date '+%F %T'` ERROR: No video found: $VIDEO" >> $LOG
        exit 1
    fi
else
    echo  "`date '+%F %T'` ERROR: No input provided" >> $LOG
    exit 1
fi
