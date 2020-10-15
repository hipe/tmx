from kiss_rdb_test.common_initial_state import publicly_shared_fixture_file
from data_pipes_test.common_initial_state import executable_fixture
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes
import unittest


class CommonCase(unittest.TestCase):
    """NOTE - many of these are abstraction candidates

    #track #[#459.F] CLI integ tests have redundant setup
    """

    # -- assertions

    def CLI_client_results_in_failure_exitstatus(self):
        self.CLI_client_results_in_failure_or_success(False)

    def CLI_client_results_in_success_exitstatus(self):
        self.CLI_client_results_in_failure_or_success(True)

    def CLI_client_results_in_failure_or_success(self, expect_success):
        ec = self.end_state.exitcode
        self.assertTrue(isinstance(ec, int))
        if expect_success:
            self.assertEqual(ec, 0)
        else:
            self.assertNotEqual(ec, 0)

    def expect_ignorecase(self, act, rxs):
        import re
        self.assertRegex(act, re.compile(rxs, re.IGNORECASE))

    # -- assertion assist

    @property
    def first_line(self):
        return self.line_at_offset(0)

    @property
    def last_line(self):
        return self.line_at_offset(-1)

    def line_at_offset(self, offset):
        return self.end_state.stderr_lines[offset]

    # -- build end state

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        from script_lib.test_support.expect_STDs import \
            build_end_state_actively_for as func
        return func(self)

    def given_stdin(self):
        return 'FAKE_STDIN_INTERACTIVE'

    def given_CLI(self):
        return subject_script().CLI_

    do_debug = False


class Case3480_basics(CommonCase):

    def test_100_subject_script_loads(self):
        self.assertIsNotNone(subject_script())


class Case3483_must_be_interactive(CommonCase):

    def test_100_CLI_client_results_in_failure_exitstatus(self):
        self.CLI_client_results_in_failure_exitstatus()

    def test_110_first_line_explains(self):
        exp = 'usage error: cannot read from STDIN.\n'
        self.assertEqual(self.first_line, exp)

    def given_stdin(self):
        return 'FAKE_STDIN_NON_INTERACTIVE'

    def given_argv(self):
        return ('hoopie-doopie',)

    def expected_lines(_):
        yield 'STDERR'
        yield 'STDERR'


class Case3486DP_strange_option(CommonCase):

    def test_100_fails(self):
        self.CLI_client_results_in_failure_exitstatus()

    def test_110_first_line_explains(self):
        act = self.first_line
        rxs = "unrecognized option ['\"]--zazoozle"
        self.expect_ignorecase(act, rxs)

    def test_120_invites_to_help(self):
        act = self.last_line
        rxs = "['\"]me -(?:h|-help)['\"] for help"
        self.expect_ignorecase(act, rxs)

    def given_argv(self):
        return ('me', '--zazoozle', 'aa', 'bb')

    def expected_lines(_):
        yield 'STDERR'
        yield 'zero_or_one', 'STDERR'


class Case3489_missing_requireds(CommonCase):

    def test_100_fails(self):
        self.CLI_client_results_in_failure_exitstatus()

    def test_110_says_expecting(self):
        act = self.first_line
        rxs = r"expecting <?near-collection"
        self.expect_ignorecase(act, rxs)

    def given_argv(self):
        return ('me',)

    def expected_lines(_):
        yield 'STDERR'
        yield 'zero_or_one', 'STDERR'


class Case3492_top_help_screen(CommonCase):

    def test_100_succeeds(self):
        self.CLI_client_results_in_success_exitstatus()

    def test_200_something_about_usage(self):
        self.section('usage')  # exists

    def test_300_something_about_description(self):
        act = self.section('description').head_line
        self.assertIn('Mutate a near collection by merging', act)

    def test_400_something_about_arguments(self):
        act = self.section('arguments').body_line_count
        self.assertEqual(act, 2)

    def test_500_something_about_options(self):
        act = self.section('options').body_line_count
        self.assertEqual(act, 3)  # flickers when no trailing invite

    def section(self, key):
        return self.end_state_help_screen[key]

    @shared_subject
    def end_state_help_screen(self):  # ..
        lines = self.end_state.stderr_lines
        func = _help_screen_lib().parse_help_screen
        help_screen = func(lines)
        return help_screen

    def given_argv(self):
        return ('me', '-h')

    def expected_lines(_):
        yield 'one_or_more', 'STDERR'


class Case3495DP_FA_help_screen(CommonCase):

    def test_100_succeeds(self):
        self.CLI_client_results_in_success_exitstatus()

    def test_200_stdout_lines_look_like_items__at_least_one(self):
        import re
        rx = re.compile(r'^ +[-a-z]+ \([^(]*\)$')  # ..
        s_a = self.end_state.first_line_run('stdout').lines
        self.assertGreaterEqual(len(s_a), 1)
        for s in s_a:
            self.assertRegex(s, rx)

    def test_300_total_number_of_format_adapters_at_end(self):
        s_a = self.end_state.last_line_run('stderr').lines
        self.assertEqual(len(s_a), 1)
        self.assertRegex(s_a[0], r'^\(\d+ total\.\)$')

    def test_400_something_about_content(self):
        # (this was a more pointed message before #history-A.1)
        _s_a = self.end_state.first_line_run('stderr').lines
        _ = 'the filename extension can imply a format adapter.\n'
        self.assertEqual(_s_a[0], _)

    def given_argv(self):
        return ('me', '--near-format', 'help', 'pp', 'qq')

    def expected_lines(_):
        yield 'one_or_more'


class Case3498DP_strange_format_adapter_name(CommonCase):
    """(this is to get us "over the wall - there is another test just like

    it that is modality-agnostic. (but this one came first! yikes)
    """

    def test_100_fails(self):
        self.CLI_client_results_in_failure_exitstatus()

    def test_200_says_not_found(self):
        act = self.end_two_sentences[0]
        self.assertIn("unrecognized format name 'zig-zag'", act)

    def test_300_says_did_you_mean(self):
        act = self.end_two_sentences[1]
        exp = r"\bknown format name\(s\): \('[-a-z]+', '[-a-z]+'"
        self.assertRegex(act, exp)

    @shared_subject
    def end_two_sentences(self):
        return self.first_line.split('. ')

    def given_argv(self):
        return 'me', '--near-format', 'zig-zag', 'pp', 'qq'

    def expected_lines(_):
        yield 'STDERR'


class Case3502_money_and_diff(CommonCase):

    def test_100_succeeds(self):
        self.CLI_client_results_in_success_exitstatus()

    def test_200_entire_output_is_just_the_diff(self):
        self.assertIsNotNone(self.end_parse_tree)

    def test_300_these_exactly(self):
        act = tuple(wat.string for wat in self._of_tree('edits'))
        exp = ('-| four | five | six\n',
               '+|four| five |SIX\n',
               '+|seven|EIGHT||\n')
        self.assertSequenceEqual(act, exp)

    def test_400_these_paths_look_like_git_paths(self):
        t = self.end_parse_tree
        md0 = t.before_path.group
        md1 = t.after_path.group
        self.assertEqual(md0(1), 'a')
        self.assertEqual(md1(1), 'b')
        self.assertIsNotNone(md0(2))
        self.assertEqual(md0(2), md1(2))

    def _of_tree(self, name):
        return getattr(self.end_parse_tree, name)

    @shared_subject
    def end_parse_tree(self):
        _lines = self.end_state.stdout_lines
        return _CrazyDiffParse(_lines).execute()

    def given_argv(self):
        return ('me', '--diff', _markdown_0100(), _far_130())

    def expected_lines(_):
        yield 'one_or_more', 'STDOUT'


# #open [#459.I] cover case: no diff


def _far_130():
    return executable_fixture('exe_130_edit_add.py')


def _markdown_0100():
    return publicly_shared_fixture_file('0100-hello.md')


class _CrazyDiffParse:  # #open you should use [#606] instead

    def __init__(self, lines):
        self._stack = [
            (range(3, 5), r'^ [^ ]'),
            (range(1, 99), r'^[-+]', 'edits'),
            (range(3, 5), r'^ [^ ]'),
            (1, r'^@@ -\d+,\d+ \+\d+,\d+ @@$'),
            (1, r'^\+\+\+ (.)(.+)', 'after_path'),
            (1, r'^--- (.)(.+)', 'before_path'),
            # (1, r'^diff '),
        ]
        self._current_memo_is_plural = None
        self._current_memo_matches = None
        self._mutex = None
        self._lines = lines

    def execute(self):
        del(self._mutex)
        self._custom_object = _CustomObject()
        self._advance()
        f = self._receive
        for line in self._lines:
            f(line)
        self._close_any_current_memo_matches()
        return self._custom_object

    def _receive(self, s):
        return self._do_receive(True, s)

    def _do_receive(self, can_advance, s):
        import re
        sym = self._current_symbol
        md = re.search(sym.regex_string, s)
        num = self._current_count_of_matched_items
        if md is None:
            if sym.this_satisfies_the_minimum(num):
                if can_advance:
                    self._advance()
                    return self._do_receive(False, s)
                else:
                    xx()
            else:
                mini = sym.minimum
                xx(f"needed at least {mini} of '{sym.name}', had {num}")
        else:
            num += 1
            self._current_count_of_matched_items = num

            name = sym.name
            if name is not None:
                if 1 == sym._range.stop:
                    self._current_memo_is_plural = False
                    self._current_memo_match = md
                else:
                    if self._current_memo_matches is None:
                        self._current_memo_matches = []
                        self._current_memo_is_plural = True
                    self._current_memo_matches.append(md)

            if sym.this_is_the_end(num):
                if 0 == len(self._stack):
                    xx()
                    del(self._current_symbol)
                else:
                    self._advance()

    def _advance(self):
        self._close_any_current_memo_matches()
        self._current_count_of_matched_items = 0
        self._current_symbol = _Symbol(*self._stack.pop())

    def _close_any_current_memo_matches(self):
        if self._current_memo_is_plural is not None:
            self._close_current_memo()

    def _close_current_memo(self):
        if self._current_memo_is_plural:
            x = tuple(self._current_memo_matches)
            self._current_memo_matches = None
        else:
            x = self._current_memo_match
            self._current_memo_match = None
        self._current_memo_is_plural = None
        name = self._current_symbol.name
        setattr(self._custom_object, name, x)


class _CustomObject:
    pass


class _Symbol:

    def __init__(self, arity, regexp, name=None):
        if isinstance(arity, int):
            use_range = range(arity, arity)
        else:
            use_range = arity
        self._range = use_range
        self.regex_string = regexp
        self.name = name

    def this_satisfies_the_minimum(self, num):
        return self.minimum <= num

    @property
    def minimum(self):
        return self._range.start

    def this_is_the_end(self, num):
        return self._range.stop == num


def _help_screen_lib():
    import script_lib.test_support.expect_help_screen as lib
    return lib


def subject_script():
    import data_pipes.cli.sync as mod
    return mod


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


if __name__ == '__main__':
    unittest.main()

# #history-B.2
# #history-A.1 (as referenced)
# #born.
