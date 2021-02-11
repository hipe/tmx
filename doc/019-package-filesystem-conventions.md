---
title: normalizing sys path
date: 2018-03-30T05:58:28-04:00
---
# note

This document used to be much longer before #history-A.2, before we decided
to let pipenv manage our `sys.path`.




## <a name='file-type-B'></a>"file type B": this `__init__.py`

when running the whole test suite, it's necessary that files like this
exist so that python knows that this module (directory as) exists, and
has (probably) python files in it.

👉 however, when any given test file is run individually as a standalone
entrypoint, it cannot reliably import this file. 👈

(if we figure out a way that it _yes could_ do this it might be nice and
it might make this wole thing less inelegant, but at present we don't know
how. our issues might be assuaged when an existing issue near [here][here1]
is resolved in python (near warning generated) but it might not - you can't
reach "above" "the module" in such an import when an individual test file
is the entrypoint.)

as such, this file _must_ exist but _must_ contain nothing. ich muss sein.



[here1]: https://docs.python.org/3/tutorial/modules.html#intra-package-references



## (document-meta)

  - #history-A.2
  - #history-A.1
  - #born.
