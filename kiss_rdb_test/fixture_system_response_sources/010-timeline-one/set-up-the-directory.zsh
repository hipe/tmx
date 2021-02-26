#!/usr/bin/env zsh

# NOTE: this is meant to be invoked only indirectly though:
#
#     py -m kiss_rdb_test.fixture_system_response_sources 010-timeline-one
#
# It's not intended to be run directly.


if [[ ! -e "_THIS_IS_A_TEMPORARY_DIRECTORY_" ]] ; then
  >&2 echo "no. not a temporary directory."
  exit 3
fi

git init .

for i in 1 2 3 4 5 ; do

  mv "file-snapshot-$i.eno" the-file.eno
  git add the-file.eno

  git commit -m "Commit number $i.

commit number $i line 2
commit number $i line 3
"

done

# #born
