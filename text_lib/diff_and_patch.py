# Parse unified diff files. In practice, just used in testing.
# If this gets too frustrating, consider using `unidiff` instead.

# Conceptually this was abstracted from [#873.23] a testing DSL we made
# in one file for asserting the content of file patches. See there for
# discussion of why we didn't complete the abstraction; hence this file
# only #began-as-abstraction.


def cli_for_production():
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv))


def _CLI(sin, sout, serr, argv):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            _do_CLI, sin, sout, serr, argv,
            formal_parameters=(
                ('-h', '--help', 'this screen'),
                ('file', 'zim zum')))


def _do_CLI(sin, sout, serr, path, _rscr):
    "experiment. just for testing patch files"

    def work(lines):
        for fp in file_patches_via_unified_diff_lines(lines):
            for line in fp._to_debugging_lines():
                serr.write(line)

    if '-' == path:
        work(sin)
    else:
        with open(path) as lines:
            work(lines)
    return 0


# == no more CLI

def lazy(orig_f):
    def use_f():
        if not len(pointer):
            pointer.append(orig_f())
        return pointer[0]
    pointer = []
    return use_f


def file_patches_via_unified_diff_lines(lines):  # :[#606]
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

    scn = _line_scanner_via_lines(lines)
    line_cache = []
    while scn.more:
        while True:
            first_char = scn.peek[0]
            if '@' == first_char:
                break
            assert(' ' != first_char)
            line_cache.append(scn.next())
            assert not scn.empty

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


def requires_parse(orig_f):
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
    def _to_debugging_lines(self):
        for line in self.junk_lines:
            yield f"JUNK LINE: {line}"
        yield f"MMM LINE: {self.mmm_line}"
        yield f"PPP LINE: {self.ppp_line}"
        for hunk in self.hunks:
            for line in hunk._to_debugging_lines():
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
        self._hunks = tuple(_Hunk(astt) for astt in asts)

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


class _Hunk:
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

    def _to_debugging_lines(self):
        yield f'HUNK: {self._at_at_line}'
        for run in self.runs:
            cat_name = run.category_name
            for line in run.lines:
                yield f'{cat_name}: {line}'

    @property
    @requires_parse
    def runs(self):
        return self._runs

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


def _line_scanner_via_lines(lines):
    if not hasattr(lines, '__next__'):
        lines = iter(lines)  # we could do scanner_via_list but don't
    from text_lib.magnetics import scanner_via as scnlib
    return scnlib.scanner_via_iterator(lines)


# ==

def apply_patch_via_lines(lines, is_dry, listener, cwd=None):

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


_PATCH_EXE_NAME = 'patch'


# ==

def xx(msg=None):
    raise RuntimeError(f"write me{f': {msg}' if msg else ''}")


if '__main__' == __name__:
    cli_for_production()

# #history-B.2
# #began-as-abstraction
