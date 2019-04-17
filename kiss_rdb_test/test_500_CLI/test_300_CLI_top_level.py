from _common_state import (
        fixture_directories_path,
        unindent as _unindent,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
from script_lib.test_support import expect_STDs as es
import unittest


"""GENERAL DISCUSSION of this test file

on stdout capture support :[#817]: :#here2:

  - this identifier marks a spot in the support library where is described
    the component architecture from which IO facades (test spies) can be made.
  - here we do a lot of gross bandaid code to accommodate the fact that Click
    is not made testing friendly #[#867.L]
  - here we do our own highly experimental construction of a write-only IO
    listener as proposed in the aforementioned support file.
  - here we have an interface for turning on the debugging form of this
  - any/all of the above will be abstracted when appropriate


on the test case number allocation here:

  - originally in [#868], CLI was allocated the number range ~"790-799 lol"
  - we expect to want more cases than that but hope we don't need much more
  - 50 is a nice round number
  - so for now we'll allocate ourselves the numberspace 790-839 (50 count)
  - we start with an item count of FIVE: TR-CDU
    (that's CRUD plus traverse, in [#010.6] regression-friendly order) PLUS:
  - one more for unforseen housekeeping & setup (the equivalent of USE,
    maybe of `CREATE DATABASE` etc..) so SIX but PLUS:
  - for now we'll stake ONE placeholder item in there for some kind of
    query thing but A) this should explode and B) this precedes the
    "modality" layer, mostly (i.e it's not a CLI thing, mainly) so SEVEN:
  - `${tmx subdivide} 790:839:7` gives us all the case numbers that appear here
  - NOTE *all* these cases are "the CLI adaptation of..". abstract later.
"""


class _CommonCase(unittest.TestCase):

    def expect_requires_these_particular_arguments(self, *expect_these):

        # #here1
        import re
        _line = self.command_help_screen().usage_line
        md = re.match(r'^Usage: ohai-mami ([a-z]+) \[OPTIONS\] (.+)$', _line)
        first, *actual_these = md[2].split(' ')

        # every one of these commands requires the collection (name)
        self.assertEqual(first, 'COLLECTION')

        # assert the zero or more other arguments that are required
        self.assertSequenceEqual(actual_these, expect_these)

    def expect_this_string_in_first_line_of_description(self, s):
        _line = self.command_help_screen().first_description_line
        self.assertIn(s, _line)

    def build_command_help_screen_subtree(self):
        lines, e = self._expect_common('stdout', 'system exit')
        self.assertEqual(e.code, _success_exit_code)
        assert('\n' == lines[1])  # meh
        return _StructUsageLineAndFirstDescLine(lines[0], lines[2])

    def apparently_just_prints_entire_help_screen(self):

        # #open [#867.L] the fact that exit_code=0 is an annoying thing from..
        lines, e = self._expect_common('stdout', 'system exit')
        self.assertEqual(e.code, _success_exit_code)

        # emits same generic message (near #here1)
        self.assertTrue('Usage:' in lines[0])

        # several lines
        self.assertTrue(3 < len(lines))

    def _expect_exit_code_for_bad_request(self):
        self.expect_exit_code(400)

    def expect_exit_code(self, which):
        self.assertEqual(self._end_state().exception.exit_code, which)

    def expect_exit_code_is_the_success_exit_code(self):
        self.assertEqual(self._end_state().exit_code, _success_exit_code)

    def _expect_common(self, which_IO, which_e):
        o = self._build_end_state(which_IO, which_e)
        lines = tuple(o.lines)  # it's a generator. flatten it now before etc
        return lines, o.exception

    def _build_end_state(self, which_IO, which_e):
        if 'stdout' == which_IO:
            yes_stdout = True
            yes_stderr = False
        elif 'stderr' == which_IO:
            yes_stdout = False
            yes_stderr = True
        elif 'stdout and stderr':
            yes_stdout = True
            yes_stderr = True

        return self.MY_BIG_FLEX(
                allow_stdout_lines=yes_stdout,
                allow_stderr_lines=yes_stderr,
                exception_category=which_e,
                )

    def _build_end_state_FOR_DEBUGGING(self, exe_cat='anything experiment'):

        o = self.MY_BIG_FLEX(
                allow_stdout_lines=True,
                allow_stderr_lines=True,
                exception_category=exe_cat,
                )

        if hasattr(o, 'exception'):
            e = o.exception
            print(f'WAS EXCEPTION: {type(e)} {str(e)}')

        if hasattr(o, 'filesystem_recordings'):
            a = o.filesystem_recordings
            if a is not None:
                print(f'HAD NUM RECORDINGS: {len(a)}')

        for line in o.lines:
            cover_me('hi')
        cover_me('hey')

    def MY_BIG_FLEX(
            self,
            allow_stdout_lines,
            allow_stderr_lines,
            exception_category):

        fs = self.filesystem()
        if fs is None:
            injections_dict = None
        else:
            injections_dict = {
                    'filesystem': fs,
                    'random_number': self.random_number(),
                    }

        return BIG_FLEX(
            given_args=self.given_args(),
            allow_stdout_lines=allow_stdout_lines,
            allow_stderr_lines=allow_stderr_lines,
            exception_category=exception_category,
            injections_dictionary=injections_dict,
            might_debug=self.might_debug,
            do_debug_f=lambda: self.do_debug,
            debug_IO_f=lambda: _sys().stderr,
            )

    def random_number(self):
        return None

    def filesystem(self):
        return None

    do_debug = False
    """turn on/off debugging output for the invocation of CLI commands.

    ALL of these behaviors require that `might_debug` (next) be True.

    so:
      - turn debugging on for all the tests in this file by
        setting the value to True here

      - turn debugging on for one particular test case by
        overriding the property and setting it to true in that case (class)

      - turn debugging on for one particular *test* by
        setting the property to true on the test context instance
        at the beginning of the test (method).

      - debugging can be turned on/off "momentarily" any time during the
        invocation of the test (but depending on your requirements you
        may need to code something fancy)

    (part of #here2)
    """

    might_debug = False
    """
    EXPERIMENTAL: on the one hand you can think of this as a nasty
    optimization, but on the other hand we see it as a coarse exercising of
    our dependency injection as described at #here2
    """


class Case791_no_args(_CommonCase):

    def test_100_just_prints_entire_help_screen(self):
        self.apparently_just_prints_entire_help_screen()

    def given_args(self):
        return ()


class Case792_strange_arg(_CommonCase):

    def test_100_throws_a_usage_error(self):
        self.assertEqual(self._exe().exit_code, 2)  # meh

    def test_200_whines_with_this_message(self):
        _msg = self._exe().message
        self.assertEqual(_msg, 'No such command "foo-fah-fee".')

    @shared_subject
    def _exe(self):
        lines, e = self._expect_common('stdout', 'usage error')
        self.assertEqual(len(lines), 0)
        return e

    def given_args(self):
        return ('foo-fah-fee',)


class Case794_strange_option(_CommonCase):

    def test_100_just_prints_entire_help_screen(self):
        self.apparently_just_prints_entire_help_screen()

    def given_args(self):
        return ('--cho-monculous')


class Case795_toplevel_help_in_general(_CommonCase):

    def test_100_exit_code_is_whatever(self):
        self.assertEqual(_CASE_A().exit_code, _success_exit_code)

    def test_200_usage_section(self):
        # (abstract this ofc, if we ever really wanted to. #here1)
        import re
        _line_obj = _CASE_A().tree.children[0]
        _line = _line_obj.styled_content_string
        _head = re.match(r'^(.+)\.\.\.$', _line)[1]  # ends in ellipses
        _mid = re.match(r'^Usage: [-a-z]+ (.+)$', _head)[1]  # begins w this
        _ok = re.match(r'^[\[\]A-Z\. ]+$', _mid)  # mid looks like this
        self.assertIsNotNone(_ok)

    def test_300_options_section(self):
        _section = _CASE_A().tree.children[1]
        first, *rest = _section.children

        # the title of this section is something like "options"
        self.assertEqual(first.styled_content_string, 'Options:')

        # the last item in the list of options is the self-referential one
        _actual = rest[0].children[-1].styled_content_string
        self.assertRegex(
                _actual,
                r'^--help[ ]+Show this message and exit\.$')

        # there are no other items
        self.assertEqual(len(rest), 1)


class Case796_toplevel_help_plus_argument(_CommonCase):

    def test_100_just_prints_entire_help_screen(self):
        self.apparently_just_prints_entire_help_screen()

    def given_args(self):
        return ('--help', 'fah-foo')


# Case797_help_screen_for_use_hub_or_something

# Case798_help_screen_for_create_hub_or_something


class Case799_help_screen_for_traverse(_CommonCase):

    def test_100_expect_requires_these_particular_arguments(self):
        self.expect_requires_these_particular_arguments()

    def test_200_expect_this_string_in_first_line_of_description(self):
        self.expect_this_string_in_first_line_of_description(
                'traverse the collection of entities')

    @shared_subject
    def command_help_screen(self):
        return self.build_command_help_screen_subtree()

    def given_args(self):
        return ('traverse', '--help')


"""DO:
    - trav no hub
    - trav bad col
    - trav good col
"""


class Case802_touch_error_message_integration(_CommonCase):

    def test_100_generic_failure_exit_status(self):
        self.expect_exit_code(2)  # FileNotFoundError.errno

    def test_200_message_lines(self):
        _actual, = self._end_state().lines
        reason, path = _actual.split(' - ')
        self.assertEqual(reason, 'collection does not exist because no schema file')  # noqa: E501
        self.assertEqual(path, 'qq/pp/schema.toml\n')

    @shared_subject
    def _end_state(self):
        return self._build_end_state('stderr', 'click exception')

    def given_args(self):
        return ('--collections-hub', 'qq', 'traverse', 'pp')


class Case804_traverse(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_lines_look_like_internal_identifiers(self):
        lines = tuple(self._end_state().lines)
        self.assertIn(len(lines), range(7, 10))
        import re
        rx = re.compile('^[A-Z0-9]{3}\n$')
        for line in lines:
            assert(rx.match(line))

    @shared_subject
    def _end_state(self):
        return self._build_end_state('stdout', None)

    def given_args(self):
        return (*_common_head(), 'traverse', _common_collection)


class Case807_help_screen_for_select(_CommonCase):

    def test_100_expect_requires_these_particular_arguments(self):
        self.expect_requires_these_particular_arguments()

    def test_200_expect_this_string_in_first_line_of_description(self):
        self.expect_this_string_in_first_line_of_description(
                'sorta like the SQL command')

    @shared_subject
    def command_help_screen(self):
        return self.build_command_help_screen_subtree()

    def given_args(self):
        return ('select', '--help')


class Case808_help_screen_for_get(_CommonCase):

    def test_100_expect_requires_these_particular_arguments(self):
        self.expect_requires_these_particular_arguments(_IID)

    def test_200_expect_this_string_in_first_line_of_description(self):
        self.expect_this_string_in_first_line_of_description(
                'retrieve the entity from the collection')

    @shared_subject
    def command_help_screen(self):
        return self.build_command_help_screen_subtree()

    def given_args(self):
        return ('get', '--help')


# Case809_get_no_ent_bad_identifier - says so
# Case810_get_no_ent_no_dir - hopefully says no such file
# Case811_get_no_ent_no_file - says no such directory


class Case812_get_no_ent_in_file(_CommonCase):

    def test_100_exit_code_is_404_lol(self):
        self.assertEqual(self._end_state().exception.exit_code, 404)

    def test_200_says_only_not_found__with_ID(self):
        line, = self._end_state().lines
        self.assertEqual(line, "'B9F' not found\n")

    @shared_subject
    def _end_state(self):
        return self._build_end_state('stderr', 'click exception')

    def given_args(self):
        return (*_common_head(), 'get', _common_collection, 'B9F')


class Case813_get(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_lines_wow(self):
        lines = self._end_state().lines
        _actual_big_string = ''.join(lines)  # correct an issue todo
        _actual_lines = tuple(_lines_via_big_string_as_is(_actual_big_string))

        _expect_big_s = """
        {
          "identifier_string": "B9H",
          "SIMPLE_AND_IMMEDIATE_ATTRIBUTES": {
            "thing-A": "hi H",
            "thing-B": "hey H"
          }
        }
        """

        _expect_lines = tuple(_unindent(_expect_big_s))
        self.assertSequenceEqual(_actual_lines, _expect_lines)

    @shared_subject
    def _end_state(self):
        return self._build_end_state('stdout', None)

    def given_args(self):
        return (*_common_head(), 'get', _common_collection, 'B9H')


class Case815_help_screen_for_create(_CommonCase):

    def test_100_expect_requires_these_particular_arguments(self):
        self.expect_requires_these_particular_arguments()

    def test_200_expect_this_string_in_first_line_of_description(self):
        self.expect_this_string_in_first_line_of_description(
                'create a new entity in the collection')

    @shared_subject
    def command_help_screen(self):
        return self.build_command_help_screen_subtree()

    def given_args(self):
        return ('create', '--help')


class Case816_create_without_attrs(_CommonCase):

    def test_100_exit_code_reflects_failure(self):
        self._expect_exit_code_for_bad_request()

    def test_200_reason(self):
        line, = self._end_state().lines
        self.assertEqual(line, 'request was empty\n')

    @shared_subject
    def _end_state(self):
        return self._build_end_state('stderr', 'click exception')

    def given_args(self):
        return (*_common_head(), 'create', _common_collection)

    def filesystem(self):
        return None


class Case819_create(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_stdout_lines_are_toml_lines_of_created_fellow(self):

        def assert_stdout(which, line):
            self.assertEqual(which, 'sout')
            return line

        ql = self._qualified_lines()
        _actual = tuple(assert_stdout(which, line) for which, line in ql[1:])

        """currently what is written to stdout on successful create is simply
        the same lines of the mutable document entity that were inserted into
        this entities file.

        contrast this with what RETRIEVE (Case711) does, which is to express
        to the user the retrieved entity as *json* (not toml).

        to have these two operations behave differently in this regard is
        perhaps a violation of "the principle of least astonishment"; but
        we uphold this inconsistency (for now) on these grounds:

        - the founding purpose of the CLI is towards a crude, quick-and-dirty
          debugging & development tool; not to be pretty & perfect (yet).

        - there is arguably one UI/UX benefit to the current way: when storing
          as opposed to retrieving, the user wants visual confirmation that
          nothing strange happened in encoding their "deep" data into a
          surface representation for this particular datastore.
        """

        _expected = tuple(_unindent("""
        [item.2H3.attributes]
        aa = "AA"
        bb = "BB"
        """))

        self.assertSequenceEqual(_actual, _expected)

    def test_300_serr_line_is_decorative(self):
        which, line = self._qualified_lines()[0]
        self.assertEqual(which, 'serr')
        self.assertEqual(line, 'created:\n')

    @shared_subject
    def _qualified_lines(self):
        return tuple(self._end_state().lines)

    @shared_subject
    def _end_state(self):
        return self._build_end_state('stdout and stderr', None)

    def given_args(self):
        return (*_common_head(), 'create', _common_collection,
                '-val', 'aa', 'AA', '-val', 'bb', 'BB')

    def filesystem(self):
        return _build_filesystem_expecting_num_file_rewrites(2)

    def random_number(self):
        return 481  # kiss ID 2H3 is base 10 481


class Case822_help_screen_for_delete(_CommonCase):

    def test_100_expect_requires_these_particular_arguments(self):
        self.expect_requires_these_particular_arguments(_IID)

    def test_200_expect_this_string_in_first_line_of_description(self):
        self.expect_this_string_in_first_line_of_description(
                'delete the entity from the collection')

    @shared_subject
    def command_help_screen(self):
        return self.build_command_help_screen_subtree()

    def given_args(self):
        return ('delete', '--help')


class Case829_help_screen_for_update(_CommonCase):

    def test_100_expect_requires_these_particular_arguments(self):
        self.expect_requires_these_particular_arguments(_IID)

    def test_200_expect_this_string_in_first_line_of_description(self):
        self.expect_this_string_in_first_line_of_description(
                'update the entity in the collection')

    @shared_subject
    def command_help_screen(self):
        return self.build_command_help_screen_subtree()

    def given_args(self):
        return ('update', '--help')


class Case836_help_screen_for_search(_CommonCase):

    def test_100_expect_requires_these_particular_arguments(self):
        self.expect_requires_these_particular_arguments()

    def test_200_expect_this_string_in_first_line_of_description(self):
        self.expect_this_string_in_first_line_of_description(
                'WARNING may merge with select')

    @shared_subject
    def command_help_screen(self):
        return self.build_command_help_screen_subtree()

    def given_args(self):
        return ('search', '--help')


@memoize
def _CASE_A():  # usually it's one invocation
    o = BIG_FLEX(
            given_args=('--help',),
            allow_stdout_lines=True,
            allow_stderr_lines=False,
            exception_category='system exit',
            injections_dictionary=None,
            might_debug=False,  # ..
            do_debug_f=lambda: False,  # ..
            debug_IO_f=lambda: _sys().stderr,
            )
    return _StructTreeAndExitCode(_tree_via_lines(o.lines), o.exception.code)


class _StructUsageLineAndFirstDescLine:
    def __init__(self, *two):
        self.usage_line, self.first_description_line = two


class _StructTreeAndExitCode:
    def __init__(self, *two):
        self.tree, self.exit_code = two


# == BEGIN stdout capture and support #here2

def BIG_FLEX(
        given_args,
        allow_stdout_lines,
        allow_stderr_lines,
        exception_category,
        injections_dictionary,
        might_debug,
        do_debug_f,
        debug_IO_f,
        ):

    mixed_writes = []
    is_complicated = False

    if allow_stdout_lines:
        if allow_stderr_lines:
            is_complicated = True

            def receive_sout_write(s):
                mixed_writes.append(('sout', s))

            def receive_serr_write(s):
                mixed_writes.append(('serr', s))
            out_WR = _write_receiver_via_function(receive_sout_write)
            err_WR = _write_receiver_via_function(receive_serr_write)
        else:
            def receive_sout_write(s):
                mixed_writes.append(s)
            out_WR = _write_receiver_via_function(receive_sout_write)
            err_WR = _no_WR
    else:
        def receive_serr_write(s):
            mixed_writes.append(s)
        out_WR = _no_WR
        err_WR = _write_receiver_via_function(receive_serr_write)

    if might_debug:
        _odwr = es.DebuggingWriteReceiver('sout', do_debug_f, debug_IO_f)
        _edwr = es.DebuggingWriteReceiver('serr', do_debug_f, debug_IO_f)
        out_WR = es.MuxingWriteReceiver((_odwr, out_WR))
        err_WR = es.MuxingWriteReceiver((_edwr, err_WR))

    def invoke_CLI():
        return _invoke_CLI(given_args, injections_dictionary)

    def clean_up_writes():
        if is_complicated:
            return __clean_up_writes_complicatedly(mixed_writes)
        return __lines_via_writes(mixed_writes)

    if exception_category is None:

        with OPEN_HORRIBLE_VENDOR_HACK(out_WR, err_WR):
            fs_finish, exit_code = invoke_CLI()

        if fs_finish is None:
            fsr = None
        else:
            fsr = fs_finish()

        _lines = clean_up_writes()
        return _BigFlexEndStateWithLala(
                filesystem_recordings=fsr,
                lines=_lines,
                exit_code=exit_code)

    def these(s):
        if 'click exception' == s:
            yield ce('ClickException')
        elif 'system exit' == s:
            yield SystemExit
        elif 'usage error' == s:
            yield ce('UsageError')
        elif 'anything experiment' == s:
            yield ce('ClickException')
            yield ce('UsageError')
            yield SystemExit
        else:
            cover_me(f'uncoded for exception category: {s}')

    def ce(s):  # ce="click exception"
        import click.exceptions as _
        return getattr(_, s)

    _exception_class_expression = tuple(these(exception_category))

    try:
        with OPEN_HORRIBLE_VENDOR_HACK(out_WR, err_WR):
            invoke_CLI()
            raise Exception('never see')
    except _exception_class_expression as e_:
        e = e_

    _ = clean_up_writes()
    return _BigFlexEndStateWithException(_, e)


class _BigFlexEndStateWithException:
    def __init__(self, lines, e):
        self.lines = lines
        self.exception = e


class _BigFlexEndStateWithLala:
    def __init__(self, filesystem_recordings, lines, exit_code):
        self.filesystem_recordings = filesystem_recordings
        self.lines = lines
        self.exit_code = exit_code


def _write_receiver_via_function(receive_write):
    return es.ProxyingWriteReceiver(receive_write)


def _expecting_no_emissions(x):
    assert(False)


_no_WR = _write_receiver_via_function(_expecting_no_emissions)


def _invoke_CLI(given_args, injections_dictionary):

    from kiss_rdb.magnetics_.collection_via_directory import (
            INJECTIONS as INJECTIONS)

    from kiss_rdb.cli import cli

    _NASTY_HACK_once()

    if injections_dictionary is None:
        injections_obj = None
        filesystem_finish = None
    else:
        random_number, filesystem = __flatten_these(**injections_dictionary)
        _random_number_generator = __rng_via(random_number)
        filesystemer, filesystem_finish = __these_two_via_filesystem(filesystem)  # noqa: E501

        injections_obj = INJECTIONS(
                random_number_generator=_random_number_generator,
                filesystemer=filesystemer)

    _exit_code = cli.main(
                args=given_args,
                prog_name='ohai-mami',
                standalone_mode=False,  # see.
                complete_var='___hope_this_env_var_is_never_set',
                obj=injections_obj,
            )

    return filesystem_finish, _exit_code


@memoize
def _NASTY_HACK_once():
    # OCD for tests (this is a common OCD we run into when testing CLI):
    # don't ever parse the same schema file more than once

    from kiss_rdb.magnetics_ import schema_via_file_lines as mod

    real_function = mod.SCHEMA_VIA_COLLECTION_PATH

    cache = {}

    def use_function(path, listener):

        if path in cache:
            print(f'USING cached fellow for {path}')
            return cache[path]

        print(f'MAKING cached fellow for {path}')
        res = real_function(path, listener)
        cache[path] = res
        return res

    mod.SCHEMA_VIA_COLLECTION_PATH = use_function


def __rng_via(random_number):
    if random_number is None:
        return

    def random_number_generator(pool_size):
        return random_number
    return random_number_generator


def __these_two_via_filesystem(filesystem):
    if filesystem is None:
        return (None, None)

    def filesystem_finish():
        return filesystem.FINISH_AS_HACKY_SPY()

    def filesystemer():
        return filesystem

    return filesystemer, filesystem_finish


def __flatten_these(random_number, filesystem):
    return random_number, filesystem


def OPEN_HORRIBLE_VENDOR_HACK(sout_write_receiver, serr_write_receiver):
    """.#open [#867.L] this so bad:

    click is not written to be test-friendly in any injection-sense, so
    we have to awfully, hackishly rewrite these functions to be other
    functions, and then (for each invocation under test) pop things back
    into place and hope our execution context works alright and hope that
    this doesn't break actual CLI that's being used during the running of
    tests. so bad.

    also:
      - don't let the "default" in the name fool you below.
    """

    from click import utils as EEK_click_utils

    sout_iof = es.Write_Only_IO_Facade(sout_write_receiver)
    serr_iof = es.Write_Only_IO_Facade(serr_write_receiver)

    dtso = getattr(EEK_click_utils, '_default_text_stdout')
    dtse = getattr(EEK_click_utils, '_default_text_stderr')

    setattr(EEK_click_utils, '_default_text_stdout', lambda: sout_iof)
    setattr(EEK_click_utils, '_default_text_stderr', lambda: serr_iof)

    def f():
        setattr(EEK_click_utils, '_default_text_stdout', dtso)
        setattr(EEK_click_utils, '_default_text_stderr', dtse)

    return _Ensure(f)


class _Ensure:

    def __init__(self, f):
        self._function = f

    def __enter__(self):
        # we could have put set-up code here, but why?
        pass

    def __exit__(self, _, _2, _3):
        f = self._function
        del self._function
        f()


def _tree_via_lines(lines):
    from script_lib.test_support.expect_treelike_screen import (
            tree_via_line_stream as _)
    return _(lines)


def __clean_up_writes_complicatedly(writes):
    if not len(writes):
        return ()

    for which, big_s in writes:
        for line in _lines_via_big_string_as_is(big_s):
            yield which, line


def __lines_via_writes(writes):
    """DISCUSSION

    we tried this with the equivalent of `re.split('(?<=\n)', write)` but
    that adds a trailing *empty* string
    """

    for write in writes:
        for line in _lines_via_big_string_as_is(write):
            yield line


def _sys():
    import sys as _
    return _


# == END support for stdout capture


def _lines_via_big_string_as_is(big_string):
    from script_lib.test_support.expect_treelike_screen import (
            line_stream_via_big_string as _)
    return _(big_string)


# == support for setup

def _common_head():
    return '--collections-hub', fixture_directories_path()


def _build_filesystem_expecting_num_file_rewrites(expected_num):
    return _fs_lib().build_filesystem_expecting_num_file_rewrites(expected_num)


def _fs_lib():
    from kiss_rdb_test import filesystem_spy as _
    return _


# == general

def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_common_collection = '050-rumspringa'
_IID = 'INTERNAL_IDENTIFIER'

_success_exit_code = 0

if __name__ == '__main__':
    unittest.main()

# #born.
