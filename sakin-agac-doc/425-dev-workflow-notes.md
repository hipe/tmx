---
title: "to use `git bisect`"
date: "2018-12-07T03:10:42-05:00"
---
# to use `git bisect`

this is basically a condensed subset of what is explained in the excellent
manpage.

1. you need to know a "bad commit" that has the test failing.
   and you need to know a "good commit".

1. do this:

```bash
$ git bisect start abc3f 23edef --  # good commit then bad (i think)
$ git bisect run python3 yadda yadda sakin_agac_test    # expand your aliass
$ git bisect reset    # quit the bisect session
```



## (document-meta)

  - #born.
