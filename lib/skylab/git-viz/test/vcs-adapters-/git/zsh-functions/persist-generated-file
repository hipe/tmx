#!/usr/bin/env zsh (just for highlighting)

typeset src=$1 dst=$2

-persist-generated-file () {
  if [[ ! -e "$src" ]] ; then
    print "no source file - $src" 1>&2 ; return 1
  elif [[ -e "$dst" ]] ; then
    -will-not-move-dump-file-because-destination-exists
  elif [[ "" = "$dst" ]] ; then
    print "cannot $0 - destination is empty"
    return 1
  else
    print "YAY: mv $src $dst"
    mv $src $dst
  fi
}

-will-not-move-dump-file-because-destination-exists () {
  cmp "$src" "$dst"
  if (( 0 == $? )) ; then
    print "no change, skipping: $dst" 1>&2
    return 0
  else
    print "STRANGE! files were different. won't clobber $dst" 1>&2
    return 1
  fi
}

-persist-generated-file
