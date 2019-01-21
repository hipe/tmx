def _normalize_sys_path():  # see [#019]
    from sys import path as a
    from os import path

    dn = path.dirname
    test_dir = dn(path.abspath(__file__))
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

    if mono_repo_dir != a[0]:
        raise Exception('sanity')


_normalize_sys_path()


# #born.
