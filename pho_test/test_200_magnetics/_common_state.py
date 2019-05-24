import sys


def _normalize_sys_path():  # see [#019]
    a = sys.path
    from os import path

    dn = path.dirname
    test_sub_dir = dn(path.abspath(__file__))
    test_dir = dn(test_sub_dir)
    mono_repo_dir = dn(test_dir)

    if test_sub_dir == a[0]:
        if mono_repo_dir == a[1]:
            # when running just a sub-directory of tests, swap to look normal
            a[0] = mono_repo_dir
            a[1] = test_sub_dir
        else:
            # plain old test file is being executed in standalone
            a[0] = mono_repo_dir  # CLOBBER the "" empty string path
    else:
        cover_me('ohai')


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_normalize_sys_path()


from pho_test import _common_state as _  # noqa: E402
sys.modules[__name__] = _

# #born.
