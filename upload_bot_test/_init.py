"""this is *the* [#019.file-type-D]. see."""

import os
path = os.path


def _():
    import sys

    dn = path.dirname

    a = sys.path
    head = a[0]

    test_sub_dir = dn(__file__)
    project_dir = dn(test_sub_dir)

    if project_dir == head:

        pass  # assume low entrypoint loaded us to use for resources

    elif test_sub_dir == head:
        if '' != a[1]:
            raise Exception('assumption failed')
        a[0] = project_dir
        a[1] = test_sub_dir
        # the above is likely to change soon to keep '' in there

        """now, project dir is at the front like it always is, and we have
        moved the test sub dir from head to the second position so when other
        test files require this file, it's still in the `sys.path`
        """
    else:
        raise Exception('assumption failed')

    return test_sub_dir


_test_sub_dir = _()
writable_tmpdir = path.join(_test_sub_dir, 'writable-tmpdir')

# #born.
