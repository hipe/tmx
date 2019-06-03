def _normalize_sys_path():  # see [#019]
    import os.path as os_path
    from sys import path as a

    dn = os_path.dirname
    test_sub_dir = dn(os_path.abspath(__file__))
    test_dir = dn(test_sub_dir)
    mono_repo_dir = dn(test_dir)

    if a[0] == test_sub_dir:
        a[0] = mono_repo_dir
    else:
        cover_me('no prob')

    assert(mono_repo_dir == a[0])


_normalize_sys_path()


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.
