# read [#017] the fixtures buliding narrative #introduction

-init-component-fatal--missing-required-parameter () {
  serr "fatal: $1 must be set to init component." ; exit $gv_err_missing_param
}

serr () {
  print -- $* 1>&2
}

typeset gv_success=0
typeset gv_error=3  # 1 & 2 are reserved
typeset gv_err_missing_param=$(( gv_error + 1 ))
typeset gv_err_extra_param=$(( $gv_err_missing_param + 1 ))
typeset gv_err_no_resource=$(( $gv_err_extra_param + 1 ))
typeset gv_err_resource_exists=$(( $gv_err_no_resource + 1 ))
typeset gv_err_param_is_extra_white_grammatical
  gv_err_param_is_extra_white_grammatical=$(( $gv_err_resource_exists + 1 ))
typeset gv_err_param_is_intra_black_grammatical
  gv_err_param_is_intra_black_grammatical=\
$(( $gv_err_param_is_extra_white_grammatical ))

[[ -z $me ]] && -init-component-fatal--missing-required-parameter '$me'

[[ -z ${rest+x} ]] && -init-component-fatal--missing-required-parameter '$rest'

-mini-me () {  # like "$( basename $( dirname $me ))/$( basename $me )"
  echo $me | sed -E 's_^.+/([^/]+/[^/]+)$_\1_'
}

# ~ #storypoint-20 parameters imported into the caller's namespace

-directory-or-fatal () {
  [[ -d $1 ]] || -init-component-fatal--missing-required-resource $1
}

-init-component-fatal--missing-required-resource () {
  serr "fatal: $(-mini-me) will not procede without resource: $1/"
  exit $gv_err_no_resource
}

typeset component_node_local_top_dir=$( dirname $( dirname $me ) )

typeset component_node_zsh_lib_dir=$component_node_local_top_dir/zsh-lib
-directory-or-fatal $component_node_zsh_lib_dir

typeset component_node_functions_dir=$component_node_zsh_lib_dir/functions
-directory-or-fatal $component_node_functions_dir

component-node-splay () {
  typeset subcmd_stem=$rest[1]
  if [[ '-h' == $subcmd_stem ]] ; then
    -component-node-splay-help-requested
  else
    -component-node-splay-when-help-not-requested $rest
  fi
}

-component-node-splay-when-help-not-requested () {
  if [[ -z $subcmd_stem ]] ; then
    -component-node-splay-when-no-sub-command
  else
    -component-node-splay-when-sub-command $rest
  fi
}

-component-node-splay-when-sub-command () {
  -component-node-splay-dispatch-sub-command
}

-component-node-splay-dispatch-sub-command () {
  -load-component-node-functions-once
  typeset fprefix="$( -say-component-node-function-name-prefix )"
  typeset token="${rest[1]}"
  typeset fname="$fprefix$token"
  # serr "(about too try to run \"$fname\" for $me)"  # #debugging
  if (( $+functions[$fname] )) ; then
    -component-node-splay-call-function $fname $rest
  else
    -component-nonde-splay-no-such-function
  fi
}

-load-component-node-functions-once () {
  -load-component-node-functions-once () {}
  fpath=($component_node_functions_dir $fpath)  # NOTE 'fpath' is magic
  typeset file bn
  for file ($component_node_functions_dir/*) ; do
    bn=$( basename $file )
    if [[ ! '_' = $bn[1] ]] ; then  # hackishly disappear a function this way
      autoload $bn
      # serr "('$bn' registered to autoload via $file)"  # #debugging
    fi
  done
}

-component-node-splay-call-function () {
  typeset fname=$1 ; shift ; shift  # $2 was cruft
  $fname $*
}

-component-nonde-splay-no-such-function () {
  typeset s="$( -say-component-node-child-moniker )"
  typeset prefix="$( -mini-me ) has no '${rest[1]}' $s. "
  -print-component-node-splay-sub-commands-screen $prefix
}

-component-node-splay-when-no-sub-command () {
  -component-node-splay-missing-sub-command
}

-component-node-splay-missing-sub-command () {
  typeset s=$( -component-node-first-arg-moniker )
  -print-component-node-splay-usage-line "expecting $s. "
  -print-component-node-splay-invite
  return $gv_err_missing_param
}

-component-node-first-arg-moniker () {
  typeset s="$( -say-component-node-child-moniker )"
  s=$( echo $s | sed -E 's/ /-/' )
  print "<$s>"
}

-say-component-node-child-moniker-plural () {
  print "$( -say-component-node-child-moniker )s"
}

-say-component-node-child-moniker () {
  print "sub command"
}

-component-node-splay-help-requested () {
  -hdr () { -stylized-hdr $1 }
  -print-component-node-splay-usage-line
  -print-component-node-description
  -print-component-node-children-help-screen-section
}

-print-component-node-description () {}

-print-component-node-splay-usage-line () {
  typeset prefix=$1
  serr "${prefix}$( -hdr usage: ) $me $( -say-component-node-args )"
}

-say-component-node-args () {
  typeset s="$( -component-node-first-arg-moniker )"
  print "$s [..]"
}

-print-component-node-children-help-screen-section () {
  serr
  typeset _hdr_line _moniker _styled
  _moniker=$( -say-component-node-child-moniker-plural )
  _styled=$( -hdr $_moniker )
  -print-component-node-splay-sub-commands-screen "" $_styled
  return $gv_success
}

-print-component-node-splay-sub-commands-screen () {
  typeset prefix=$1 infix=$2 suffix=$3
  typeset s="$( -say-component-node-child-moniker-plural )"
  [[ -z $infix ]] && infix="available $s"
  serr "${prefix}${infix}${suffix}:"
  typeset -a arr
  arr=(${(f)"$(-say-each-component-child-node-slug)"})
  for x ($arr) ; do
    print " • $x"
  done
}

-say-each-component-child-node-slug () {
  -say-each-component-child-node-slug-from-function-dir-glob
}

-say-each-component-child-node-slug-from-function-dir-glob () {
  typeset fprefix="$( -say-component-node-function-name-prefix )"
  typeset glob_body="$component_node_functions_dir/$fprefix"
  typeset x omg
  for x ($glob_body*) ; do
    omg=$( echo $x | sed -E "s_^.+/${fprefix}([^/]+)\$_\1_" )
    print -- $omg
  done
}

-say-component-node-function-name-prefix () {
  typeset head="$( basename $me )"
  typeset tail="$( -say-component-node-function-name-prefix-infix )"
  print -- "$head$tail"
}

-say-component-node-function-name-prefix-infix () {
  print -- '-'
}

-print-component-node-splay-invite () {
  serr "use $( -stylized-hdr "$me -h" ) for help"
}

-hdr () {
  print $1
}

-stylized-hdr () {
  print "\e[32m$1\e[0m"
}

-say-component-node-error-predicate () {
  say-component-node-error-predicate-for-any-base-exitstatus $*
}

say-component-node-error-predicate-for-any-base-exitstatus () {
  typeset exitstatus="$1"  # note it's string not integer now
  typeset s
  case $exitstatus in
    "$gv_error")
      s="did not accomplish its goal"
      ;;
    "$gv_err_missing_param")
      s="could not execute because of a missing parameter"
      ;;
    "$gv_err_extra_param")
      s="would not execute because of an unexpected parameter"
      ;;
    "$gv_err_no_resource")
      s="could not execute because a required resource was not resolved"
      ;;
    "$gv_err_resource_exists")
      s="would not execute because\
 otherwise it would have clobbered an existing resource"
      ;;
    "$gv_err_param_is_extra_white_grammatical")
      s="could not execute because\
 parameter is outside the grammar of valid values"
      ;;
    "$gv_err_param_is_intra_black_grammatical")
      s="could not execute because parameter has a disallowed value"
      ;;
    *)
      s="exited with the mysterious exit code $exitstatus"
      ;;
  esac
  if [[ ! -z $s ]] ; then
    print -- $s
    return $gv_success
  else
    return $gv_error
  fi
}

# ~ the below is not reached by the above, but may be so via client hooking

dispatch-target-to-child-build-script () {
  typeset tgt_name=$1 ; shift ; typeset child=$1 ; shift
  typeset script
  script=$( -say-build-script-for-child-node $child ) || return $?
  # serr "might dispatch to child script - '$script'"  # #debugging
  if [[ ! -f $script ]] ; then
    -when-no-such-build-script-for-child $script $child ; return $?
  fi
  if [[ ! -x $script ]] ; then
    -when-build-script-for-child-is-not-executable $script $child ; return $?
  fi
  -dispatch-target-to-sanitized-child-build-script $script $tgt_name $*
}

-say-build-script-for-child-node () {
  required-parameter child_nodes_dir || return $?
  print $child_nodes_dir/$1/script/build
}

required-parameter () {
  [[ -z ${(P)1} ]] || return $gv_success
  serr "aborting because a function cannot not run because \$$1 is not set."
  return $gv_err_missing_param
}

-when-no-such-build-script-for-child () {
  serr "cannot execute $( -say-component-node-child-moniker ) '$2' -\
 build script not found: $1"
  return $gv_err_no_resource
}

-when-build-script-for-child-is-not-executable () {
  serr "cannot build '$2' - build script is not executable: $1"
  return $gv_err_no_resource
}

-dispatch-target-to-sanitized-child-build-script () {
  typeset script=$1 ; shift
  $script $*
  typeset exitstatus=$?
  if (( $gv_success != $exitstatus )) ; then
    -when-child-build-script-results-in-nonzero-exitstatus $script $exitstatus
    exitstatus=$?
  fi
  return $exitstatus
}

-when-child-build-script-results-in-nonzero-exitstatus () {
  typeset script=$1 exitstatus=$2
  typeset s="$( -say-component-node-error-predicate $exitstatus )"
  serr "(notice: child script $s: $script)"
  return $exitstatus
}

say-each-child-node-with-a-build-script () {  # clients may hook in via this
  required-parameter child_nodes_dir || return $?
  typeset x
  for x ($child_nodes_dir/*/script/build) ; do
    print $( basename $( dirname $( dirname $x ) ) )
  done
,n}
