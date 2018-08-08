# #covers: script.sync

from _init import (
        fixture_executable_path,
        fixture_file_path,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


class _CommonCase(unittest.TestCase):
    """NOTE - many of these are abstraction candidates

    #track #[#410.K]
    """

    # -- assertions

    def _CLI_client_results_in_failure_exitstatus(self):
        self._CLI_client_results_in_failure_or_success(False)

    def _CLI_client_results_in_success_exitstatus(self):
        self._CLI_client_results_in_failure_or_success(True)

    def _CLI_client_results_in_failure_or_success(self, expect_success):
        sta = self._end_state()
        es = sta.exitstatus
        self.assertEqual(type(es), int)  # #[#412]
        if expect_success:
            self.assertEqual(es, 0)
        else:
            self.assertNotEqual(es, 0)

    # -- assertion assist

    def _displays_usage(self):
        _lines = self._stderr_lines()
        self.assertRegex(
                _lines[0],
                r'^usage: me \[-h\] \[--near-format FORMAT\] '
                r'\[--far-format FORMAT\] \[--diff\]\n'
                r' +near-collection far-collection$')

    def _first_line(self):
        return self._this_line(0)

    def _second_line(self):
        return self._this_line(1)

    def _this_line(self, offset):
        return self._stderr_lines()[offset]

    def _stderr_lines(self):
        return self._end_state().stderr_lines

    # -- build end state

    def _build_end_state(self):

        _argv = self._argv()

        _stdin = self._stdin()

        stdout, stderr, end_stater = self._sout_and_serr_and_end_stater()
        # stdout, stderr, end_stater = _these().for_DEBUGGING()

        _cli = _subject_script()._CLI(_stdin, stdout, stderr, _argv)

        _actual_exitstatus = _cli.execute()

        return end_stater(_actual_exitstatus)

    def _expect_this_many_on_stderr(self, num):
        return self._expect_on_X_this_many('stderr', num)

    def _expect_on_X_this_many(self, which, num):
        return _these().for_expect_on_which_this_many_under(which, num, self)

    def _stdin(self):
        return _these().MINIMAL_INTERACTIVE_IO


class Case010_basics(_CommonCase):

    def test_100_subject_script_loads(self):
        self.assertIsNotNone(_subject_script())


class Case020_must_be_interactive(_CommonCase):

    def test_100_CLI_client_results_in_failure_exitstatus(self):
        self._CLI_client_results_in_failure_exitstatus()

    def test_110_first_line_explains(self):
        self.assertEqual(self._first_line(), 'cannot yet read from STDIN.\n')

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _stdin(self):
        return _these().MINIMAL_NON_INTERACTIVE_IO

    def _argv(self):
        return ()

    def _sout_and_serr_and_end_stater(self):
        return self._expect_this_many_on_stderr(2)


class Case030_strange_option(_CommonCase):  # #coverpoint6.1.2

    def test_100_fails(self):
        self._CLI_client_results_in_failure_exitstatus()

    def test_110_SECOND_line_explains(self):
        _ = self._second_line()
        self.assertEqual(_, 'me: error: unrecognized arguments: --zazoozle\n')

    def test_120_displays_usage(self):
        self._displays_usage()

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _argv(self):
        return ('me', '--zazoozle', 'aa', 'bb')

    def _sout_and_serr_and_end_stater(self):
        return self._expect_this_many_on_stderr(2)


class Case035_missing_requireds(_CommonCase):

    def test_100_fails(self):
        self._CLI_client_results_in_failure_exitstatus()

    def test_110_umm(self):
        _act = self._second_line()
        _exp = 'the following arguments are required: '
        'near-collection, far-collection'
        self.assertIn(_exp, _act)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _argv(self):
        return ('me',)

    def _sout_and_serr_and_end_stater(self):
        return self._expect_this_many_on_stderr(2)


class Case040_top_help_screen(_CommonCase):

    def test_100_succeeds(self):
        self._CLI_client_results_in_success_exitstatus()

    def test_200_something_about_usage(self):
        self._section('usage')  # exists

    def test_300_something_about_description(self):
        _sect = self._section('description')
        _first_line = _sect.children[0].styled_content_string
        self.assertIn('description: for a given particular natur', _first_line)

    def test_400_something_about_arguments(self):
        self._num_children(self._section('positional arguments'), 2)

    def test_500_something_about_options(self):
        self._num_children(self._section('optional arguments'), 4)  # -h + 1

    def _num_children(self, sect, num):
        cx = sect.children
        self.assertEqual(len(cx), 2)
        _act = len(cx[1].children)
        self.assertEqual(_act, num)

    def _section(self, key):
        return self._section_index()[key]

    @shared_subject
    def _section_index(self):
        _lines = self._end_state().stderr_lines
        return _help_screen_lib().section_index_via_chunks(_lines)

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _sout_and_serr_and_end_stater(self):
        return _these().for_recording_all_stderr_lines()

    def _argv(self):
        return ('me', '-h')


class Case050_FA_help_screen(_CommonCase):

    def test_100_succeeds(self):
        self._CLI_client_results_in_success_exitstatus()

    def test_200_stdout_lines_look_like_items__at_least_two(self):
        import re
        rx = re.compile(r'^ +[_a-z]+ \(\*\.[a-z]{2,3}\)$')  # ..
        s_a = self._end_state().first_section('stdout').lines
        self.assertGreaterEqual(len(s_a), 2)
        for s in s_a:
            self.assertRegex(s, rx)

    def test_300_total_number_of_format_adapters_at_end(self):
        s_a = self._end_state().last_section('stderr').lines
        self.assertEqual(len(s_a), 1)
        self.assertRegex(s_a[0], r'^\(\d+ total\.\)$')

    def test_400_reminder_at_begnning_about_help(self):
        _s_a = self._end_state().first_section('stderr').lines
        self.assertIn('FYI', _s_a[0])

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _sout_and_serr_and_end_stater(self):
        return _these().for_flip_flopping_sectioner()

    def _argv(self):
        return ('me', '--near-format', 'help', 'xx', 'yy')


class Case060_strange_format_adapter_name(_CommonCase):
    """(this is to get us "over the wall - there is another test just like

    it that is modality-agnostic. (but this one came first! yikes)
    """

    def test_100_fails(self):
        self._CLI_client_results_in_failure_exitstatus()

    def test_200_says_not_found(self):
        _ = self._two_sentences()[0]
        self.assertEqual(_, "no format adapter for 'zig-zag'")

    def test_300_says_did_you_mean(self):
        _ = self._two_sentences()[1]
        self.assertRegex(_, r"\bthere's '[a-z_]+' and '")

    @shared_subject
    def _two_sentences(self):
        return self._first_line().split('. ')

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _sout_and_serr_and_end_stater(self):
        return self._expect_this_many_on_stderr(1)

    def _argv(self):
        return ('me', '--far-format', 'zig-zag', 'xx', 'yy')


class Case070_money_and_diff(_CommonCase):  # #coverpoint6.2

    def test_100_succeeds(self):
        self._CLI_client_results_in_success_exitstatus()

    def test_200_entire_output_is_just_the_diff(self):
        self.assertIsNotNone(self._crazy_parse_tree())

    def test_300_these_exactly(self):
        _act = [x.string for x in self._of_tree('edits')]
        _exp = (
                '-| four | five | six\n',
                '+|four| five |SIX  \n',
                '+|seven|EIGHT|     |\n',
                )
        self.assertSequenceEqual(_act, _exp)

    def test_400_these_paths_look_like_git_paths(self):
        t = self._crazy_parse_tree()
        md0 = t.before_path.group
        md1 = t.after_path.group
        self.assertEqual(md0(1), 'a')
        self.assertEqual(md1(1), 'b')
        self.assertIsNotNone(md0(2))
        self.assertEqual(md0(2), md1(2))

    def _of_tree(self, name):
        return getattr(self._crazy_parse_tree(), name)

    @shared_subject
    def _crazy_parse_tree(self):
        _lines = self._end_state().stdout_lines
        return _CrazyDiffParse(_lines).execute()

    @shared_subject
    def _end_state(self):
        return self._build_end_state()

    def _sout_and_serr_and_end_stater(self):
        return _these().for_recording_all_stdout_lines()

    def _argv(self):
        return ('me', '--diff', _markdown_0100(), _far_130())


# #open [#410.T] cover case: no diff


def _far_130():
    return fixture_executable_path('exe_130_edit_add.py')


def _markdown_0100():
    return fixture_file_path('0100-hello.md')


class _CrazyDiffParse:

    def __init__(self, lines):
        self._stack = [
            (range(3, 5), r'^ [^ ]'),
            (range(1, 99), r'^[-+]', 'edits'),
            (range(3, 5), r'^ [^ ]'),
            (1, r'^@@ -\d+,\d+ \+\d+,\d+ @@$'),
            (1, r'^\+\+\+ (.)(.+)', 'after_path'),
            (1, r'^--- (.)(.+)', 'before_path'),
            (1, r'^diff '),
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
                    cover_me()
            else:
                cover_me()
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
                    cover_me()
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
        return self._range.start <= num

    def this_is_the_end(self, num):
        return self._range.stop == num


def cover_me():
    raise Exception('cover me')


def _help_screen_lib():
    import script_lib.test_support.expect_help_screen as lib
    return lib


def _these():
    import script_lib.test_support.stdout_and_stderr_and_end_stater as lib
    return lib


def _expect_STDs():
    import script_lib.test_support.expect_STDs as lib
    return lib


@memoize
def _subject_script():
    import script.sync as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
