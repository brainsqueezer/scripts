#!/bin/sh

# first, we fix the directories

for name in $(find . -type d -print | sed 's/ /____/g')
do
  if [ $name != "." ] ; then
    oldname="$(echo $name | sed 's/____/ /g')"
    newname="$(echo $name | sed 's/____/_/g')"
    if [ "$oldname" != "$newname" ] ; then
      echo "renaming \"$oldname\" to $newname"
      mv "$oldname" "$newname"
    fi
  fi
done

echo ""
echo "done with directories, fixing individual files..."

# now let's fix the files therein using almost identical code

for name in $(find . -type f -print | sed 's/ /____/g')
do
  oldname="$(echo $name | sed 's/____/ /g')"
  newname="$(echo $name | sed 's/____/_/g')"
  if [ "$oldname" != "$newname" ] ; then
    echo "renaming \"$oldname\" to $newname"
    mv "$oldname" "$newname"
  fi
done

exit 0