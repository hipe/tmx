import sys


def _():
    import os

    path = os.path
    dn = path.dirname

    a = sys.path
    head = a[0]

    test_sub_dir = dn(__file__)
    top_test_dir = dn(test_sub_dir)
    mono_repo_dir = dn(top_test_dir)

    if test_sub_dir == head:
        a.insert(0, mono_repo_dir)
    elif mono_repo_dir == head:
        raise Exception('hello')
        pass
    else:
        raise Exception('sanity')


_()


import sakin_agac_test._init as x  # noqa: E402
sys.modules[__name__] = x

# #copy-pasted (mostly)
