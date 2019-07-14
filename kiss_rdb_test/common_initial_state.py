import os.path as os_path




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
    import kiss_rdb.storage_adapters_.toml.entities_via_collection as ents_lib
    _tb = ents_lib.table_block_via_lines_and_table_start_line_object_(
            lines, tslo, listener)
    return _tb.to_mutable_document_entity_(listener)


def TSLO_via(identifier_string, meta_or_attributes):
    import kiss_rdb.storage_adapters_.toml.identifiers_via_file_lines as lib
    return lib.TSLO_via(identifier_string, meta_or_attributes)


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


def _make_functions_for():
    def functions_for(who):
        if who in cache:
            return cache[who]
        if 'toml' == who:
            res = _functions_for_toml()
        else:
            raise Exception(f"add functions for '{who}'")
        cache[who] = res
        return res
    cache = {}
    return functions_for


functions_for = _make_functions_for()


class _functions_for_toml:

    def __init__(self):
        self.fixture_dir_name = '4219-toml'
        self._ca_head = None
        self._fd_path = None

    def common_args_head(self):
        if self._ca_head is None:
            _ = self.fixture_directories_path()
            self._ca_head = ('--collections-hub', _)
        return self._ca_head

    def fixture_directory_path(self, tail):
        return os_path.join(self.fixture_directories_path(), tail)

    def fixture_directories_path(self):
        if self._fd_path is None:
            self._fd_path = os_path.join(
                    fixture_directories_path(), self.fixture_dir_name)
        return self._fd_path


@lazy
def fixture_directories_path():
    return os_path.join(_top_test_dir, 'fixture-directories')

# #history-A.1
# #born.
