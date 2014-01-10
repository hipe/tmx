[[ -z "$GV" ]] && return 1

() {   # register all functions with the autoloader

  typeset bn func fdir=$GV/test/zsh-lib/functions

  fpath=($fdir $fpath)
  for func ($fdir/*) ; do
    bn=$( basename $func )
    autoload $bn
  done
}
