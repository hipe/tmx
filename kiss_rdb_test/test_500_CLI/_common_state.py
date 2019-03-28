def _normalize_sys_path():  # see [#019]. this is copy-paste-prune of cousin
    from sys import path as a
    from os import path

    dn = path.dirname
    test_sub_dir = dn(path.abspath(__file__))
    _test_dir = dn(test_sub_dir)
    mono_repo_dir = dn(_test_dir)

    if test_sub_dir == a[0]:
        if mono_repo_dir == a[1]:
            a[0] = mono_repo_dir
            a[1] = test_sub_dir
        else:
            a[0] = mono_repo_dir  # CLOBBER
    else:
        raise Exception('cover me: unexpected sys.path state')


_normalize_sys_path()


from kiss_rdb_test import _common_state as _  # noqa: E402
import sys  # noqa: E402
sys.modules[__name__] = _

# #born.
