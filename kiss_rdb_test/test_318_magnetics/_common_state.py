def _normalize_sys_path():  # see [#019]
    from sys import path as a
    from os import path

    dn = path.dirname
    test_sub_dir = dn(path.abspath(__file__))
    test_dir = dn(test_sub_dir)
    mono_repo_dir = dn(test_dir)

    if test_sub_dir == a[0]:
        if mono_repo_dir == a[1]:

            # THEN we call this [#019.test-run-type-B], which is to say:
            # we are doing "unittest discover" AND
            # our immediate parent dir was the argument.

            # in order for sys.path to be recognized as having been normalized,
            # the mono repo dir must be the first element
            a[0] = mono_repo_dir

            # for sys.path to be truly normal we would want it to be like this:
            # a[1] = test_dir
            # but we can't because unittest expects our immediate parent dir
            # to be there so it can load sibling test files (modules).

            # so for now, this (but later my have to elaborate):
            a[1] = test_sub_dir
        else:
            # ELSE a plain old test file is being executed in standalone
            # (which we call [#019.test-run-type-A])

            a[0] = mono_repo_dir  # CLOBBER
            # (this means subsequent imports of subject file would fail)

    else:
        raise Exception('hello')


_normalize_sys_path()


from kiss_rdb_test import _common_state as _  # noqa: E402
import sys  # noqa: E402
sys.modules[__name__] = _

# #history: receive transplant of "unindent with dot hack"
# #born.
