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
    mono_repo_dir = dn(top_test_dir)

    if test_sub_sub_dir == head:
        # at #history-A.1: we realized we do not actually want to clobber
        # the sub-sub dir. if we "pud" the dir (see [#001.aliases]), that
        # dir must be in the sys path list.
        # so not this: `a[0] = mono_repo_dir` but this:
        a.insert(0, mono_repo_dir)
    elif mono_repo_dir == head:
        pass
    else:
        raise Exception('sanity')


_()


import sakin_agac_test._init as x  # noqa: E402
sys.modules[__name__] = x


# #history-A.1 (can be temporary) as referenced
# #copy-pasted.
