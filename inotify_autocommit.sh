#!/bin/sh 

# Originally by Bjoern Steinbrink, simplified by Johannes Schindelin 

inotifywait -m -r --exclude ^\./\.git/.* \ 
        -e close_write -e move -e create -e delete . 2>/dev/null | 
while read FILE_PATH EVENT FILE_NAME 
do 
        FILE_NAME="$FILE_PATH$FILE_NAME" 
        FILE_NAME=${FILE_NAME#./} 

        # git doesn't care about directories 
        test -d "$FILE_NAME" && continue 

        case "$EVENT" in 
        *MOVED_TO*|*CREATE*) 
                git add "$FILE_NAME" 
                git commit -m "$FILE_NAME created" 
                ;; 
        *CLOSE_WRITE*|*MODIFY*) 
                git add "$FILE_NAME" 
                git commit -m "$FILE_NAME changed" 
                ;; 
        *DELETE*|*MOVED_FROM*) 
                git rm --cached "$FILE_NAME" 
                git commit -m "$FILE_NAME removed" 
                ;; 
        esac 
done 