import re


def updated_file_blocks_via_(plan, listener):
    before_ks = set((*locals().keys(), 'before_ks'))

    def merge_head_blocks(cb, tb):
        return same_merge(cb, tb)  # hi.

    def merge_tail_blocks(cb, tb):
        return same_merge(cb, tb)  # hi.

    def update_client_case_with_template_case(ci, ti):
        ccase = client_maybe_cases[ci]
        tcase = template_cases[ci]
        from ._updated_case_via_two_cases import updated_case_via_ as func
        nu_case = func(ccase, tcase, throwing_listener)
        use(nu_case)

    def insert(offset):
        use(plan.template_cases[offset])

    def insert_block(tb):
        use(tb)  # hi.

    locs = locals()
    actions = {k: locs[k] for k in (set(locs.keys()) - before_ks)}

    def same_merge(cb, tb):
        # At writing, this is our experimental behavior for both the header
        # and the footer, when we have a merge:

        # 1) If the template block has marked itself as default, stand down
        if tb.has_directive:
            assert 'default' == tb._directive_body
            return use(cb)

        # 2) If the code looks the same ignoring comments & w.s, stand down
        if _blocks_are_same_ignoring_comments_and_whitespace(cb, tb):
            return use(cb)

        # 3), otherwise (YIKES) overwrite whatever is there
        if tb.has_directive:
            tb = tb.without_directive()
        use(tb)

    client_maybe_cases = plan.client_maybe_cases
    template_cases = plan.template_cases

    def use(block):
        result_blocks.append(block)  # hi.

    result_blocks = []

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    class stop(RuntimeError):
        pass

    try:
        for (action_k, *args) in plan.steps:
            actions[action_k](*args)
        return tuple(result_blocks)
    except stop:
        pass


def _blocks_are_same_ignoring_comments_and_whitespace(cb, tb):
    def is_code(line):
        if '\n' == line:
            return
        return not re.match('^[ ]*#', line)

    def code_lines_via_lines(lines):
        return (line for line in lines if is_code(line))

    cscn = _scanner_via_iterator(code_lines_via_lines(cb.lines))
    tscn = _scanner_via_iterator(code_lines_via_lines(tb.lines))

    while True:
        if cscn.empty:
            if tscn.empty:
                return True
            return False
        elif tscn.empty:
            return False
        c_code_line = cscn.next()
        t_code_line = tscn.next()
        if t_code_line != c_code_line:
            return False
    assert()


def plan_via_client_and_template_blocks_(cblx, tblx, listener):  # #testpoint
    def main():
        lop_off_any_first_and_last_plains()
        index_the_template_cases_ensuring_no_collisions_or_plains()
        walk_each_client_block_ensuring_many_things()
        self.head_plan = decide_head_plan()
        self.tail_plan = decide_tail_plan()
        return assemble_the_final_plan()

    def assemble_the_final_plan():
        hp, tp = self.head_plan, self.tail_plan
        head_plan_pcs, tail_plan_pcs = ((() if pl is None else (pl,)) for pl in (hp, tp))  # noqa: E501
        final_plan = (*head_plan_pcs, *self.cases_plan, *tail_plan_pcs)
        return _FilePlan(
            final_plan, self.client_maybe_cases, self.template_cases)

    def decide_tail_plan():
        cb, tb = self.client_tail_plain_block, self.template_tail_plain_block
        if cb is None:
            if tb is None:
                return
            return 'insert_block', tb
        if tb is None:
            return 'pass_through_client_plain', cb
        return 'merge_tail_blocks', cb, tb

    def decide_head_plan():
        cb, tb = self.client_head_plain_block, self.template_head_plain_block
        if cb is None:
            if tb is None:
                return
            return 'insert_block', tb
        if tb is None:
            return 'pass_through_client_plain', cb
        return 'merge_head_blocks', cb, tb

    def walk_each_client_block_ensuring_many_things():
        plan = []

        t_cases = self.template_cases
        t_case_offset_via_key = self.template_case_offset_via_case_key
        c_maybe_cases = self.client_maybe_cases

        offset_of_prev_template_case = -1
        seen_client_case = set()

        for ci in range(0, len(c_maybe_cases)):
            ccase = c_maybe_cases[ci]

            # If the client block is plain text, experimentally pass thru
            if 'test_case' != ccase.type:
                assert 'plain' == ccase.type
                plan.append(('pass_through_client_plain', ci))
                continue

            ck = ccase.case_key
            ti = t_case_offset_via_key.get(ck)

            # If client block is a case with strange key...........
            if ti is None:
                xx('cover case of client block with strange key')

            # Now, client case matches up with a template case

            # If we don't check key dups, other error messages sound confusing
            if ck in seen_client_case:
                xx('cover me: duplicate client case key')
            seen_client_case.add(ck)

            # The offset into the template cases OF the client case key
            # must be greater than the last template case we processed,
            # otherwise the client cases are "out of order" (that is, we
            # have no good algorithm to use to fold-in new template cases).

            if not (offset_of_prev_template_case < ti):
                xx('cover client cases out of order')

            # Insert any new cases to insert
            first_template_case_to_insert = offset_of_prev_template_case + 1
            for i in range(first_template_case_to_insert, ti):
                plan.append(('insert_case', i))
            offset_of_prev_template_case = ti

            # Always one merge! one for every client case
            plan.append(('update_client_case_with_template_case', ci, ti))

        # Flush out the {all|[any] remaining} template cases you didn't process
        for ti in range(offset_of_prev_template_case+1, len(t_cases)):
            plan.append(('insert', ti))

        self.cases_plan = tuple(plan)

    def index_the_template_cases_ensuring_no_collisions_or_plains():
        dct = {}  # case offset via case key
        maybe_cases = self.template_maybe_cases
        del self.template_maybe_cases
        for i in range(0, len(maybe_cases)):
            case = maybe_cases[i]
            if 'test_case' != case.type:
                xx("cover this: plain block in template")
            k = case.case_key
            if k in dct:
                xx("cover this: template case key collision")
            dct[k] = i
        self.template_case_offset_via_case_key = dct
        self.template_cases = maybe_cases

    def lop_off_any_first_and_last_plains():
        cindex = _DOM_index(cblx)
        tindex = _DOM_index(tblx)
        self.client_head_plain_block = cindex.head_plain_block
        self.client_tail_plain_block = cindex.tail_plain_block
        self.template_head_plain_block = tindex.head_plain_block
        self.template_tail_plain_block = tindex.tail_plain_block
        self.client_maybe_cases = cblx[cindex.cases_begin:cindex.cases_end]
        self.template_maybe_cases = tblx[tindex.cases_begin:tindex.cases_end]

    def check_arg(block):
        assert isinstance(block, tuple)
        if not len(block):
            return
        if block[-1].type not in ('plain', 'test_case'):
            raise AssertionError(f"oops: {block[-1].type!r}")

    check_arg(cblx)
    check_arg(tblx)

    class self:  # #class-as-namespace
        pass

    return main()


class _DOM_index:
    # Experimentally we allow zero or one plain block at the beginning and
    # end of files. (In practice, such blocks are always employed.)

    # Because merging is annoying/impossible without following the
    # "ordered subset" algorithm, we do NOT allow plain blocks anywhwere
    # else besides being head-anchored or tail-anchored. Checked elsewhere

    def __init__(o, blocks):
        leng = len(blocks)
        o.head_plain_block, o.tail_plain_block = None, None
        o.cases_begin, o.cases_end = 0, leng  # not guaranteed

        # If no blocks at all, done
        if not leng:
            return

        # If the first block is plain, advance the begin pointer
        if (block := blocks[0]).is_plain:
            o.head_plain_block = block
            o.cases_begin += 1

        # If that was the only block in the whole shebang, you're done
        if 1 == leng:
            return

        # If the last block is plain, back the end pointer up by one
        if (block := blocks[o.cases_end-1]).is_plain:
            o.tail_plain_block = block
            o.cases_end -= 1


def file_DOM_via_lines_(lines, path):
    return file_DOM_via_blocks_(tuple(_blocks_via_lines(lines)), path)


class file_DOM_via_blocks_:
    def __init__(self, blocks, path):
        self.blocks, self.path = blocks, path

    def to_lines(self):
        return (line for block in self.blocks for line in block.lines)


def _blocks_via_lines(lines):  # #testpoint
    p = _parser(lines)
    while p.more:
        if (block := p.any_block_of_other_lines()):
            yield block
            if p.empty:
                break
        yield p.parse_block_of_case_lines()


def _parser(lines):  # parse the one kind or the other kind
    def any_block_of_other_lines(_):  # assume more
        cache = []
        while True:
            if (md := case_line_easy_rx.match(scn.peek)) is not None:
                md = case_line_hard_rx.match(scn.peek)
                assert md
                self._last_match = md
                break
            cache.append(scn.next())
            if scn.empty:
                break
        if not len(cache):
            return
        return _PlainBlock(tuple(cache))

    def parse_block_of_case_lines(_):
        cache = [scn.next()]
        md = self._last_match
        del self._last_match
        while True:
            do_stop = re.match(r'^[^ \n]', scn.peek)
            if do_stop:
                break
            cache.append(scn.next())
            if scn.empty:
                break
        return _case_block_via_md_and_lines(md, tuple(cache))

    case_line_easy_rx = re.compile('^class Case')
    case_line_hard_rx = re.compile(r"""^
        class[ ]
        Case(?P<case_number>[0-9N]{4})
        _
        (?P<case_key>[^(:]+)\(CommonCase\):$
    """, re.VERBOSE)
    scn = _scanner_via_iterator(lines)

    class parser:
        @property
        def more(_):
            return scn.more

        @property
        def empty(_):
            return scn.empty
    self = parser

    parser.any_block_of_other_lines = any_block_of_other_lines
    parser.parse_block_of_case_lines = parse_block_of_case_lines

    return parser()


def _case_block_via_md_and_lines(md, lines):
    line = lines[0]
    sx = ['test_case_first_line']
    beg, end = md.span('case_number')
    sx.append(line[0:beg])
    sx.append(line[beg:end])
    beg, end_ = md.span('case_key')
    sx.append(line[end:beg])
    sx.append(line[beg:end_])
    sx.append(line[end_:])
    return _CaseBlock(_AST_via_sexp(tuple(sx)), lines)


# ==

class _FilePlan:
    def __init__(self, steps, client_maybe_cases, template_cases):
        self.steps = steps
        self.client_maybe_cases = client_maybe_cases
        self.template_cases = template_cases


class _CaseBlock:

    def __init__(self, ast, lines):
        self._AST = ast
        self.lines = lines

    def update(self, otr):  # Use the case number of the other
        use_this = otr.case_number
        sx = list(self._AST._sexp)
        sx[2] = use_this
        ast = self._AST.__class__(tuple(sx))
        lines = list(self.lines)
        lines[0] = ast._to_string()
        return self.__class__(ast, tuple(lines))

    def to_debugging_lines(self):
        yield f"CASE block ({len(self.lines)} lines):\n"
        yield f"  FIRST LINE: {self.lines[0]!r}\n"

    @property
    def case_key(self):
        return self._AST.case_key

    @property
    def case_number(self):
        return self._AST.case_num

    @property
    def first_line_AST_(self):
        return self._AST

    is_plain = False
    type = 'test_case'


def _AST_via_sexp(sx):
    if (f := _AST_via_sexp).x is None:
        f.x = _build_lazy_AST_classes().AST_via_sexp
    return f.x(sx)


_AST_via_sexp.x = None


def _build_lazy_AST_classes():
    from text_lib.magnetics.ast_via_sexp_via_definition import \
        lazy_classes_collection_via_AST_definitions as func
    return func(_sexp_definitions())


def _sexp_definitions():
    yield ('test_case_first_line',
           's',
           's', 'as', 'case_num',  # #here1
           's',
           's', 'as', 'case_key',
           's')


class _PlainBlock:
    def __init__(self, lines):
        self.lines = lines
        self._has_directive = None

    # == Directives (similar to function-level items in sibling)

    def without_directive(self):  # make it ready to write into output
        if not self.has_directive:
            return self
        new = self.__class__(self.lines[1:])
        new._has_directive = False
        return new

    @property
    def has_directive(self):
        if self._has_directive is None:
            self._resolve_directive()
        return self._has_directive

    def _resolve_directive(self):
        md = re.match('^# wicked: (.+)', self.lines[0])
        self._has_directive = True if md else False
        if not self._has_directive:
            return
        self._directive_body = md[1]

    # ==

    def to_debugging_lines(self):
        yield f"PLAIN block ({len(self.lines)} lines)\n"
        yield f"  FIRST LINE: {self.lines[0]!r}\n"

    is_plain = True
    type = 'plain'


def _scanner_via_iterator(itr):
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func(itr)


def xx(msg=None):
    raise RuntimeError(msg or "wee")

# #born
