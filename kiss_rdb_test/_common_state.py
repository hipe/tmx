import os.path as os_path


def _normalize_sys_path():  # see [#019]
    from sys import path as a

    dn = os_path.dirname
    test_dir = dn(os_path.abspath(__file__))
    mono_repo_dir = dn(test_dir)

    if test_dir == a[0]:
        # IF this then this is a [#019.test-run-type-C], i.e the topmost
        # test directory was the argument path.

        # as far as we know, such circumstance is the *only* circumstance
        # under which this subject file is loaded.

        if mono_repo_dir != a[1]:  # (unittest must do this? why?)
            raise Exception('hello')

        # simply SWAP THEM, so that sys.path looks normalized
        a[0] = mono_repo_dir
        a[1] = test_dir

    elif mono_repo_dir == a[0]:
        # this file was loaded by a lower same-named file
        # that wants its resources
        pass

    assert(mono_repo_dir == a[0])

    return test_dir


_top_test_dir = _normalize_sys_path()


def lazy(f):  # #meh
    def redefined_f():
        return use_f()

    def use_f():
        x = f()
        nonlocal use_f

        def use_f():
            return x
        return x

    return redefined_f


def fixture_directory_path(stem):
    return os_path.join(fixture_directories_path(), stem)


@lazy
def fixture_directories_path():
    return os_path.join(_top_test_dir, 'fixture-directories')

# #born.
