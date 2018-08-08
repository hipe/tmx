"""this is *the* [#019.file-type-D]. see."""

import os
path = os.path


def _():
    import sys

    dn = path.dirname
    a = sys.path
    head = a[0]

    top_test_dir = dn(__file__)
    mono_repo_dir = dn(top_test_dir)

    if mono_repo_dir == head:

        pass  # assume low entrypoint loaded us to use for resources

    elif top_test_dir == head:
        if '' == a[1]:  # assume tree loaded by unittest
            a[0] = mono_repo_dir
            a[1] = top_test_dir  # [#019.why-this-in-the-second-position]
        else:
            a[0] = mono_repo_dir

    else:
        sanity()


def sanity():
    raise Exception('assumption failed')


_()

# #born as copy-paste.
