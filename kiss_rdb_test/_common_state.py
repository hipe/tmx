import os.path as os_path


def _normalize_sys_path():  # see [#019]
    from sys import path as a

    dn = os_path.dirname
    test_dir = dn(os_path.abspath(__file__))
    mono_repo_dir = dn(test_dir)

    if test_dir == a[0]:
        # the topmost test directory was the argument path (type C)

        assert(mono_repo_dir == a[1])  # `py -m unittest discover` probably

        # swap them so sys.path advertises that it is normalized
        a[0] = mono_repo_dir
        a[1] = test_dir

    elif mono_repo_dir == a[0]:
        # file was loaded by a lower same-named file that wants its resources
        pass
    else:
        # either sub-unit is being run or a test file is loading us the new way
        assert(0 == a[0].index(test_dir))

        if mono_repo_dir == a[1]:  # sub-unit
            # swap them so sys.path advertises that it is normalized
            a[1] = a[0]  # keep the deep test module so other tests can load
            a[0] = mono_repo_dir
        else:
            # single file is being run, loaded this the the new way. clobber
            a[0] = mono_repo_dir

        # (this branch added at #history-A.1)

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


def pretend_file_via_path_and_big_string(path, big_string):
    return PretendFile(unindent(big_string), path)


class PretendFile:

    def __init__(self, lines, path):
        self._lines = lines
        self.path = path

    def __enter__(self):
        x = self._lines
        del self._lines
        return x

    def __exit__(self, typ, err, stack):
        pass


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

    from script_lib.test_support import unindent

    itr = unindent(big_s)
    for line in itr:  # once
        assert('.\n' == line)
        break
    return itr


def unindent(big_string):
    # #[#008.I]
    from script_lib.test_support import unindent
    return unindent(big_string)


def debugging_listener():
    from modality_agnostic.test_support import structured_emission as se_lib
    return se_lib.debugging_listener()


def fixture_directory_path(stem):
    return os_path.join(fixture_directories_path(), stem)


@lazy
def fixture_directories_path():
    return os_path.join(_top_test_dir, 'fixture-directories')

# #history-A.1
# #born.
