from _common_state import (
        unindent,
        )
from kiss_rdb_test import CLI as CLI_support
from kiss_rdb_test.CLI import (
    common_args_head,
    build_filesystem_expecting_num_file_rewrites,
    )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


"""GENERAL DISCUSSION of this test file

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


(:#here2: is [#817] (our main test support module)
"""


class _CommonCase(CLI_support.CLI_Test_Case_Methods, unittest.TestCase):

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

    def _expect_common(self, which_IO, which_e):
        o = self.build_end_state(which_IO, which_e)
        lines = tuple(o.lines)  # it's a generator. flatten it now before etc
        return lines, o.exception

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


class Case800_no_args(_CommonCase):

    def test_100_just_prints_entire_help_screen(self):
        self.apparently_just_prints_entire_help_screen()

    def given_args(self):
        return ()


class Case801_strange_arg(_CommonCase):

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


class Case802_strange_option(_CommonCase):

    def test_100_just_prints_entire_help_screen(self):
        self.apparently_just_prints_entire_help_screen()

    def given_args(self):
        return ('--cho-monculous')


class Case803_toplevel_help_in_general(_CommonCase):

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


class Case804_toplevel_help_plus_argument(_CommonCase):

    def test_100_just_prints_entire_help_screen(self):
        self.apparently_just_prints_entire_help_screen()

    def given_args(self):
        return ('--help', 'fah-foo')


# Case805_use_hub_help

# Case808_create_hub_help


class Case811_traverse_help(_CommonCase):

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


class Case812_traverse_fail(_CommonCase):

    def test_100_generic_failure_exit_status(self):
        self.expect_exit_code(2)  # FileNotFoundError.errno

    def test_200_message_lines(self):
        _actual, = self.end_state().lines
        reason, path = _actual.split(' - ')
        self.assertEqual(reason, 'collection does not exist because no schema file')  # noqa: E501
        self.assertEqual(path, 'qq/pp/schema.toml\n')

    @shared_subject
    def end_state(self):
        return self.build_end_state('stderr', 'click exception')

    def given_args(self):
        return ('--collections-hub', 'qq', 'traverse', 'pp')


class Case813_traverse(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_lines_look_like_internal_identifiers(self):
        lines = tuple(self.end_state().lines)
        self.assertIn(len(lines), range(7, 10))
        import re
        rx = re.compile('^[A-Z0-9]{3}\n$')
        for line in lines:
            assert(rx.match(line))

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout', None)

    def given_args(self):
        return (*common_args_head(), 'traverse', _common_collection)


class Case814_select_help(_CommonCase):

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


class Case817_get_help(_CommonCase):

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


class Case818_get_fail(_CommonCase):

    def test_100_exit_code_is_404_lol(self):
        self.assertEqual(self.end_state().exception.exit_code, 404)

    def test_200_says_only_not_found__with_ID(self):
        line, = self.end_state().lines
        self.assertEqual(line, "'B9F' not found\n")

    @shared_subject
    def end_state(self):
        return self.build_end_state('stderr', 'click exception')

    def given_args(self):
        return (*common_args_head(), 'get', _common_collection, 'B9F')


class Case819_get(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_lines_wow(self):
        lines = self.end_state().lines
        _actual_big_string = ''.join(lines)  # correct an issue todo
        _actual_lines = tuple(_lines_via_big_string_as_is(_actual_big_string))

        _expect_big_s = """
        {
          "identifier_string": "B9H",
          "core_attributes": {
            "thing-A": "hi H",
            "thing-B": "hey H"
          }
        }
        """

        _expect_lines = tuple(unindent(_expect_big_s))
        self.assertSequenceEqual(_actual_lines, _expect_lines)

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout', None)

    def given_args(self):
        return (*common_args_head(), 'get', _common_collection, 'B9H')


class Case820_create_help(_CommonCase):

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


class Case821_create_fail(_CommonCase):

    def test_100_exit_code_reflects_failure(self):
        self.expect_exit_code_for_bad_request()

    def test_200_reason(self):
        line, = self.end_state().lines
        self.assertEqual(line, 'request was empty\n')

    @shared_subject
    def end_state(self):
        return self.build_end_state('stderr', 'click exception')

    def given_args(self):
        return (*common_args_head(), 'create', _common_collection)

    def filesystem(self):
        return None


class Case822_create(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_stdout_lines_are_toml_lines_of_created_fellow(self):

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

        :#HERE3
        """

        _actual = self.common_entity_screen().stdout_lines

        _expected = tuple(unindent("""
        [item.2H3.attributes]
        aa = "AA"
        bb = "BB"
        """))

        self.assertSequenceEqual(_actual, _expected)

    def test_300_stderr_line_is_decorative(self):
        line = self.common_entity_screen().stderr_line
        self.assertEqual(line, 'created:\n')

    @shared_subject
    def common_entity_screen(self):
        return self.expect_common_entity_screen()

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout and stderr', None)

    def given_args(self):
        return (*common_args_head(), 'create', _common_collection,
                '-val', 'aa', 'AA', '-val', 'bb', 'BB')

    def filesystem(self):
        return build_filesystem_expecting_num_file_rewrites(2)

    def random_number(self):
        return 481  # kiss ID 2H3 is base 10 481


class Case823_delete_help(_CommonCase):

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


# Case824 - delete fail


class Case825_delete(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_stdout_is_deleted_lines(self):

        _actual = self.common_entity_screen().stdout_lines

        _expected = tuple(unindent("""
        [item.B7G.attributes]
        thing-1 = "hi G"
        thing-2 = "hey G"
        """))

        self.assertSequenceEqual(_actual, _expected)

    def test_300_stderr_line_is_decorative(self):
        line = self.common_entity_screen().stderr_line
        self.assertEqual(line, 'deleted:\n')

    @shared_subject
    def common_entity_screen(self):
        return self.expect_common_entity_screen()

    @shared_subject
    def end_state(self):
        # return self.build_end_state_FOR_DEBUGGING()
        return self.build_end_state('stdout and stderr', None)

    def given_args(self):
        return (*common_args_head(), 'delete', _common_collection, 'B7G')

    def filesystem(self):
        return build_filesystem_expecting_num_file_rewrites(2)


class Case226_update_help(_CommonCase):

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


class Case828_update(_CommonCase):

    def test_100_succeeds(self):
        self.expect_exit_code_is_the_success_exit_code()

    def test_200_stdout_is_updated_lines_CAPTURE_WS_ISSUE(self):

        _actual = self.common_entity_screen().stdout_lines

        _expected = tuple(unindent("""
        [item.B7F.attributes]
        thing-2 = "hey F updated"

        thing-3 = "T3"
        thing-4 = "T4"
        """))

        self.assertSequenceEqual(_actual, _expected)

    def test_300_stderr_line_is_decorative(self):
        line = self.common_entity_screen().stderr_line
        self.assertEqual(line, 'updated. new entity:\n')

    @shared_subject
    def common_entity_screen(self):
        return self.expect_common_entity_screen()

    @shared_subject
    def end_state(self):
        return self.build_end_state('stdout and stderr', None)

    def given_args(self):
        return (*common_args_head(), 'update', _common_collection,
                'B7F',
                '-delete', 'thing-1',
                '-change', 'thing-2', 'hey F updated',
                '-add', 'thing-3', 'T3',
                '-add', 'thing-4', 'T4',
                )

    def filesystem(self):
        return build_filesystem_expecting_num_file_rewrites(1)


class Case829_search_help(_CommonCase):

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

    def debug_IO_f():
        import sys as _
        return _.stderr

    o = CLI_support.BIG_FLEX(
            given_args=('--help',),
            allow_stdout_lines=True,
            allow_stderr_lines=False,
            exception_category='system exit',
            injections_dictionary=None,
            might_debug=False,  # ..
            do_debug_f=lambda: False,  # ..
            debug_IO_f=debug_IO_f,
            )

    _tree = CLI_support.tree_via_lines(o.lines)
    return _StructTreeAndExitCode(_tree, o.exception.code)


class _StructUsageLineAndFirstDescLine:
    def __init__(self, *two):
        self.usage_line, self.first_description_line = two


class _StructTreeAndExitCode:
    def __init__(self, *two):
        self.tree, self.exit_code = two


def _lines_via_big_string_as_is(big_string):
    import kiss_rdb.magnetics_.CUD_attributes_via_request as lib
    return lib.lines_via_big_string_(big_string)


# == general

def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_common_collection = '050-rumspringa'
_IID = 'INTERNAL_IDENTIFIER'

_success_exit_code = 0

if __name__ == '__main__':
    unittest.main()

# #born.
