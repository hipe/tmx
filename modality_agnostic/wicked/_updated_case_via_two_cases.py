from collections import namedtuple as _nt
import re


def updated_case_via_(ccase, tcase, listener):  # #testpoint
    def main():
        assert_that_the_two_cases_start_with_head_lines_and_stow_them_away()
        check_that_the_remaining_chunks_of_both_cases_are_all_test_functions()
        make_an_index_relating_each_template_function_KEY_to_its_position()
        traverse_the_client_functions_asserting_they_are_an_ordered_subset()
        return apply_the_plan()

    def apply_the_plan():
        result_functions = resolve_result_functions()
        result_head_lines = resolve_head_lines()
        # (cases don't have tail lines, just zero or more function runs)

        # NOTE currently the case block doesn't itself have a concept of
        # "functions" (because our recursive descent parsing). So, when we
        # make a new case from all our work, we flatten our result list of
        # functions into just lines. This is okay, but we could complexify it

        # We never change the first line

        use_AST = ccase.first_line_AST_
        lines = [ccase.lines[0]]

        if result_head_lines:
            for line in result_head_lines.lines:
                lines.append(line)

        for func in result_functions:
            for line in func.lines:
                lines.append(line)

        return ccase.__class__(use_AST, tuple(lines))

    def resolve_head_lines():
        c_head, t_head = self.c_head, self.t_head
        if has_content(c_head):
            if has_content(t_head):
                xx("we think we want to keep the client lines")
                return
            return c_head
        elif has_content(t_head):
            return t_head
        if all(('\n' == line) for line in c_head.lines):
            # maybe user is kinky about how many blank lines
            return c_head
        return t_head  # maybe client case was `pass`

    def has_content(chunk):
        def find():  # couldn't
            for i in range(0, leng):
                if '\n' != lines[i]:
                    return i
        leng = len(lines := chunk.lines)
        if (i := find()) is None:
            return  # there is no line that is not a newline
        if 1 == leng and '    pass\n' == lines[i]:
            return  # yikes, hard-code this exception for empty cases
        return True

    def resolve_result_functions():
        before_ks = set((*locals().keys(), 'before_ks'))

        def update_client_func_with_template_func(ci, ti):
            cfunc, tfunc = cfuncs[ci], tfuncs[ti]
            if not tfunc.has_directive:
                append(cfunc.updated_by(tfunc))
                return
            kw = tfunc._directive_body
            if 'default' != kw:
                raise _DirectiveError(f"'default' is only direc (had {kw!r})")

            # 'default' means "don't use it in the presence of a client func"
            result_functions.append(cfunc)

        def insert_template_case(ti):
            append(tfuncs[ti].without_directive())

        locs = locals()
        actions = {k: locs[k] for k in (set(locs.keys()) - before_ks)}

        def append(func):
            result_functions.append(func)

        plan, cfuncs, tfuncs = self.plan, self.c_functions, self.t_functions
        result_functions = []

        for k, *args in plan:
            actions[k](*args)

        return tuple(result_functions)

    def traverse_the_client_functions_asserting_they_are_an_ordered_subset():
        # Assert ordered subset. And while we're at it, make a plan too

        plan, cfuncs, tfuncs = [], self.c_functions, self.t_functions
        dct = self.template_function_offset_via_function_key
        previous_formal_offset = -1  # be careful

        def describe_case():
            return ''.join(('managed client case ', repr(ccase.case_key)))

        for i in range(0, len(cfuncs)):
            cfunc = cfuncs[i]
            all_purpose_k = cfunc.all_purpose_function_key
            formal_offset = dct.get(all_purpose_k)

            # Can't have strange new functions (Must be ordered *subset*)
            if formal_offset is None:
                def lines():
                    use_np = describe_case()
                    yield f"{use_np} can't add arbitrary new functions:"
                    yield ''.join(('>   ', cfunc.lines[0][:-1]))
                listener('error', 'expression', 'strange_new_function', lines)
                raise stop()

            # Must be in formal order (Must be *ordered* subset)
            if not (previous_formal_offset < formal_offset):
                def lines():
                    current = tfuncs[formal_offset].vernacular_name
                    previous = tfuncs[previous_formal_offset].vernacular_name
                    use_np = describe_case()
                    yield (f"The functions of {use_np} must be in the same "
                           "order as in the template case.")
                    yield f"Can't have {current!r} after {previous!r}"
                listener('error', 'expression', 'out_of_order', lines)
                raise stop()

            # Insert any formals in the distance between previous and here
            for ti in range(previous_formal_offset+1, formal_offset):
                plan.append(('insert_template_case', ti))

            # Do the update
            previous_formal_offset = formal_offset
            plan.append(('update_client_func_with_template_func', i, formal_offset))  # noqa: E501

        # Any remaining template functions (imagine empty client case)
        for ti in range(previous_formal_offset+1, len(tfuncs)):
            plan.append(('insert_template_case', ti))

        self.plan = tuple(plan)

    def make_an_index_relating_each_template_function_KEY_to_its_position():
        dct = {k: v for k, v in do_make_index()}
        self.template_function_offset_via_function_key = dct

    def do_make_index():
        funcs = self.t_functions
        for i in range(0, len(funcs)):
            yield funcs[i].all_purpose_function_key, i

    def check_that_the_remaining_chunks_of_both_cases_are_all_test_functions():
        self.t_functions = must_be_all_functions(tscn, tcase, 'template case')
        self.c_functions = must_be_all_functions(cscn, tcase, 'client case')

    def assert_that_the_two_cases_start_with_head_lines_and_stow_them_away():
        self.t_head = must_have_HLs_and_advance(tscn, tcase, 'template case')
        self.c_head = must_have_HLs_and_advance(cscn, ccase, 'client case')

    def must_be_all_functions(scn, case, noun_phrase):
        # Assert that all ZERO or more remaining items in the scan are..
        result = []
        while scn.more:
            if not scn.peek.is_function:
                break
            result.append(scn.next())
        if scn.empty:
            return tuple(result)

        def lines():
            use_np = ''.join((noun_phrase, ' ', repr(case.case_key)))
            yield f"{use_np} needed function here: {case.lines[0]!r}"
        listener('error', 'expression', 'unconventional_looking_case', lines)
        raise stop()

    def must_have_HLs_and_advance(scn, case, noun_phrase):  # #here2
        if scn.empty:
            return
        if 'head_lines' == (act_type := scn.peek.type):
            return scn.next()

        def lines():
            use_np = ''.join((noun_phrase, ' ', repr(case.case_key)))
            yield f"{use_np} can't immediately start with '{act_type}'"
        listener('error', 'expression', 'unconventional_looking_case', lines)
        raise stop()

    cchunx = tuple(_chunks_via_case(ccase))
    tchunx = tuple(_chunks_via_case(tcase))
    cscn = _scanner_via_list(cchunx)
    tscn = _scanner_via_list(tchunx)

    class self:  # #class-as-namespace
        pass

    class stop(RuntimeError):
        pass

    try:
        return main()
    except stop:
        pass


def _chunks_via_case(case):
    before_ks = set((*locals().keys(), 'before_ks'))

    def head_lines(lines):
        return _HeadLines(lines)

    def coarse_def(lines):
        line = lines[0]
        md = _test_not_test_rx.match(line)
        if not md:
            xx(f'oops: {line!r}')
        fname, rest = md.groups()
        if not rest:
            return _OrdinaryFunction(fname, lines)
        md2 = re.match(r'(?P<digits>[0-9]{2,})_(?P<fkey>.+)\Z', rest)
        if not md2:
            xx(f'oops: {fname!r}')
        return _test_function_via_matches(md, md2, lines)

    locs = locals()
    actions = {k: locs[k] for k in (set(locs.keys()) - before_ks)}

    for sx in _coarse_chunks_via_case(case):
        yield actions[sx[0]](*sx[1:])


def _test_function_via_matches(md, md2, lines):
    fbeg, fend = md.span('fname')
    rbeg, rend = md.span('test_rest')
    dbeg, dend = md2.span('digits')
    kbeg, kend = md2.span('fkey')
    dbeg, dend, kbeg, kend = ((i+rbeg) for i in (dbeg, dend, kbeg, kend))
    line = lines[0]
    sx = ('test_function_first_line',  # #here1
          line[0:dbeg],  # pc 1: before digits
          line[dbeg:dend],  # pc 2: digits
          line[dend:kbeg],  # pc 3: between digits and fkey (always '_')
          line[kbeg:kend],  # pc 4: fkey
          line[kend:],  # pc 5: after fkey
          )
    return _TestFunction(_AST_via_sexp(sx), lines)


_test_case_first_line_AST_def = (
    'test_function_first_line',  # #here1
    's',  # pc 1: before digits
    's', 'as', 'digits',  # pc 2
    's',  # pc 3: between digits and fkey (always '_')
    's', 'as', 'fkey',  # pc 4
    's')  # pc 5: after fkey


_test_not_test_rx = re.compile(r'''^
    [ ]{4}def[ ]
    (?P<fname>
        (?: test_ (?P<test_rest> [^(]+)
         |  [^(]+  )
    ) \(
''', re.VERBOSE)


class _Function:

    def __init__(self):
        self._has_directive = None

    # == Directives (doesn't make sense to call these on client test funcs)

    def without_directive(self):  # make it ready to write into output
        if not self.has_directive:
            return self
        new_lines = (self.lines[0], *self.lines[_DI+1:])
        new = self.__class__(self._first_line_AST, new_lines)
        new._has_directive = False
        return new

    @property
    def has_directive(self):
        if self._has_directive is None:
            self._resolve_directive()
        return self._has_directive

    def _resolve_directive(self):
        md = re.match('^[ ]{8}# wicked: (.+)', self.lines[_DI])
        self._has_directive = True if md else False
        if not self._has_directive:
            return
        self._directive_body = md[1]


_DI = 1  # directive offset lol


class _TestFunction(_Function):
    # [ ][ ][ ][ ]def test_0123_chooo_chaaa(fsfseeffe\n

    def __init__(self, ast, lines):
        self._first_line_AST, self.lines = ast, lines
        self._OFAPK = None
        super().__init__()

    # == Updating (doesn't make sense to call these on template test funcs)

    def updated_by(self, otr):
        # For now, updating one function with another (a client function with
        # a template function always) simply means keep your own first line
        # but use ALL the remaining lines of the template function as yours.

        mutable_lines = list(otr.lines)
        mutable_lines[0] = self.lines[0]
        return self.__class__(self._first_line_AST, tuple(mutable_lines))

    # ==

    @property
    def all_purpose_function_key(self):
        if self._OFAPK is None:
            self._OFAPK = ('test_function', self.fkey)
        return self._OFAPK

    @property
    def vernacular_name(self):
        return self.fkey

    @property
    def fkey(self):
        return self._first_line_AST.fkey

    type = 'test_function'
    is_function = True


class _OrdinaryFunction(_Function):

    def __init__(self, fname, lines):
        self.fname, self.lines = fname, lines
        self._OFAPK = None
        super().__init__()

    def updated_by(self, otr):
        # for now let's just meh
        return otr

    @property
    def all_purpose_function_key(self):
        if self._OFAPK is None:
            self._OFAPK = ('ordinary_function', self.fname)
        return self._OFAPK

    @property
    def vernacular_name(self):
        return self.fname

    type = 'ordinary_function'
    is_function = True


_HeadLines = _nt('HeadLines', ('lines',))
_HeadLines.type = 'head_lines'
_HeadLines.is_function = False


# ==

def _AST_via_sexp(sx):
    if (f := _AST_via_sexp).x is None:
        f.x = _build_lazy_AST_classes().AST_via_sexp
    return f.x(sx)


_AST_via_sexp.x = None


def _build_lazy_AST_classes():
    from text_lib.magnetics.ast_via_sexp_via_definition import \
        lazy_classes_collection_via_AST_definitions as func
    return func((_test_case_first_line_AST_def,))


# ==

def _coarse_chunks_via_case(case):
    # Break the body lines of a case class into its function definition runs

    # While asserting that every nonfirst line is either the blank line
    # or indented by at least four spaces, chunk this series of zero or more
    # lines into  [ 'head_lines', [ 'coarse_def' [..]] ]

    cache = []
    scn = _scanner_via_list(case.lines)
    scn.advance()
    while scn.more:
        if _ting_rx.match(scn.peek):
            break
        assert _otr_thing_rx.match(scn.peek)
        cache.append(scn.next())
    if len(cache):
        yield 'head_lines', tuple(cache)
        cache.clear()
    if scn.empty:
        return
    cache.append(scn.next())
    while scn.more:
        if _ting_rx.match(scn.peek):
            yield 'coarse_def', tuple(cache)
            cache.clear()
            cache.append(scn.next())
            continue
        assert _otr_thing_rx.match(scn.peek)
        cache.append(scn.next())
    if not len(cache):
        return
    yield 'coarse_def', tuple(cache)


_ting_rx = re.compile(r'^[ ]{4}def[ ]')
_otr_thing_rx = re.compile(r'^(?:$|[ ]{4})')


def _scanner_via_list(ls):
    from text_lib.magnetics.scanner_via import scanner_via_list as func
    return func(ls)


class _DirectiveError(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(msg or "wee")

# #born
