# #[#019.file-type-D]

import os.path as os_path


def _():
    dn = os_path.dirname
    import sys

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

    return (top_test_dir,)


def hello_you():  # #open #[#707.B]
    pass


def sanity(s='assumption failed'):
    raise Exception(s)


(
    _top_test_dir,
) = _()

# #born.
