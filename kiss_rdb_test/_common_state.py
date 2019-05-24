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
    else:
        raise Exception('when')

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


# ==


def MDE_via_lines_and_table_start_line_object(lines, tslo, listener):
    import kiss_rdb.magnetics_.entities_via_collection as ents_lib
    _tb = ents_lib.table_block_via_lines_and_table_start_line_object_(
            lines, tslo, listener)
    return _tb.to_mutable_document_entity_(listener)


def TSLO_via(identifier_string, meta_or_attributes):
    import kiss_rdb.magnetics_.identifiers_via_file_lines as ids_lib
    return ids_lib.TSLO_via(identifier_string, meta_or_attributes)


def unindent_with_dot_hack(big_s):
    """preserve meaningful leading space in a big string with this dot hack.

    in nature, the file-likes we typically test around begin with a non-space
    character, which enables our unindent function to infer how much to
    unindent the big string to "decode" it (from pretty to correct).

    however, in this project typical index files have meaningful indent
    on the first line (reasons). this hack enables us to have best of both.
    """

    if '' == big_s:
        return iter(())

    itr = unindent(big_s)
    for line in itr:  # once
        assert('.\n' == line)
        break
    return itr


def unindent(big_s):
    return _selib().unindent(big_s)


def debugging_listener():
    return _selib().debugging_listener()


def fixture_directory_path(stem):
    return os_path.join(fixture_directories_path(), stem)


@lazy
def fixture_directories_path():
    return os_path.join(_top_test_dir, 'fixture-directories')


def _selib():
    # from . import structured_emission as _  # breaks on pud why?
    from kiss_rdb_test import structured_emission as _
    return _


# #born.
