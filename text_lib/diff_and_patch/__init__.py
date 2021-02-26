"""
Our favorite functions so far:

- `next_hunk_via_line_scanner`: Parse a single hunk (AST) out of a stream
  (actually scanner) of lines. One day we'll justify why we don't use `unidiff`

- `scanner_via_iterator`: convenience method exposed here typically used
  with above, to convert an iterator of lines (e.g. an open filehandle)
  into a line scanner with one element of lookahead, for parsing.

- `apply_patch_via_lines`: passes input lines directly to the system's
  `patch` utility. Uses an intermediate tempfile to avoid partial patchings.


Our business lexicon (and other assumptions and provisions) for patches:

- We input and output the "unified diff" format where not stated otherwise.
  (The manpage for `patch` seems to imply that this is the same thing as
  as a "context diff".)

- We don't refer to our business objects as "patches" unqualified because
  it's ambiguous what that means in regards to how big or little the
  unit of diff is.

- The part of a unified diff that starts with an '@@', the `patch` mangpage
  calls that a "hunk" and so, so do we.

- The expression "patch file" (as a noun) is a bit ambigious and we might
  alter other language here to avoid the expression. Here we use it to mean
  any series of lines in the "context diff" format; but note a single
  "patch file" may have several "file patches" in it (yikes). We may prefer
  simply "context diff".

- We say a "file patch" to mean those lines of a context diff targeting
  a specific, given file. In our VCS, such runs of lines are demarcated with
  a line like `diff --git a/some/file.code b/some/file.code`, which `patch`
  recognizes as a context diff header. A "file patch" is composed of some
  header lines and one or more hunks.

- We use the term "run" here (as in "a run of lines") to mean, within a
  hunk, a … run of contiguous lines within a hunk of the same type (insert,
  remove or context).
"""

# (old comments from pre #history-B.4 just about the test-support facilities):

# Conceptually this was abstracted from [#873.23] a testing DSL we made
# in one file for asserting the content of file patches. See there for
# discussion of why we didn't complete the abstraction; hence this file
# only #began-as-abstraction.


from dataclasses import dataclass as _dataclass
import re as _re


# == BEGIN a small amount of CLI tooling just for dev assistance

def cli_for_production():
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv))


def _formals_for_CLI():
    yield '-h', '--help', 'This screen'
    yield 'WHICH_WAY', '{ "OLD_WAY" | "NEW_WAY" } There are two ways'
    yield 'FILE', "A unifed diff in a file. pass '-' to read from STDIN."


def _CLI(sin, sout, serr, argv):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(_do_CLI, sin, sout, serr, argv, _formals_for_CLI())


def _do_CLI(sin, sout, serr, which, path, _rscr):
    "experiment. just for testing patch files"

    do_new_way = ('OLD_WAY', 'NEW_WAY').index(which)

    if '-' == path:
        from contextlib import nullcontext
        opened = nullcontext(sin)
    else:
        opened = open(path)

    with opened as input_lines:
        if do_new_way:
            scn = scanner_via_iterator(input_lines)
            while scn.more:
                hunk = next_hunk_via_line_scanner(scn)
                serr.writelines(hunk.to_summary_lines())
        else:
            for fp in file_patches_via_unified_diff_lines(input_lines):
                serr.writelines(fp.to_summary_lines())
    return 0

# == END CLI tooling


def lazy(orig_f):  # #decorator #[#510.6]
    def use_f():
        if orig_f.do_call:
            orig_f.memoized_value = orig_f()
        return orig_f.memoized_value
    orig_f.do_call = True
    return use_f


def file_patches_via_unified_diff_lines(lines):  # :[#606]
    """NOTE probably use `next_hunk_via_line_scanner` (or a derivative)

    instead for all new work. This older way is being maintained for now for
    at least three reasons:

    - No time to refactor the whole world right now
    - The Old Way has multi-pass, opt-in progressive parsing (coarse pass
      then fine pass) which has different behavior clients may prefer
      (e.g unit tests). May have some performance benefit lol
    - The Old Way uses a clever older parser generator below that we just
      can't quit yet even though the new FSA pattern is the bee's knees.
    """

    # The parse is lazy/streaming across two axes: one, it chunks the input
    # lines in to "file patches" with the really coarse parsing below, rather
    # than parsing the whole "big patchfile" in to memory all at once.

    # (It may do similar lazy parsing/streaming things with the other plural
    # elements, like the hunks in a file patch, or the runs in hunk.)

    # The other axis of laziness is that we don't parse down in to deeper
    # level of detail until we need to (like the hunks of a file, or the
    # runs in a hunk). So when the file patch is first constructed, it is just
    # a flat tuple of raw lines, not an array of chunks; and similarly a
    # chunk with its runs.

    scn = scanner_via_iterator(lines)
    return _file_patches_via_unified_diff_line_scanner_OLD_WAY(scn)


def _file_patches_via_unified_diff_line_scanner_OLD_WAY(scn):
    line_cache = []
    while scn.more:

        # Advance over the zero or more "junk" lines
        # (keep going until you find the '@' line but don't consume it)
        while True:
            first_char = scn.peek[0]
            if '@' == first_char:
                break
            assert(' ' != first_char)
            line_cache.append(scn.next())
            assert scn.more

        while True:
            line_cache.append(scn.next())
            if scn.empty:
                break  # this might let some invalid unidiffs thru
            first_char = scn.peek[0]
            if first_char in (' ', '+', '-', '@'):
                continue
            break

        file_patch_lines = tuple(line_cache)
        line_cache.clear()
        yield _FilePatch(file_patch_lines)


def requires_parse(orig_f):  # #decorator
    def use_f(self):
        if self._is_raw:
            self._is_raw = False
            self._parse()
        return orig_f(self)
    return use_f


class _FilePatch:

    def __init__(self, lines):
        self._lines = lines
        self._is_raw = True

    @requires_parse
    def to_summary_lines(self):
        for line in self.junk_lines:
            yield f"JUNK LINE: {line}"
        yield f"MMM LINE: {self.mmm_line}"
        yield f"PPP LINE: {self.ppp_line}"
        for hunk in self.hunks:
            for line in hunk.to_summary_lines():
                yield line

    @property
    @requires_parse
    def junk_lines(self):
        return self._junk_lines

    @property
    @requires_parse
    def mmm_line(self):
        return self._mmm_line

    @property
    @requires_parse
    def ppp_line(self):
        return self._ppp_line

    @property
    @requires_parse
    def hunks(self):
        if self._hunks_is_raw:
            self._hunks_is_raw = False
            self._parse_hunks()
        return self._hunks

    def _parse_hunks(self):
        asts = self._hunk_ASTs
        del self._hunk_ASTs
        self._hunks = tuple(_Hunk_OLD_WAY(astt) for astt in asts)

    def _parse(self):
        lines = self._lines
        del self._lines
        ast = _parse_file_patch(lines)
        if 'junk_line' in ast:  # zero or more
            _ = tuple(md.string for md in ast.pop('junk_line'))
        else:
            _ = ()
        self._junk_lines = _
        self._mmm_line = ast.pop('minus_minus_minus_line').string
        self._ppp_line = ast.pop('plus_plus_plus_line').string
        self._hunk_ASTs = ast.pop('hunk')
        self._hunks_is_raw = True
        assert(not len(ast))


class _Hunk_OLD_WAY:
    def __init__(self, ast):
        self._at_at_line = ast.pop('at_at_line').string
        self._body_lines = tuple(md.string for md in ast.pop('body_line'))
        assert(not len(ast))
        self._is_raw = True

    def these_lines(self, *tokens):
        """Given args like ('context', '(', 'remove', 'add', ')', 'context'),

        both assert this run pattern over the whole hunk and return the
        corresponding lines from the captured subexpression expressed by
        the parenthesis"""

        return _these_lines(self.runs, tokens)

    def to_remove_lines_runs(self):
        return self._to_runs('remove_lines')

    def to_add_lines_runs(self):
        return self._to_runs('add_lines')

    def _to_runs(self, cat):
        for run in self.runs:
            if cat == run.category_name:
                yield run

    def to_summary_lines(self):
        yield f'HUNK: {self._at_at_line}'
        for run in self.runs:
            cat_name = run.category_name
            for line in run.lines:
                yield f'{cat_name}: {line}'

    @property
    @requires_parse
    def runs(self):
        return self._runs

    def to_the_four_integers(self):
        md = _AT_AT_four_integers_rx.match(self._at_at_line)
        return tuple(int(s) for s in md.groups())

    def _parse(self):
        lines = self._body_lines
        del self._body_lines
        _ = _partition(lines, lambda line: line[0], lambda cat, items: _Run(cat, items))  # noqa: E501
        self._runs = tuple(_)


def _partition(items, category_function, flush_chunk):
    itr = iter(items)
    for item in itr:
        previous_category = category_function(item)
        item_cache = [item]
        break
    for item in itr:
        current_category = category_function(item)
        if previous_category == current_category:
            item_cache.append(item)
            continue
        # there was a change
        yield flush_chunk(previous_category, tuple(item_cache))
        item_cache.clear()
        item_cache.append(item)
        previous_category = current_category
    assert(len(item_cache))
    yield flush_chunk(previous_category, tuple(item_cache))


# == Complicated Reading

def _these_lines(runs, tokens):
    # this is like a specialized unittest.assertSequenceEqual that also
    # captures a subexpression in the runs. (see __doc__ of caller)

    captured_runs = []

    expected_pattern, run_offset_of_open_parenthesis, \
        run_offset_of_close_parenthesis = _parse_for_these_lines(tokens)

    actual_stack = list(reversed(runs))
    expected_stack = list(reversed(expected_pattern))

    is_before_capturing, is_capturing, is_after_capturing = (True, False, 0)

    offset = -1  # be careful
    while len(actual_stack):
        offset += 1

        # Assert expectations

        actual = actual_stack.pop()
        if not len(expected_stack):
            xx("unexpected extra run(s)")
        expected = expected_stack.pop()
        if expected != actual.category_name:
            xx(f"had '{actual.category_name}' expected {expected} at {offset}")

        # Maybe capture

        if is_before_capturing:
            if offset < run_offset_of_open_parenthesis:
                continue
            assert(run_offset_of_open_parenthesis == offset)
            is_before_capturing = False
            is_capturing = True

        if is_capturing:
            if run_offset_of_close_parenthesis == offset:
                is_capturing = False
                is_after_capturing = True
                continue
            assert(offset < run_offset_of_close_parenthesis)
            captured_runs.append(actual)
            continue

        assert(is_after_capturing)

    if len(expected_stack):
        xx("missing expected run(s)")

    leng = run_offset_of_close_parenthesis - run_offset_of_open_parenthesis
    assert(leng == len(captured_runs))

    def lines():
        for run in captured_runs:
            for line in run.lines:
                yield line

    return tuple(lines())


def _parse_for_these_lines(tokens):
    run_offset = 0
    run_offset_of_open_parenthesis = None
    run_offset_of_close_parenthesis = None

    expected_pattern = []

    for token in tokens:
        if token in ('context', 'remove', 'add'):
            run_offset += 1
            expected_pattern.append(f'{token}_lines')
            continue
        if '(' == token:
            assert(run_offset_of_open_parenthesis is None)
            run_offset_of_open_parenthesis = run_offset
            continue
        assert(')' == token)
        assert(run_offset_of_close_parenthesis is None)
        run_offset_of_close_parenthesis = run_offset

    assert(run_offset_of_open_parenthesis is not None)
    assert(run_offset_of_close_parenthesis is not None)
    assert(run_offset_of_open_parenthesis < run_offset_of_close_parenthesis)
    # the above implicitly asserts a nonzero amount of run category references

    return tuple(expected_pattern), \
        run_offset_of_open_parenthesis, run_offset_of_close_parenthesis


_run_category_via_character = \
        {' ': 'context_lines', '-': 'remove_lines', '+': 'add_lines'}


class _Run:
    def __init__(self, char, lines):
        self.category_name = _run_category_via_character[char]
        self.lines = lines


# == Parsing

def _parse_file_patch(lines):

    parser_builder = _parser_builder()
    p = parser_builder()

    lineno = 0
    reached_done = False
    itr = iter(lines)
    for line in itr:
        lineno += 1

        while True:
            direc = p.parse_line(line)
            if direc is None:
                direc = ('stop', None)

            direc_name, direc_data = direc

            if 'done_but_rewind' == direc_name:
                xx()

            break

        if 'stay' == direc_name:
            continue

        if 'stop' == direc_name:
            lines = parser_builder.THESE_LINES(line, lineno, p)
            xx(' '.join(lines))
            # listener('error', 'expression', 'expecting', lambda: lines)
            return

        if 'done' == direc_name:
            xx()
            reached_done = True
            ast = direc_data()
            xx(ast)
            break
        xx()

    assert(not reached_done)  # our grammar is such that, it globs on tail

    for unexpected_line in itr:
        xx()  # had more lines than we expected

    return p.receive_EOF()()


@lazy
def _parser_builder():
    from text_lib.magnetics.parser_via_grammar import \
        WIP_PARSER_BUILDER_VIA_DEFINITION as parser_builder_via, THESE_LINES

    parser_builder = parser_builder_via(_define_grammar)
    parser_builder.THESE_LINES = THESE_LINES
    return parser_builder


def _define_grammar(g):
    # (compare this to the next function for a 6 mo. later alternative)

    define = g.define
    sequence = g.sequence
    # alternation = g.alternation
    regex = g.regex

    define('file', sequence(
        ('between', 0, 'and', 3, 'junk_line', 'keep'),  # not implemented fully
        ('one', 'minus_minus_minus_line', 'keep'),
        ('one', 'plus_plus_plus_line', 'keep'),
        ('one_or_more', 'hunk', 'keep'),
    ))

    define('hunk', sequence(
        ('one', 'at_at_line', 'keep'),
        ('one_or_more', 'body_line', 'keep')
    ))

    define('junk_line', regex(r'^[a-z]'))  # ..
    define('minus_minus_minus_line', regex(r'^---[ ]'))
    define('plus_plus_plus_line', regex(r'^\+\+\+[ ]'))
    define('at_at_line', regex(r'^@@[ ]'))
    define('body_line', regex(r'^[- +]'))


def next_hunk_via_line_scanner(scn):
    """(DEV NOTES: this is an alternative implementation of the above function,

    one from six months later using the our new favorite pattern for parsing
    (#[#508.5]), and one that has different properties and is for different
    purposes.

    This way is more robust because it counts down and asserts the acutal
    number of hunk lines against what is declared at the hunk head line; and
    also it's "more readable" in its way because it's self-contained pure
    python with no external libraries; but the old way has a certain charm
    which is why we're maintaining both for now...)
    """

    def from_ready_state():
        yield if_does_not_start_with_AT, add_to_junk_lines
        yield since_it_starts_with_AT, on_AT_AT_line

    def if_does_not_start_with_AT():
        return '@' != first_char

    def add_to_junk_lines():
        # (you've got to allow blank lines, space-indented lines)
        store['junk_lines'].append(line)

    def since_it_starts_with_AT():
        assert '@' == first_char
        return True

    def on_AT_AT_line():
        md = _AT_AT_four_integers_rx.match(line)
        # ..
        store['AT_AT_line'] = line
        captures = md.groups()
        these = 'before_start', 'before_length', 'after_start', 'after_length'
        for i, k in enumerate(these):
            store[k] = int(captures[i])

        store['num_BEFORE_lines_remaining'] = store['before_length']
        store['num_AFTER_lines_remaining'] = store['after_length']
        assert 0 < expecting_this_many_more_hunk_lines()

        store['hunk_body_line_sexps'] = []
        move_to(from_expecting_another_hunk_line)

    def from_expecting_another_hunk_line():
        yield if_context_line, handle_context_line
        yield if_remove_line, handle_remove_line
        yield if_add_line, handle_insert_line

    def if_context_line():
        return ' ' == first_char

    def if_remove_line():
        return '-' == first_char

    def if_add_line():
        return '+' == first_char

    def handle_context_line():
        decrement('num_BEFORE_lines_remaining')
        decrement('num_AFTER_lines_remaining')
        return handle_hunk_line('context_line')

    def handle_remove_line():
        decrement('num_BEFORE_lines_remaining')
        return handle_hunk_line('remove_line')

    def handle_insert_line():
        decrement('num_AFTER_lines_remaining')
        return handle_hunk_line('insert_line')

    def decrement(which):
        num = store[which]
        if num < 1:
            _ = which.replace('_', ' ')
            xx(f"malformed hunk header: Expected zero {_}, had one: {line!r}")
        store.update_value(which, num - 1)

    def handle_hunk_line(sexp_type):
        store['hunk_body_line_sexps'].append((sexp_type, line))
        num = expecting_this_many_more_hunk_lines()
        if num:
            return

        # Once you are expecting no more lines in this hunk, you are done
        assert 0 == num
        store.pop('num_BEFORE_lines_remaining')
        store.pop('num_AFTER_lines_remaining')
        move_to(from_ready_state)
        return 'return_this', _Hunk_NEW_WAY(**store)

    def expecting_this_many_more_hunk_lines():
        return store['num_BEFORE_lines_remaining'] + \
               store['num_AFTER_lines_remaining']

    def move_to(state_function):
        stack[-1] = state_function

    stack = [from_ready_state]  # (we never actually push to the stack for now)
    store = _StrictDict()

    store['junk_lines'] = []

    def find_transition():
        for test, action in stack[-1]():
            yn = test()
            if yn:
                return action
        from_where = stack[-1].__name__.replace('_', ' ')
        lines = [f"Couldn't find a transition {from_where} for line:"]
        lines.append(repr(line))
        xx('\n'.join(lines))

    while scn.more:
        line = scn.peek
        first_char = line[0]
        action = find_transition()
        scn.advance()  # (calling it before we call the action just b.c we can)
        direc = action()
        if direc is None:
            continue
        typ = direc[0]
        assert 'return_this' == typ
        return_this, = direc[1:]
        return return_this

    from_where = stack[-1].__name__.replace('_', ' ')
    xx(f"{from_where}, expecting more input but had no more lines")


@_dataclass
class _Hunk_NEW_WAY:
    junk_lines: tuple  # or list but not formally
    AT_AT_line: str
    before_start: int
    before_length: int
    after_start: int
    after_length: int
    hunk_body_line_sexps: tuple  # or list but not formally

    def REVERT_LINES(self, current_lines):
        return _APPLY_HUNK_IN_REVERSE_YOURSELF_OMG(
            current_lines, self.hunk_body_line_sexps)

    def to_git_hunk_run_header_AST(self):
        scn = scanner_via_iterator(self.junk_lines)
        p = _git_hunk_run_parser()
        header_AST = p(scn)
        assert scn.empty  # ..
        return header_AST

    def to_summary_lines(self, margin=''):
        yield f"{margin}Hunk:\n"

        num_junk_lines = len(self.junk_lines)
        yield f"{margin}  ({num_junk_lines} junk lines)\n"
        yield f"{margin}  {self.AT_AT_line}"
        counts = {k: 0 for k in ('remove_line', 'insert_line', 'context_line')}
        for k, _ in self.hunk_body_line_sexps:
            counts[k] += 1
        yield f"{margin}  {counts!r}\n"


# ==

@lazy
def _git_hunk_run_parser():
    def parse(scn):  # #[#508.5] favorite FSA pattern

        def from_beginning_state():
            yield if_match(SHA_line_rx), go(from_expecting_author_line)

        def from_expecting_author_line():
            yield if_match(author_line_rx), go(from_expecting_date_line)

        def from_expecting_date_line():
            yield if_match(date_line_rx), go(from_expecting_message)

        def from_expecting_message():
            yield if_line_is_blank_or_indented, append_message_line
            yield if_match(DIFF_line_rx), go(from_expecting_MMM)

        def if_line_is_blank_or_indented():
            if '\n' == line:
                return True
            return ' ' == line[0]  # or rx. is it faster? #todo

        def append_message_line():
            store['message_lines'].append(line)

        def from_expecting_MMM():
            yield if_match(MMM_line_rx), go(from_expecting_PPP)

        def from_expecting_PPP():
            yield if_match(PPP_line_rx), MAYBE_DO_END

        def MAYBE_DO_END():
            store_last_matchdata()  # we just matched PPP line
            return 'return_this', _Git_Hunk_Run_Header_AST(**store)

        # ==

        def if_match(rx):
            def test():
                md = rx.match(line)
                if md is None:
                    return
                store['last_matchdata'] = md
                return True
            return test

        def go(next_state_function):
            def action():
                store_last_matchdata()
                stack[-1] = next_state_function
            return action

        def store_last_matchdata():
            md = store.pop('last_matchdata')
            for k, v in md.groupdict().items():
                store[k] = v

        def find_transition():
            for test, action in stack[-1]():
                yn = test()
                if yn:
                    return action
            from_where = stack[-1].__name__.replace('_', ' ')
            xx(f"No transition found {from_where} for line: {line!r}")

        stack = [from_beginning_state]
        store = _StrictDict()
        store['message_lines'] = []

        assert scn.more  # ..
        while scn.more:
            line = scn.peek
            action = find_transition()
            scn.advance()  # doing it before action just becase we can
            direc = action()
            if direc is None:
                continue
            typ = direc[0]
            assert 'return_this' == typ
            ret, = direc[1:]
            # (leave the line scanner wherever it is)
            return ret

        xx('never reached the end state (the "plus plus plus" line)')

    c = _re.compile
    SHA_line_rx = c(r'commit (?P<SHA>[0-9a-z]{8,})$')
    author_line_rx = c(r'Author:[ ](?P<author>.+)$')
    date_line_rx = c(r'Date:[ ]+(?P<datetime_string>[^ ].+)$')
    DIFF_line_rx = c(r'diff[ ]--git[ ](?P<A_path>[^ ]+)[ ](?P<B_path>\S+)$')
    MMM_line_rx = c(r'---[ ](?P<MMM_path>\S+)$')
    PPP_line_rx = c(r'\+\+\+[ ](?P<PPP_path>\S+)$')

    return parse


@_dataclass
class _Git_Hunk_Run_Header_AST:
    SHA: str
    author: str
    datetime_string: str
    message_lines: tuple  # (or list)
    A_path: str
    B_path: str
    MMM_path: str
    PPP_path: str

    def to_summary_lines(self, margin=''):
        def these():
            for line in self.message_lines:
                line = rx.match(line)[1]
                if '\n' == line:
                    continue
                yield line
        rx = _re.compile(r'[ ]*(.+)', _re.DOTALL)
        itr = these()
        line1 = next(itr)
        line2 = None
        for line2 in itr:
            break
        yield f"{margin}Git hunk run header AST:\n"
        yield f"{margin}  Commit: {self.SHA}\n"
        yield f"{margin}  Datetime: {self.datetime_string}\n"
        if True:
            yield f"{margin}  Excerpt: {line1}"
        if line2:
            yield f"{margin}           {line2}"


_ugh = 12


# ==

def scanner_via_iterator(lines):  # (used here, exposed for convenience)
    if not hasattr(lines, '__next__'):
        lines = iter(lines)  # we could do scanner_via_list but don't
    from text_lib.magnetics import scanner_via as scnlib
    return scnlib.scanner_via_iterator(lines)


# ==

def patch_unit_of_work_via(before_lines, after_lines, path_tail, do_create):
    assert isinstance(before_lines, tuple)  # #[#011]
    assert isinstance(after_lines, tuple)  # #[#011]

    if do_create:
        assert not len(before_lines)
        pathA = '/dev/null'
    else:
        pathA = f'a/{path_tail}'

    pathB = f'b/{path_tail}'

    from difflib import unified_diff
    diff_lines = tuple(unified_diff(before_lines, after_lines, pathA, pathB))

    class patch_unit_of_work:  # #class-as-namespace
        def replace_path_tail(new_path_tail):
            return patch_unit_of_work_via(  # ick/meh
                before_lines, after_lines, new_path_tail, do_create)
    o = patch_unit_of_work
    o.path_tail, o.do_create_file = path_tail, do_create
    o.diff_lines = diff_lines
    return o


def _APPLY_HUNK_IN_REVERSE_YOURSELF_OMG(current_lines, hunk_body_line_sexps):
    # this is written out of necessity and is not for general use
    # no fuzzy matching hunks
    # see next function for applying a patch using the system

    def fail_when_unexpected_extra():
        xx(f"Oops, unexpected extra line (input line {input_lineno}): {current_line!r}")  # noqa: E501

    def prepare_operation():
        typ, full_line = operation_stack[-1]
        line_body = full_line[1:]  # not wasteful, never been done before here
        return typ, line_body

    input_lineno = 0
    operation_stack = list(reversed(hunk_body_line_sexps))
    for current_line in current_lines:
        input_lineno += 1

        while True:  # (loop while doing another operation on the same line)

            if not operation_stack:
                fail_when_unexpected_extra()

            typ, line_body = prepare_operation()

            # For context lines, output line as-is after confirming is same
            if 'context_line' == typ:
                if line_body == current_line:
                    operation_stack.pop()
                    yield current_line
                    break
                a = [f"context mismatch on input line {input_lineno}:"]
                a.append(f"expected line: {line_body!r}")
                a.append(f"input line:    {current_line!r}")
                xx('\n'.join(a))

            # Insert lines manifest as remove lines when reversed. Do not yield
            if 'insert_line' == typ:
                if line_body == current_line:
                    # (do nothing, do not output the line. remember reversed)
                    operation_stack.pop()
                    break
                a = [f"line mismatch for reversed insert (delete) on line {input_lineno}:"]  # noqa: E501
                a.append(f"wanted to delete line: {line_body!r}")
                a.append(f"but had line:          {current_line!r}")
                xx('\n'.join(a))

            # For each one or more removed line, output it (loop within loop)
            assert 'remove_line' == typ
            operation_stack.pop()
            yield line_body

            # (you outputted the content of the operation but no the current
            #  input line, which still requires matching against operations)
            pass  # hi. loop again!

        # end while True loop
    # end traverse current lines

    if operation_stack:
        wat = operation_stack[-1][1]
        xx(f"oops, remaining instruction(s) at end of input: {wat!r}")


def apply_patch_via_lines(lines, is_dry, listener, cwd=None):
    # see previous function for a rough as hell "revert" written by hand

    from tempfile import NamedTemporaryFile
    with NamedTemporaryFile('w+') as fp:  # #[#508.3] this pattern

        # Write the diff lines to a temporary file
        for line in lines:
            fp.write(line)
        fp.flush()

        # Apply the patch and be done!
        if _apply_big_patchfile(fp.name, is_dry, cwd, listener):
            return True

        # If there was an issue, write the diff to a tempfile for dbg (#todo)
        fp.seek(0)
        dst = 'z/_LAST_PATCH_.diff'
        with open(dst, 'w') as dst_fp:  # from shutil import copyfile meh
            for line in fp:
                dst_fp.write(line)
        msg = f"(wrote a copy of patchfile for debugging - {dst})"
        listener('info', 'expression', 'wrote', lambda: (msg,))


def _apply_big_patchfile(patchfile_path, is_dry, cwd, listener):

    def serr(msg):
        if '\n' == msg[-1]:  # lines coming from the subprocess
            msg = msg[0:-1]
        listener('info', 'expression', 'from_patchfile', lambda: (msg,))

    args = [_PATCH_EXE_NAME]
    if is_dry:
        line = "(executing patch with --dry-run ON)"
        listener('info', 'expression', 'dry_run', lambda: (line,))
        args.append('--dry-run')
    args += ('--strip', '1', '--input', patchfile_path)

    import subprocess as sp
    opened = sp.Popen(
        args=args, stdin=sp.DEVNULL, stdout=sp.PIPE, stderr=sp.PIPE,
        text=True,  # don't give me binary, give me utf-8 strings
        cwd=cwd)  # might be None

    with opened as proc:

        # #todo the below is kinda funny looking and may need an expert
        stay = True
        while stay:
            stay = False
            for line in proc.stdout:
                serr(f"stdout from patch: {line}")
                stay = True
                break
            for line in proc.stderr:
                serr(f"stderr from patch: {line}")
                stay = True
                break

        proc.wait()  # not terminate. maybe timeout one day
        es = proc.returncode

    if 0 == es:
        return True
    serr(f"exitstatus from patch: {repr(es)}\n")


# == Simple Support

class _StrictDict(dict):  # #[#508.5] custom strict data structure
    # Just like a dict but you have to be clear about intent

    def __setitem__(self, k, v):
        assert k not in self
        return self._parent_set_item(k, v)

    def update_value(self, k, v):
        assert k in self
        return self._parent_set_item(k, v)

    _parent_set_item = dict.__setitem__


_AT_AT_four_integers_rx = _re.compile(
    r'@@[ ]\-(\d+),(\d+)[ ]\+(\d+),(\d+)[ ]@@(?:$|[ ])')


_PATCH_EXE_NAME = 'patch'


# ==

def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))


if '__main__' == __name__:
    cli_for_production()


# #history-B.4 add passive option to parsing, rewrite to use FSA pattern
# #history-B.2
# #began-as-abstraction
