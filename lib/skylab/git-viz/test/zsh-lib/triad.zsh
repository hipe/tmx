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
  typeset frame_count=0 line mani_API_path remote_rc
  required-parameter mani_path || return $?
  required-parameter callback_fname || return $?
  mani_API_path=$( -say-triad-manifest-API-script-path ) || return $?
  # a great battle was waged below to give you 2 streams & rc. fittingly ironic
  typeset tmpfile; tmpfile==()
  # serr "  (tmpfile: $tmpfile)"  # #debugging
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

-triad-process-info-string () {
  serr "${triad_indent}(info from manifest API: ${(qqq)1})"
}

-triad-process-notice-string () {
  serr "${triad_indent}(notice from manifest API: ${(qqq)1})"
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
  typeset -A triad_manifest_dumpfile_shortpath
  triad_manifest_dumpfile_shortpath[out]="$3"
  triad_manifest_dumpfile_shortpath[err]="$4"
  typeset triad_sout_fullpath=$(-triad-normalize-dumpfile-dst-path "$3")
  typeset triad_serr_fullpath=$(-triad-normalize-dumpfile-dst-path "$4")
  typeset expected_rc_s=$5
  typeset -A freetags ; -triad-parse-marshalled-freetags $6
  -triad-maybe-separator
  $callback_fname "$cmd" "$from_dir" -triad-triad-callback
}
-triad-parse-marshalled-freetags () {
  (( 0 == $# )) && return
  typeset x ; typeset -a a
  for x do
    a=(${(s:=:)x})
    freetags[${a[1]}]="${a[2]}"
  done
}

-triad-maybe-separator () {
  frame_count=$(( $frame_count + 1 ))
  if (( 1 < $frame_count )) ; then
    if [[ 0 == $(( $frame_count % 2 )) ]] ; then
      -triad-report-even-separator
    else
      -triad-report-odd-separator
    fi
  fi
}
-triad-report-even-separator () { serr '☆彡' }
-triad-report-odd-separator () { serr '☆ミ' }

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
  $out_operation out $outpath $triad_sout_fullpath ; a=$?
  $err_operation err $errpath $triad_serr_fullpath ; b=$?
  (( 0 == a )) || return $a ; (( 0 == $b )) || return $b
  ${success_callback:-'-triad-default-success-callback'}
}
-triad-default-success-callback () {
  serr "finished building $( -triad-say-any-extra-part-description )part."
  return $gv_success
}
-triad-say-any-extra-part-description () {
  typeset s=$($partlib_say_part_moniker)
  [[ -z $s ]] || print "'$s' "
}

--triad-pre-mv () {
  typeset stream=$1 src=$2 dst=$3
  typeset dst_exists dst_has_content dst_is_specified
  typeset src_exists src_has_content
  --triad-pre-mv-build-state
  --triad-pre-mv-act-on-state
}

--triad-pre-mv-build-state () {
  if [[ ! -z $dst ]] ; then
    dst_is_specified=true
    if [[ -s $dst ]] ; then
      dst_exists=true ; dst_has_content=true
    elif [[ -e $dst ]] ; then
      dst_exists=true
    fi
  fi
  if [[ -s $src ]] ; then
    src_exists=true ; src_has_content=true
  elif [[ -e $src ]] ; then
    src_exists=true
  fi
}

--triad-pre-mv-act-on-state () {
  if [[ $src_has_content == true ]] ; then
    if [[ $dst_has_content == true ]] ; then
      --triad-pre-mv-when-both-have-content
    elif [[ $dst_exists == true ]] ; then
      --triad-off-script-content-emergence
    elif [[ $dst_is_specified == true ]] ; then
      --triad-pre-mv-when-first-build
    else
      --triad-off-script-unexpected-content
    fi
  elif [[ $src_exists == true ]] ; then
    if [[ $dst_has_content == true ]] ; then
      --triad-off-script-content-disappearance
    elif [[ $dst_exists == true ]] ; then
      print -- --triad-when-one-empty-file-to-another-remove-source
    elif [[ $dst_is_specified == true ]] ; then
      --triad-off-script-expected-content-did-not-occur
    else
      print -- --triad-remove-empty-file-and-report-no-output-as-expected
    fi
  else
    --triad-bad-parameters-from-callback-source-dumpfile-does-not-exist
  fi
}
--triad-bad-parameters-from-callback-source-dumpfile-does-not-exist () {
  serr "your system call script gave back"\
    "a path to a std${moniker} dump file that doesn't exist: $src"
  return $gv_err_no_resource
}
--triad-pre-mv-when-both-have-content () {
  typeset cmp_output
  cmp_output=$(cmp -- "$src" "$dst")
  if (( 0 == $? )) ; then
    print -- --triad-remove-source-file-when-no-change
  else
    --triad-off-script-content-change
  fi
}
--triad-off-script-content-change () {
  serr "${_TRIAD_FOSP}the std${stream} of the performance was different"\
    "than what is in the fixture dumpfile:"
  serr $cmp_output
  return $_TRIAD_OFF_SCRIPT
}
--triad-pre-mv-when-first-build () {
  typeset dst_dirname=$dst:h
  typeset dst_dirname_dirname=$dst_dirname:h
  if [[ ! -d $dst_dirname ]] ; then
    if [[ ! -d $dst_dirname_dirname ]] ; then
      serr "fatal: when saving dumpfiles, we won't create more than"\
        "one directory. this directory must exist: $dst_dirname_dirname"
      return $gv_err_no_resource
    else
      print -- --triad-create-directory-and-mv-file
    fi
  else
    print -- --triad-mv-file
  fi
}
--triad-off-script-content-emergence () {
  serr "${_TRIAD_FOSP}the fixtures have an empty ${stream}put dumpfile"\
    "but the performance dump had content ($src)."
  serr "${triad_indent}if the performance dump looks correct, consider"\
    "running the performance again after removing the empty manifest file: $dst"
  return $_TRIAD_OFF_SCRIPT
}
--triad-off-script-unexpected-content () {
  serr "${_TRIAD_FOSP}the performance wrote to the std${stream} stream"\
    "but no \"s${stream} file\" was specified in the manifest."
  serr "${triad_indent}inspect the ${stream}put in the temporary dumpfile"\
    "and if it looks right, consider specifying a name in the manifest: $src"
  return $_TRIAD_OFF_SCRIPT
}
--triad-off-script-content-disappearance () {
  serr "${_TRIAD_FOSP}the performance wrote nothing to the std${stream}"\
    "stream but the content in this file was expected: $dst"
  return $_TRIAD_OFF_SCRIPT
}
--triad-off-script-expected-content-did-not-occur () {
  serr "${_TRIAD_FOSP}the manifest specified a \"s${stream} file\""\
    "but the performance wrote nothing to std${stream}."
  serr "${triad_indent}if the performance is not expected to generate any"\
    "${stream}put, remove the filename from the manifest"\
     " (${triad_manifest_dumpfile_shortpath[$stream]})"
  return $_TRIAD_OFF_SCRIPT
}
--triad-create-directory-and-mv-file () {
  typeset dirname="${3:h}"
  serr "キタ━━━(゜∀゜)━━━!!!!! (mkdir $dirname)"  # kitaa!
  mkdir -- "$dirname" || return $?  # #dry-run
  --triad-mv-file "${*[@]}"
}
--triad-mv-file () {
  serr "${triad_indent}mv $2 $3"
  mv -n -- "$2" "$3"  # #dry-run
}
--triad-when-one-empty-file-to-another-remove-source () {
  serr "(notice: empty fixture files are extraneous. they and their "\
    "manifest entries should be removed: "\
     "${triad_manifest_dumpfile_shortpath[$1]}"
  --triad-remove-empty-file-and-report-no-output-as-expected "${*[@]}"
}
--triad-remove-empty-file-and-report-no-output-as-expected () {
  serr "${triad_indent}no ${1}put as expected."
  rm -- "$2"  # #dry-run
}
--triad-remove-source-file-when-no-change () {
  serr "${triad_indent}${1}put is exactly as expected"\
    "($(stat -f%z $3) bytes)."
  rm -- "$2"  # #dry-run
}
_TRIAD_FOSP='fatal off-script performance: '
_TRIAD_OFF_SCRIPT=$gv_early_exit

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
      --triad-report-that-exitstatus-was-as-expected
    else
      --triad-off-script-exit-status
    fi
  else
    --triad-bad-parameter-for-exit-status
  fi
}
--triad-report-that-exitstatus-was-as-expected () {
  serr "${triad_indent}system command ${_TRIAD_RC} $actual_s"\
    "is as expected"
  exitstatus=$gv_success
}
--triad-off-script-exit-status () {
  serr "${_TRIAD_FOSP}: expected $_TRIAD_RC $expected_s"\
    "but actual $_TRIAD_RC was $actual_s."\
     "please correct either your manifest or your performance."
  exitstatus=$gv_err_param_is_extra_white_grammatical
}
--triad-bad-parameter-for-exit-status () {
  serr "fatal: bad argument from your system call callback: expected"\
    "$_TRIAD_RC to be an integer, had \"$actual_s\"."
  exitstatus=$gv_err_param_is_extra_white_grammatical
}

_TRIAD_RC=exitstatus

loud-cd () {
  serr "${triad_indent}cd $1"
  if [[ -d $1 ]] ; then
    cd -- $1
  else
    serr "no such directory: $1"
    return $gv_err_no_resource
  fi
}
