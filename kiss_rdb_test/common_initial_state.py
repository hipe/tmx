from modality_agnostic.test_support.common import memoize_into, lazy
import os.path as os_path


class OneWriteReference:  # :[#510.5] (again)
    def __init__(self):
        self._is_first_call = True

    def receive_value(self, x):
        assert(self._is_first_call)
        self._is_first_call = False
        self.value = x


# == Business-y

def MDE_via_lines_and_table_start_line_object(lines, tslo, listener):
    import kiss_rdb.storage_adapters_.toml.entities_via_collection as ents_lib
    _tb = ents_lib.table_block_via_lines_and_table_start_line_object_(
            lines, tslo, listener)
    return _tb.to_mutable_document_entity_(listener)


def TSLO_via(identifier_string, meta_or_attributes):
    import kiss_rdb.storage_adapters_.toml.identifiers_via_file_lines as lib
    return lib.TSLO_via(identifier_string, meta_or_attributes)


@lazy
def didactic_collectioner():
    import kiss_rdb_test.fixture_code._1416_SAs._33_SAs as mod
    path = mod.__path__
    paths = path._path
    if 1 < len(paths):
        fs_path, = tuple(set(paths))  # assert they are all the same
    else:
        fs_path, = paths
    from kiss_rdb.magnetics_.collection_via_path import \
        collectioner_via_storage_adapters_module as func
    return func(path._name, fs_path)


# == Assertion support

def end_state_named_tuple(*attrs):  # #decorator
    # (This is the second writing of this. The first writing is somewhere in
    # some code added in the last week or two. This is a blind rewrite. We
    # aren't going to bother looking for the original now because of how
    # straightforwardly memorable this is, in terms of its input, its result,
    # and even its implementation (w/ namedtuple) AND SO how trivial it will
    # be to unify later. When the need emerges, put this in [ma] t.s. probably)

    """
    NOTE this does NOT memoize. Typically (but not necessarily), a memoizing
    decorator is seen above it.
    """

    def decorator(orig_f):
        def use_f(tc):
            values = orig_f(tc)
            if not ptr:
                ptr.append(build_class())
            return ptr[0](*values)
        return use_f

    def build_class():
        from collections import namedtuple as nt
        return nt('DerivedEndState', attrs)
    ptr = []
    return decorator


# == Pretend resources (performance support)

"""
Why and How

In production our line-based collection façades are built from either
pathnames or already-open file resources (e.g STDIN, STDOUT, an open file)

In tests we represent files in a number of other ways: big strings, tuples
of lines, generators of lines. (See more at md RDCU test file tagged [#507.11])

It's tempting to bend our [#857.D] flowchart to accomodate all these other
shapes but it's a smell to write production code (logic not structure)
to accomodate only test scenarios

In the very old days we had the concept of a "mock filesystem" we would
inject. Then this got simplified to be an overidden `open` function that
got injected (always called `opn`)

But: EXPERIMENTALLY new in the coming edition, when the façade builder is
passed what looks like an open filehandle, it's passed thru in a null
context manager and it's expected to read from it and (MAYBE) write to
it as appropriate without closing it

This newly supported argument type provides an easier, clearer way of
getting our fixture data in to the SUT. (We don't have to mock the "whole
filesystem" by implementing an `opn` function, we just pass in the mock
filehandle. (Still we use `opn` when we are testing with pathnames for
whatever reason.)

So, all this code-mess here is a mediation between all the different
ways we represent files in tests and the two ways we represent them in
production. (#[#873.26] whether and how we seek(0))


About the names

We use the word "pretend" to avoid the more stringent meanings associated
with "mock", "fake", "stub" (and "dummy"?), because this test double might
match those definitions to greater or lesser degrees based on what the
arguments are and how it's used. (We avoid the term "double" because we
find "pretend" to be more transparent and less ambiguous.)


Development & Future

There is ongoing tension between how much of this to abstract upwards.
We move new argument-handling routes up to the library package only as we
want them in other packages (at writing [dp])


A Small Note About Parameter Order

It may pain you that the agument order here is sometimes reverse what it is in
the library function (when it's (path, lines) here and there it's (lines, path)
but this inconsistency is by hard-fought design: in our test files it reads
better to have the pathname on top, before the lines, also when passing in
`opn` the lines argument becomes optional. However in the library file it is
the lines argument that's required and the pathname that is optional (e.g
when mocking STDIN).)
"""


def spy_on_write_and_lines_for(tc, debug_prefix):
    # (this pretend resource for capturing output is at top.
    # the rest in this sections are for mocking input)

    from script_lib.test_support.expect_STDs import \
        spy_on_write_and_lines_for as func
    return func(tc, debug_prefix, isatty=None)


def pretend_resource_and_controller_via_KV_pairs(itr):
    k, f = next(itr)
    assert 'pretend_file' == k
    dct = {k: v for layer in (f(), itr) for k, v in layer}
    dct['lines'] = _lines_via_big_string(dct.pop('big_string'))
    return _pretend_resource(**dct)


def _pretend_resource_via_mixed(x):
    typ = type(x).__name__
    if 'dct' == typ:
        return _pretend_resource(**x)
    if 'tuple' == typ:
        if 2 == len(x) and '\n' not in x[0]:  # 😢
            return _pretend_resource_via_two(*x)
        return _pretend_resource(iter(x), f"{__file__}:xyzz1")
    if 'str' == typ:
        return _pretend_resource_via_string(x)


pretend_resource_and_controller_via_mixed = _pretend_resource_via_mixed


def _pretend_resource_via_two(pretend_path, x):

    typ = type(x).__name__
    if 'str' == typ:
        itr = _lines_via_big_string(x)
    elif 'generator' == typ:
        itr = x
    else:
        raise RuntimeError(f"easy for you my friend: '{typ}'")
    return _pretend_resource(itr, pretend_path)


def _pretend_resource_via_string(x):
    if '\n' in x:
        raise RuntimeError("easy for you my friend, have fun")

    # façader will open and close it as a real filesystem file
    return x, None  # #here1


def _lines_via_big_string(big_string):
    from .common_initial_state import unindent as func
    return func(big_string)


def _pretend_resource(lines, pretend_path, expect_num_rewinds=None, **kw):
    # The fork-in-the-road (we might push up): controller or no controller
    # based on the presence of one option

    assert hasattr(lines, '__next__')  # [#022]
    if expect_num_rewinds is None:
        fh = fake_file_via_path_and_lines(pretend_path, lines, **kw)
        return fh, None  # #here1
    from modality_agnostic.test_support.mock_filehandle import \
        mock_filehandle_and_mutable_controller_via as func
    return func(expect_num_rewinds, lines, pretend_path=pretend_path, **kw)


def fake_file_via_path_and_big_string(path, big_string):
    return fake_file_via_path_and_lines(path, unindent(big_string))


def fake_file_via_path_and_lines(path, lines, **kw):
    if isinstance(lines, tuple):
        lines = iter(lines)
    from modality_agnostic.test_support.mock_filehandle import \
        mock_filehandle as func
    return func(lines, path, **kw)


# ==


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

    unindent = _load_unindent()

    itr = unindent(big_s)
    for line in itr:  # once
        assert('.\n' == line)
        break
    return itr


def unindent(big_string):
    # #[#008.I]
    return _load_unindent()(big_string)


def _load_unindent():
    from text_lib.magnetics.via_words import unindent
    return unindent


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
