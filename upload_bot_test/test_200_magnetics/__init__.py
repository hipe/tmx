"""(see [#204] and our cousin file there.)"""


def _():  # (a scope for lvars - don't accidentally export any names)

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

        a[1] = top_test_dir

    a[0] = project_dir


_()


import upload_bot_test  # noqa: E402, F401

# #born.
