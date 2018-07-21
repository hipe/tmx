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

        # we get here when running `pud tag_lyfe_test`
        None if project_dir == a[1] else sanity()
        # at #history-A.1 the above changed from being '' to being the
        # project dir.

        # for some weird reason we want the one thing to be first and the
        # other thing to be second. but this might change
        # changed at #history-A.1

        a[0] = project_dir
        a[1] = top_test_dir  # [#019.why-this-in-the-second-position]

    else:
        sanity()


def hello_you():  # #open #[#707.B]
    pass


def sanity(s='assumption failed'):
    raise Exception(s)


_()

# #history-A.1: things changed at upgrade to python 3.7
# #born.
