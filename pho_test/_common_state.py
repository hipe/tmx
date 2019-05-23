def _normalize_sys_path():  # see [#019]
    from sys import path as a
    import os.path as os_path

    dn = os_path.dirname
    test_dir = dn(os_path.abspath(__file__))
    mono_repo_dir = dn(test_dir)

    if test_dir == a[0]:
        # when running all tests
        assert(mono_repo_dir == a[1])
        a[0] = mono_repo_dir
        a[1] = test_dir

    elif mono_repo_dir == a[0]:
        # a lower-level same file already did this. loaded us for resources
        pass
    else:
        cover_me('ohai')

    assert(mono_repo_dir == a[0])


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_normalize_sys_path()

# #born.
