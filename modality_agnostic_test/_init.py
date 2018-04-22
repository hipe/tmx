"""this is *the* [#019.file-type-D]. see."""

import os
path = os.path


def _():
    import sys

    dn = path.dirname
    a = sys.path
    head = a[0]

    top_test_dir = dn(__file__)
    project_dir = dn(top_test_dir)

    if project_dir == head:

        pass  # assume low entrypoint loaded us to use for resources

    elif top_test_dir == head:
        None if '' == a[1] else sanity()
        a[0] = project_dir
        a[1] = top_test_dir  # [#019.why-this-in-the-second-position]

    else:
        sanity()


def sanity():
    raise Exception('assumption failed')


_()

# #born.
