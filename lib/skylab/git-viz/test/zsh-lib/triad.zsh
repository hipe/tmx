#!/usr/bin/env zsh (just for highlighting)

set-triad-manifest-API-script () {
  _TRIAD_MANIFEST_API_SCRIPT=$1
  -say-triad-manifest-API-script-path () {
    print -- "$_TRIAD_MANIFEST_API_SCRIPT"
  }
}

-say-triad-manifest-API-script-path () {
  serr "you did not 'set-triad-manifest-API-script'"
  return $gv_err_missing_param
}

triad-lookup-system-commands () {
  typeset -a rest ; rest=($*)
  typeset i=1 x
  typeset callback_fname mani_path
  while (( i <= $#rest )) ; do
    x=$rest[$i]
    case $x in
      --each-command)
        callback_fname=$rest[$(( $i + 1 ))]
        rest[$i,$(( $i + 1 ))]=() ;;
      --system-commands-manifest)
        mani_path=$rest[$(( $i + 1 ))]
        rest[$i,$(( $i + 1 ))]=() ;;
      *)
        i=$(( $i + 1 )) ;;
    esac
  done
  -triad-call-out-to-API $rest
}

-triad-call-out-to-API () {
  typeset chan_fname es exitstatus line mani_API_path row row_tail
  required-parameter mani_path || return $?
  required-parameter callback_fname || return $?
  mani_API_path=$( -say-triad-manifest-API-script-path ) || return $?
  # (a great battle was waged below to give you 2 stream and an e.s - ironic)
  typeset tmpfile; tmpfile==()
  $mani_API_path --manifest-path $mani_path $* 1>$tmpfile 2>&2
  typeset exitstatus=$?
  while read -r line ; do
    row=(${(@s.	.)line})
    row_tail=($row[2,-1])
    chan_fname=-triad-process-${row[1]}-row
    if (( $+functions[$fname] )) ; then
      $chan_fname $row_tail ; es=$?
      [[ (( 0 != $es )) && (( 0 == $exitstatus )) ]] && exitstatus=$es
    else
      serr "(unexpected channel name '${row[1]}', ignoring.)"
    fi
  done < $tmpfile
  rm $tmpfile
  return $exitstatus
}

-triad-process-info-row () {
  serr "${triad_indent}(info from manifest API: ${(qqq)1})"
}

-triad-process-notice-row () {
  serr "${triad_indent}(notice from manifest API: ${(qqq)1})"
}

-triad-process-error-row () {
  serr "error from manifest API: ${(qqq)1}"
}

-triad-process-payload-row () {
  typeset cmd=${(q)1} from_dir=$2

  typeset triad_sout_fullpath=$3
  typeset triad_serr_fullpath=$4
  typeset triad_exitstatus_s=$5
  typeset _reserved_='_reserved_'
  $callback_fname ${1} $from_dir $_reserved_ -triad-triad-callback
}

-triad-triad-callback () {
  typeset outpath=$1 errpath=$2 exitstatus$3 success_callback=$4
  typeset a b c out_operation err_operation
  out_operation=$( --triad-prepare-move "$outpath" $triad_sout_fullpath );a=$?
  err_operation=$( --triad-prepare-move "$errpath" $triad_serr_fullpath );b=$?
  -triad-validate-exitstatus "$exitstatus" $triad_exitstatus_s ; c=$?
  (( 0 == a )) || return $a
  (( 0 == b )) || return $b
  (( 0 == c )) || return $c
  $out_operation output $outpath $triad_sout_fullpath ; a=$?
  $err_operation errput $errpath $triad_serr_fullpath ; b=$?
  (( 0 == a )) || return $a ; (( 0 == $b )) || return $b
  ${success_callback--triad-default-success-callback}
}

-triad-default-success-callback () {
  serr "finished building $( -triad-say-any-extra-part-description )part."
  return $gv_success
}

-triad-say-any-extra-part-description () {
  typeset s=$( -say-this-part )
  [[ -z $s ]] || print "'$s' "
}

--triad-prepare-move () {
  typeset src=$1 dst=$2
  if [[ ! -e $src ]] ; then
    serr "source path points to nonexistant file - $src"
    return $gv_err_no_resource
  elif [[ -z $dst ]] ; then
    serr "cannot perist generated file - destination parameter is empty"
    return $gv_err_no_resource
  elif [[ -e $dst ]] ; then
    --triad-prepare-generated-file-move-when-destination-exists
  else
    --triad-prepare-generated-file-move-when-destination-does-not-exist
  fi
}

--triad-prepare-generated-file-move-when-destination-exists () {
  cmp "$src" "$dst"
  if (( 0 == $? )) ; then
    print -- -triad-source-is-no-different-from-destination
    return $gv_success
  else
    serr "fatal: off-script performance:"\
      "files were different. won't clobber $dst"
    return $gv_err_resource_exists
  fi
}

--triad-prepare-generated-file-move-when-destination-does-not-exist () {
  if [ -s $src ] ; then
    print -- -triad-move-dumpfile-when-destination-does-not-exist-operation
    return $gv_success
  else
    print -- -triad-source-is-empty-and-destination-does-not-exist-operation
    return $gv_success
  fi
}

-triad-source-is-no-different-from-destination () {
  serr "${triad_indent}no change, skipping: $3"
  serr "${triad_indent}rm $2"
  rm $2  # #dry-run
}

-triad-source-is-empty-and-destination-does-not-exist-operation () {
  serr "${triad_indent}(as expected,"\
    "there was no $1 from the system call. removing tmpfile)"
  serr "${triad_indent}rm $2"
  rm $2  # #dry-run
}

-triad-move-dumpfile-when-destination-does-not-exist-operation () {
  serr "  mv $2 $3"
  mv -n "$2" "$3"  # #dry-run
}

-triad-validate-exitstatus () {
  typeset actual_s=$1 expected_s=$2
  typeset prev=$RE_MATCH_PCRE ; $RE_MATCH_PCRE=true
  typeset exitstatus
  if [[ $expected_s =~ '\?[^[:alnum:]]?$' ]] ; then
    --triad-announce-actual-exitstatus
  elif [[ ! ( $expected_s =~ '^[0-9]+$' ) ]] ; then
    --triad-expected-exitstatus-looks-funny
  else
    --triad-assert-expected-exitstatus
  fi
  RE_MATCH_PCRE=prev
  return exitstatus
}
--triad-announce-actual-exitstatus () {
  serr "${triad_indent}notice: in response to the manifest API's query,"\
    "actual exitstatus was: $actual_s."\
    "(you may want this to be reflected in the manifest)"
  exitstatus=$gv_success
}
--triad-expected-exitstatus-looks-funny () {
  serr "fatal: malformed expected exitstatus string from manifest API -"\
    "expected '?' or <integer>, had: \"$expected_s\"."
  exitstatus=$gv_err_param_is_extra_white_grammatical
}
--triad-assert-expected-exitstatus () {
  if [[ $actual_s =~ '^\d+$' ]] ; then
    if (( $actual_s == $expected_s )) ; then
      exitstatus=$gv_success
    else
      serr "fatal: off-script peformance: expected exitstatus $expected_s,"\
        "had $actual_s. please correct your manifest or figure out"\
        "your vendor software"
      exitstatus=$gv_err_param_is_extra_white_grammatical
    fi
  else
    serr "fatal: bad argument from your system call callback: expected"\
      "exitstatus to be an integer, had \"$actual_s\"."
    exitstatus=$gv_err_param_is_extra_white_grammatical
  fi
}

loud-cd () {
  serr "${triad_indent}cd $1"
  cd $1
}
