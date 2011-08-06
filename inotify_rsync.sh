#!/bin/sh

set -e
set -u

BASEDIR="$1"
REMOTE_HOST="$2"
RSYNC="rsync -av -e ssh --delete "

# Initial sync
$RSYNC ${BASEDIR}/* ${REMOTE_HOST}:${BASEDIR}/

# Wait for individual file events and keep in sync
inotifywait --format '%e %w' -e close_write -e move -e create -e delete -qmr $BASEDIR | while read EVENT DIR
do
  # Fork off rsync proc to do sync
  $RSYNC ${DIR}/* ${REMOTE_HOST}:${DIR}/ &
done