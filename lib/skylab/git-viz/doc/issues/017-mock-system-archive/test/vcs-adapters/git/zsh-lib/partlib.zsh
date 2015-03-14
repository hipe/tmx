
if ! (( 0 == $gv_success )) ; then
  print "fatal: partlib requires the 'init-component-node' library" 1>&2
  return 6  # if we are lucky this is 'gv_no_resource'
fi

_PARTLIB_FILE=$0

--partlib-will-always-add-these-functions-when-you-load-this-file() {
  typeset dir=${_PARTLIB_FILE:h}/partlib-functions
  if [[ ! -d $dir ]] ; then
    serr "fatal: where is partlib functions dir? - $dir"
    return $gv_no_resource
  fi
  -component-node-add-all-functions-in-directory "$dir" || return $?
}

--partlib-will-always-add-these-functions-when-you-load-this-file || return $?


# ~ help narrative (see [#028] #dynamic-scoping-as-ersatz-vtable)

partlib-parse-adverb-and-asset-output-dir () {
  # [#028] #storypoint-2
  adverb=$rest[$#rest]
  asset_output_dir=$rest[$(($#rest - 1 ))]
  rest[$(($#rest - 1)),${#rest}]=()
}

-partlib-help () {  # [#028] #when-to-use-volatile-functions
  case "$rest[1]" in
    -h | --help )
      $partlib_render_help
      ;;
    *)
      return 1
      ;;
  esac
}

partlib_render_help=partlib-render-help
partlib-render-help () {
  $partlib_usage
  $partlib_description
  return 0
}

partlib_usage=partlib-usage
partlib-usage () {
  typeset fname=part-$($partlib_say_part_moniker)-usage
  if (( $+functions[$fname] )) ; then
    $fname
  else
    serr "usage: $($partlib_say_invocation_name) [...]"
  fi
}

partlib_say_invocation_name=partlib-say-invocation-name
partlib-say-invocation-name () {
  print -- "$me part $($partlib_say_part_moniker)"
}

partlib_say_part_moniker=partlib-say-part-moniker
partlib-say-part-moniker () {
  print -- "${part_func##part-}"
}

partlib_description=partlib-description
partlib-description () {
  typeset x=$( $partlib_say_part_moniker )
  typeset fname=part-${x}-description
  if (( $+functions[$fname] )) ; then
    $fname
  fi
}

# ~ payload behavior sub-narrative

-partlib-require-asset-output-dir () {  # same technique as '-partlib-help'
  if [[ ! -d $asset_output_dir ]] ; then
    serr "'$( $partlib_say_part_moniker )' requires that"\
      "'${asset_stem#mock-}' be built first (sorry, this isn't 'make' :P)."
    return $gv_err_no_resource
  fi
  return $gv_success
}
