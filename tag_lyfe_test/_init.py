# #[#019.file-type-D]

import os.path as os_path


def _():
    dn = os_path.dirname
    import sys

    a = sys.path
    head = a[0]

    top_test_dir = dn(__file__)
    mono_repo_dir = dn(top_test_dir)

    if mono_repo_dir == head:

        pass  # assume low entrypoint loaded us to use for resources

    elif top_test_dir == head:

        # we get here when running `pud tag_lyfe_test`
        None if mono_repo_dir == a[1] else sanity()
        # at #history-A.1 the above changed from being '' to being the
        # project dir.

        # for some weird reason we want the one thing to be first and the
        # other thing to be second. but this might change

        # (the above history tag is sibling file 'query.py')

        a[0] = mono_repo_dir
        a[1] = top_test_dir  # [#019.why-this-in-the-second-position]

    else:
        sanity()

    return top_test_dir


def fixture_file_path(stem):
    return os_path.join(_top_test_dir, 'fixture-files', stem)


def sanity(s='assumption failed'):
    raise Exception(s)


_top_test_dir = _()


# #extracted from sibling
