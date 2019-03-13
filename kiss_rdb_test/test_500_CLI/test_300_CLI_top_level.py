import _common_state  # noqa: F401
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
  - here we do a lot of gross bandaide code to accomdate the fact that Click
    is not made testing friendly
  - here we do our own highly experimental construction of a write-only IO
    listener as proposed in the aforementioned support file.
  - here we haev an interface for turning on the debugging form of this
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
        lines = tuple(self.stdout_lines_expecting_success())
        assert('\n' == lines[1])  # meh
        return _These_Two_B(lines[0], lines[2])

    def apparently_just_prints_entire_help_screen(self):

        # #open [#867.L] the fact that exit_code=0 is an annoying thing from..
        lines = tuple(self.stdout_lines_expecting_success())

        # emits same generic message (near #here1)
        self.assertTrue('Usage:' in lines[0])

        # several lines
        self.assertTrue(3 < len(lines))

    def stdout_lines_expecting_success(self):
        stdout_lines, exit_code = self._stdout_lines_and_exit_code()
        self.assertEqual(exit_code, 0)
        return stdout_lines

    def _stdout_lines_and_exit_code(self):
        return _stdout_lines_and_exit_code(
                given_args=self.given_args(),
                might_debug=self.might_debug,
                do_debug_f=lambda: self.do_debug,
                debug_IO_f=lambda: _sys().stderr,
                )

    do_debug = True
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
        self.assertIsNotNone(self._exe())

    def test_200_whines_with_this_message(self):
        _msg = str(self._exe())
        self.assertEqual(_msg, 'No such command "foo-fah-fee".')

    @shared_subject
    def _exe(self):
        try:
            self.stdout_lines_expecting_success()
        except _usage_error() as e_:
            e = e_
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
        self.assertEqual(_CASE_A().exit_code, 0)  # #open #[#867.L]

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

        # the first item in the list of options is the self-referential one
        self.assertEqual(
                rest[0].styled_content_string,
                '--help  Show this message and exit.')

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


class Case800_help_screen_for_select(_CommonCase):

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
    lines, ec = _stdout_lines_and_exit_code(
            given_args=('--help',),
            might_debug=False,  # ..
            do_debug_f=lambda: False,  # ..
            debug_IO_f=lambda: _sys().stderr,
            )
    return _These_Two_A(_tree_via_lines(lines), ec)


class _These_Two_A:
    def __init__(self, aa, bb):
        self.tree = aa
        self.exit_code = bb


class _These_Two_B:
    def __init__(self, aa, bb):
        self.usage_line = aa
        self.first_description_line = bb


# == BEGIN stdout capture and support #here2

def _stdout_lines_and_exit_code(given_args, might_debug, do_debug_f, debug_IO_f):  # noqa: E501
    _ = __build_invoke_CLI_function(given_args)
    ws, ec = __stdout_writes_and_exit_code_via_invoke(_, might_debug, do_debug_f, debug_IO_f)  # noqa: E501
    return __lines_via_writes(ws), ec


def __build_invoke_CLI_function(given_args):
    def f():
        from kiss_rdb.cli import cli
        _ = cli.main(
                args=given_args,
                prog_name='ohai-mami',
                standalone_mode=False,  # see.
                complete_var='___hope_this_env_var_is_never_set',
                )
        cover_me(f'neve been this far {type(_)}')
    return f


def __stdout_writes_and_exit_code_via_invoke(invoke_CLI, might_debug, do_debug_f, debug_IO_f):  # noqa: E501
    """experiment..."""

    writes = []
    receive_write = writes.append

    if might_debug:
        _pwr = es.ProxyingWriteReceiver(receive_write)
        _dwr = es.DebuggingWriteReceiver('sout', do_debug_f, debug_IO_f)
        wr = es.MuxingWriteReceiver((_dwr, _pwr))
    else:
        wr = es.ProxyingWriteReceiver(receive_write)

    try:
        with OPEN_HORRIBLE_VENDOR_HACK(wr):
            invoke_CLI()
    except SystemExit as e_:
        e = e_

    return writes, e.code


def OPEN_HORRIBLE_VENDOR_HACK(sout_write_receiver):
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

    dtso = getattr(EEK_click_utils, '_default_text_stdout')

    dtse = getattr(EEK_click_utils, '_default_text_stderr')

    setattr(EEK_click_utils, '_default_text_stdout', 'expect no call xyzz123')

    setattr(EEK_click_utils, '_default_text_stdout', lambda: sout_iof)

    def f():
        setattr(EEK_click_utils, '_default_text_stdout', dtso)

        setattr(EEK_click_utils, '_default_text_stdout', dtse)

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


def __lines_via_writes(writes):
    """DISCUSSION

    we tried this with the equivalent of `re.split('(?<=\n)', write)` but
    that adds a trailing *empty* string
    """

    from script_lib.test_support.expect_treelike_screen import (
            line_stream_via_big_string as lines_via_big)

    for write in writes:
        for line in lines_via_big(write):
            yield line


def _sys():
    import sys as _
    return _


# == END support for stdout capture


def _usage_error():
    from click.exceptions import UsageError as _
    return _


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_IID = 'INTERNAL_IDENTIFIER'

if __name__ == '__main__':
    unittest.main()

# #born.
