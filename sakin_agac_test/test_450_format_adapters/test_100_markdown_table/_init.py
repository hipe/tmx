"""this is a *100% copy-paste* of the inelegant #[#019.file-type-C]. see."""

import sys


def _():
    import os

    path = os.path
    dn = path.dirname

    a = sys.path
    head = a[0]

    test_sub_sub_dir = dn(__file__)
    test_sub_dir = dn(test_sub_sub_dir)
    top_test_dir = dn(test_sub_dir)
    project_dir = dn(top_test_dir)

    if test_sub_sub_dir == head:
        a[0] = project_dir
    elif project_dir == head:
        pass
    else:
        raise Exception('sanity')


_()


import sakin_agac_test._init as x  # noqa: E402
sys.modules[__name__] = x


# #copy-pasted.
