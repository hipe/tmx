# init the autoloaded functions at this node. random orphans too

build-dumps-for-repo () {
  typeset tmp_dirname=$1
  validate-repo-dir-as-only-parameter "$tmp_dirname" $0 || return $?
  build-positive-dumps-for-repo $tmp_dirname || return $?
  build-negative-dumps-for-repo $tmp_dirname
}

validate-repo-dir-as-only-parameter () {
  typeset tmp_dirname=$1 ;  typeset me=$2
  if [[ ! -d $tmp_dirname ]] ; then
    print "usage: $me <dirname>. (not such directory: $tmp_dirname)" 1>&2
    return 1
  fi
}

component-stem-from-component-path () {
  # "friz-braz-1" from "x/y/for-friz-braz-1"
  # (centralize this hacky string "math" here)
  typeset pth=$1 ; typeset bn=$( basename $pth )
  print -- $bn[5,-1]
}

required-environment-parameter () {
  typeset param_name=$1 ; typeset param_value=$2 ; typeset me=$3
  if [[ "" = "$param_value" ]] ; then
    print -- "$me needs environment parameter \$${param_name} to be set." 1>&2
    return 1
  fi
}

resolve-VCS-name-from-tmp-dirname () {
  if [[ "" == $1 ]] ; then
    print "argument to $0 was empty" 1>&2
    return 1
  else
    print $1 | sed -E 's/^tmp\.([^.]+).+/\1/'
  fi
}

() {  # init autoloading for the autoloaded functions at this node

  [[ -z $VCS_DIR ]] && return 1
  typeset fdir=$VCS_DIR/zsh-functions file bn
  fpath=($fdir $fpath)
  for file ($fdir/*) ; do
    bn=$( basename $file )
    if [[ ! '_' = $bn[1] ]] ; then
      autoload $bn
    fi
  done
}
