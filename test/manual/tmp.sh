#!/bin/bash

array=( zero one two three four five )
count=${#array[@]}

index=0

while [ "$index" -lt "$count" ] ; do
  echo ${array[$index]}
  if [ "$index" -eq "3" ] ; then
    echo "fizz" 1>&2
  fi
  if [ "$index" -eq "4" ] ; then
    echo -n "bo" 1>&2
  fi
  sleep 0.5
  ((index ++))
done

echo "done with shell script."
exit 0
