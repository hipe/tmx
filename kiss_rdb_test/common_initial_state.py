from modality_agnostic.test_support.common import memoize_into
import os.path as os_path


class OneWriteReference:  # :[#510.5] (again)
    def __init__(self):
        self._is_first_call = True

    def receive_value(self, x):
        assert(self._is_first_call)
        self._is_first_call = False
        self.value = x


def lazy(f):  # #[#510.8]
    class EvaluateLazily:
        def __init__(self):
            self._has_been_evaluated = False

        def __call__(self):
            if not self._has_been_evaluated:
                self._has_been_evaluated = True
                self._value = f()
            return self._value
    return EvaluateLazily()


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
    return pretend_file_via_path_and_lines(path, unindent(big_string))


class pretend_file_via_path_and_lines:  # :[#877.B] #[#504.8]
    # (LIKE [#510.12] pass-thru etc but plus a `path` param)
    # if you find yourself wishing it had a path property, unify with [#877.C]

    def __init__(self, path, lines):
        self._lines = lines
        self.path = path

    def __enter__(self):
        x = self._lines
        del self._lines
        return x

    def __exit__(self, typ, err, stack):
        pass

    def release_lines__(self):
        rv = self._lines
        del self._lines
        return rv


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
    import modality_agnostic.test_support.common as em
    return em.debugging_listener()


# == Load Fixtures

def publicly_shared_fixture_file(which):
    assert(_this == which)
    return functions_for('markdown').fixture_path(_this)


_this = '0100-hello.md'


def __make_functions_for():
    def functions_for(key):
        if key not in cache:
            cache[key] = _these_classes[key]()
        return cache[key]
    cache = {}
    return functions_for


functions_for = __make_functions_for()


def _path_for(self, tail):
    _ = self.fixture_directories_directory
    return os_path.join(_, tail)


class _FunctionsFor:

    @memoize_into('_ca_head')
    def common_args_head(self):
        _ = self.fixture_directories_directory
        return ('--collections-hub', _)

    @property
    @memoize_into('_fdd')
    def fixture_directories_directory(self):
        _ = top_fixture_directories_directory()
        return os_path.join(_, self.fixture_dir_name)


def o(k):
    def decorator(cls):
        _these_classes[k] = cls
        return cls
    return decorator


_these_classes = {}


@o('eno')
class ___funcs_for_eno(_FunctionsFor):
    fixture_directory_for = _path_for
    fixture_dir_name = '4844-eno'


@o('google_sheets')
class ___funcs_for_google_sheets(_FunctionsFor):
    fixture_directory_for = _path_for
    fixture_dir_name = '4921-google-sheets'


@o('markdown')
class ___funcs_for_MD(_FunctionsFor):
    fixture_path = _path_for
    fixture_dir_name = '2656-markdown-table'


@o('toml')
class ___funcs_for_TOML(_FunctionsFor):
    fixture_directory_for = _path_for
    fixture_dir_name = '4219-toml'


@lazy
def top_fixture_directories_directory():
    return os_path.join(_top_test_dir(), 'fixture-directories')


@lazy
def _top_test_dir():
    return os_path.dirname(os_path.abspath(__file__))


# #history-A.1
# #born.
