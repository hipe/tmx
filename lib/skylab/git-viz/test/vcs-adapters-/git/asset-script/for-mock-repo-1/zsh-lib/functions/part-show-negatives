#!/usr/bin/env zsh  #just-for-syntax-highlighting

serr "pretend to show negatives"

return $gv_success

  transient_out=tmp.show.456456.out.txt
  transient_err=tmp.show.456456.err.txt
  transient_iam=tmp.show.456456.iam.txt
  $vcs_exe show --numstat --pretty=tformat:%ai 456456 -- \
    1>"$transient_out" 2>"$transient_err"
  typeset exitstatus=$?
  print "exitstatus $exitstatus" > "$transient_iam"
