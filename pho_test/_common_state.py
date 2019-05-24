import os.path as os_path


def lazy(f):  # #meh
    is_first_call = True
    x = None

    def use_f():
        nonlocal is_first_call
        nonlocal x
        if is_first_call:
            is_first_call = False
            x = f()
        return x
    return use_f


def _normalize_sys_path():  # see [#019]
    from sys import path as a

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

    return test_dir


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_top_test_dir = _normalize_sys_path()


def fixture_directory(stem):
    return os_path.join(fixture_directories_path(), stem)


@lazy
def fixture_directories_path():
    return os_path.join(_top_test_dir, 'fixture-directories')


def throwing_listenerer():
    return kiss_rdber().THROWING_LISTENER


def kiss_rdber():
    import kiss_rdb as _
    return _

# #born.
