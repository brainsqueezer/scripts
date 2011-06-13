#!/bin/bash

if [ $# -ne 2 ]; then
  echo "ussage: download.sh <links_file> <download_folder>"
  exit;
fi

INPUT_FILE=$1
DOWNLOAD_FOLDER=$2
COUNT=0
MIRROR=dt.rapidshare.com;

for i in `cat $INPUT_FILE`; do

  echo === FILE $COUNT ===
  DONE=0

  while [ $DONE -ne 1 ];  do
    GET_URL=`wget -q -O - $i \
      | grep "<form id=\"ff\" action=\""  \
      | grep -o 'http://[^"]*'`
    OUTPUT=`wget -q -O - --post-data "dl.start=Free" $GET_URL`
    WAIT_TIME=`echo "$OUTPUT" \
      | grep "try again in about" \
      | grep -o "[0-9]\{1,3\}"`
    if [ -z $WAIT_TIME ]; then
      echo DOWNLOAD AVALIABLE $i
      DONE=1
    else
      echo WAIT: --${WAIT_TIME}-- min
      sleep 1m
    fi
  done

  FILE_URL=`echo "$OUTPUT" \
    | grep "document.dlf.action=" \
    | grep -o "http://[^\"]*${MIRROR}[^\\]*"`
  OUTPUT_FILE=${DOWNLOAD_FOLDER}/part-${COUNT}.rar

  #if [ -z ${FILE_URL} ]; then
  #echo uppps.... some error ocurred;
  #fi

  echo FILE_URL $FILE_URL
  echo WAITING a bit
  sleep 90

  echo DOWNLOADING $FILE_URL
  wget -O $OUTPUT_FILE $FILE_URL

  COUNT=$(( $COUNT + 1 ))
done
