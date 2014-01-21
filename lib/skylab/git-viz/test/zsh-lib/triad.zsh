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

-triad-call-out-to-API () {  # rc <- result code
  typeset line mani_API_path remote_rc
  required-parameter mani_path || return $?
  required-parameter callback_fname || return $?
  mani_API_path=$( -say-triad-manifest-API-script-path ) || return $?
  # a great battle was waged below to give you 2 streams & rc. fittingly ironic
  typeset tmpfile; tmpfile==()
  serr "(tmpfile: $tmpfile)"  # #debugging
  $mani_API_path --manifest-path $mani_path $* 1>$tmpfile 2>&2
  remote_rc=$?
  while read -r line ; do
    --triad-process-API-statement
  done < $tmpfile
  rm $tmpfile
  return $remote_rc
}
--triad-process-API-statement () {
  typeset -a row
  row=("${(@s.	.)line}")  # NOTE contains empty fields so use "$arr[@]"
  typeset channel_tuple statement_fname
  --triad-process-out-statement-fname-for-routing
  if (( $+functions[$statement_fname] )) ; then
    $statement_fname "$row[@]" ; func_rc=$?
    [[ (( 0 != $func_rc )) && (( 0 == $remote_rc)) ]] && remote_rc=$func_rc
    # any error from the API call trumps any first error from above call
  else
    serr "(unforseen channel tuple '${(f)channel_tuple}', ignoring.)"
  fi
}
--triad-process-out-statement-fname-for-routing () {
  case $#row in
    0) statement_fname=-triad-this-function-does-not-exist
       channel_tuple=('[zero-width]') ;;
    1) statement_fname=-triad-this-function-does-not-exist
       channel_tuple=('[no-channel]') ;;
    2) --triad-process-out-statement-fname-for-routing-from-monadic ;;
    *) --triad-process-out-statement-fname-for-routing-from-iambic ;;
  esac
}
--triad-process-out-statement-fname-for-routing-from-monadic () {
  typeset channel=$row[1]
  row=("${row[2,-1][@]}")  # omg really zsh
  statement_fname=-triad-process-$channel-string
  channel_tuple=("$channel")
}
--triad-process-out-statement-fname-for-routing-from-iambic () {
  typeset channel=$row[1] ; typeset shape=$row[2] ; typeset form=$row[3]
  row=("${row[4,-1][@]}")
  statement_fname=-triad-process-$form-$channel-$shape
  channel_tuple=("$channel" "$shape" "$form")
}

-triad-process-debug-string () {
  serr "${triad_indent}(debug from manifest API: ${(qqq)1})"
}

-triad-process-error-string () {
  serr "${triad_indent}(error from manifest API: ${(qqq)1})"
}

-triad-process-normalized_request-info-iambic () {
  typeset i ; typeset -a orly
  for i in {1..$#row} ; do  # poor man's map, egads
    orly[$i]="${(q)row[$i]}"
  done
  serr "${triad_indent}(norm'd echo: ${(q)mani_API_path} ${(fq)orly})"
}

-triad-process-command-payload-fixed_width () {
  typeset cmd=$1 from_dir=$2
  typeset triad_sout_fullpath=$(-triad-normalize-dumpfile-dst-path "$3")
  typeset triad_serr_fullpath=$(-triad-normalize-dumpfile-dst-path "$4")
  typeset expected_rc_s=$5
  typeset _reserved_='_reserved_'
  $callback_fname "$cmd" "$from_dir" $_reserved_ -triad-triad-callback
}

-triad-normalize-dumpfile-dst-path () {
  if [[ $1 =~ '^[^/]' ]] ; then
    -triad-expand-relative-dumpfile-dst-path "$1"
  else
    print -- "$1"
  fi
}

-triad-expand-relative-dumpfile-dst-path () {
  print -- "${${mani_path:-.}:h}/${1}"
}

-triad-triad-callback () {
  typeset outpath=$1 errpath=$2 actual_rc=$3 success_callback=$4
  typeset a b c out_operation err_operation
  out_operation=$( --triad-pre-mv out "$outpath" $triad_sout_fullpath ) ; a=$?
  err_operation=$( --triad-pre-mv err "$errpath" $triad_serr_fullpath ) ; b=$?
  -triad-validate-exitstatus "$actual_rc" $expected_rc_s ; c=$?
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

--triad-pre-mv () {
  typeset moniker=$1 src=$2 dst=$3
  if [[ ! -e $src ]] ; then
    serr "your system call script gave back"\
      "a path to a std${moniker} dump file that doesn't exist: $src"
    return $gv_err_no_resource
  elif [[ -z $dst && -s $src ]] ; then
    serr "${_TRIAD_FOSP}std${moniker} output was generated"\
      "but no \"s${moniker} file\" was specified in manifest."\
       "(${moniker}put is in dumpfile: $src)"
    return $gv_err_no_resource
  elif [[ -e $dst ]] ; then
    --triad-prepare-generated-file-move-when-destination-exists
  else
    --triad-prepare-generated-file-move-when-destination-does-not-exist
  fi
}

_TRIAD_FOSP='fatal off-script performance: '

--triad-prepare-generated-file-move-when-destination-exists () {
  cmp "$src" "$dst"
  if (( 0 == $? )) ; then
    print -- -triad-source-is-no-different-from-destination
    return $gv_success
  else
    serr "${_TRIAD_FOSP}files were different. won't clobber $dst"
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
  typeset prev=$RE_MATCH_PCRE ; RE_MATCH_PCRE=true
  typeset exitstatus
  if [[ ${expected_s:=0} =~ '\?[^[:alnum:]]?$' ]] ; then
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
    "actual $_TRIAD_RC was: $actual_s."\
    "(you may want this to be reflected in the manifest)"
  exitstatus=$gv_success
}
--triad-expected-exitstatus-looks-funny () {
  serr "fatal: malformed expected exitstatus string from manifest API -"\
    "expected '?' or <integer>, had: \"$expected_s\"."
  exitstatus=$gv_err_param_is_extra_white_grammatical
}
--triad-assert-expected-exitstatus () {
  if [[ $actual_s =~ '^[0-9]+$' ]] ; then
    if (( $actual_s == $expected_s )) ; then
      serr "${triad_indent}(system command had ${_TRIAD_RC} $actual_s"\
        "as expected)"
      exitstatus=$gv_success
    else
      serr "${_TRIAD_FOSP}: expected $_TRIAD_RC $expected_s"\
        "but actual $_TRIAD_RC was $actual_s."\
         "please correct your manifest or figure out"\
          "your vendor software"
      exitstatus=$gv_err_param_is_extra_white_grammatical
    fi
  else
    serr "fatal: bad argument from your system call callback: expected"\
      "$_TRIAD_RC to be an integer, had \"$actual_s\"."
    exitstatus=$gv_err_param_is_extra_white_grammatical
  fi
}

_TRIAD_RC=exitstatus

loud-cd () {
  serr "${triad_indent}cd $1"
  cd $1
}
