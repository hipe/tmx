"""do two things:

1) mutate `sys.path` such that if from our tests we can load any arbitrary
asset file and it can assume the `sys.path` it has in production.

2) maintain a set of names we export. (things useful for testing).


because our (at writing) only item for (2) is a directory path that resides
one level up from us, we decided that a more sane location to do this work
a same-named file one level up from us.

in order to reach such a file we have to manipulate `sys.path` ourselves.

(#history-A.1 is when we schlurped codemess into this one file.)
"""


def _():
    """
    (make it so all lvars are in a scope except those we explicitly export)
    """
    import os
    import sys

    path = os.path
    dirname = path.dirname

    entrypoint_test_dir = dirname(path.abspath(__file__))
    top_test_dir = dirname(entrypoint_test_dir)

    project_dir = dirname(top_test_dir)

    a = sys.path
    current_head_path = a[0]

    if entrypoint_test_dir == current_head_path:  # test file is entrypoint
        pass

    else:  # test suite is being run

        if top_test_dir != a[0]:
            raise Exception('assumption failed')

        if '' != a[1]:
            raise Exception('assumption failed')

        # BE REALLY FASCIST - clobber both pwd and specific test dir!
        # (we don't want to be importing anything without "absolute paths"

        a[1] = top_test_dir  # left in it so when child tests say `import __init__`..

    a[0] = project_dir
_()


from grep_dump_test import(
        writable_tmpdir,
        )

# #history-A.1
