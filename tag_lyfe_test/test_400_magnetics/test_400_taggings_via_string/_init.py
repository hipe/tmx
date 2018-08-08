# #[#019.file-type-C]

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
        # don't clobber the sub-sub dir. (see cousin files)
        a.insert(0, mono_repo_dir)
    elif mono_repo_dir == head:
        pass
    else:
        raise Exception('sanity')


_()


import tag_lyfe_test._init as x  # noqa: E402
sys.modules[__name__] = x

# #copy-pasted.
