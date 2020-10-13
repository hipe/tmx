from collections import namedtuple as _nt
import re


STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.csv',)
STORAGE_ADAPTER_IS_AVAILABLE = True
# STORAGE_ADAPTER_UNAVAILABLE_REASON = "it's a placeholder stub"


def COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
        collection_path, listener=None, opn=None, rng=None):

    if hasattr(collection_path, 'fileno'):
        fh = collection_path
        assert 'r' == fh.mode[0]
        assert 0 == fh.fileno()
        return _collection_implementation_via_read_only_stream(fh, listener)

    def when_path(args, monitor):  # #here1
        xx('where')
        assert(0 == len(args))

        class ContextManagerWhenPath:

            def __enter__(self):
                self._close_me = None
                opened = (opn or open)(collection_path)
                self._close_me = opened
                return _traverse_via_upstream(opened, monitor.listener)

            def __exit__(self, *_3):
                if self._close_me is None:
                    return
                self._close_me.close()
                self._close_me = None

        return ContextManagerWhenPath()

    return _CollectionImplementation(when_path)


def _collection_implementation_via_read_only_stream(stdin, _monitor):
    def when_IO(args, monitor):  # #here1
        assert(0 == len(args))

        class ContextManagerWhenSTDIN:
            def __enter__(self):
                return _traverse_via_upstream(stdin, monitor.listener)

            def __exit__(self, *_3):
                pass
        return ContextManagerWhenSTDIN()
    return _CollectionImplementation(when_IO)


class _CollectionImplementation:

    def __init__(self, f):
        raise RuntimeError('away this')
        self._GONE_multi_depth_value_dictionaries_as_storage_adapter = f


def _traverse_via_upstream(*_):
    raise RuntimeError('GONE')


def SCHEMA_AND_ENTITIES_VIA_LINES(lines, listener):

    def main():
        make_sure_there_is_at_least_one_line()
        make_sure_the_line_has_at_least_one_cell_and_note_num_fields()
        make_sure_the_cells_all_translate_to_valid_field_names()
        return _MinimalSchema(self.field_name_keys), entities()

    def entities():
        rang, num, ks = self.range, self.num_fields, self.field_name_keys
        while scn.more:
            line = scn.next()
            line_ast = line_AST_via_line(line)
            cells = line_ast.cells
            if num != len(cells):
                d = counter()
                _whine_about_num_fields_variation(listener, line_ast, d, num)
                break  # provision #here3
            k_v_s = ((ks[i], cells[i].cell_content) for i in rang)

            # [#873.5] no None, no empty string
            yield _MinimalEntity({k: v for k, v in k_v_s if len(v)})

    def make_sure_the_cells_all_translate_to_valid_field_names():
        def is_bad(field_name):
            return False if field_name_rx.match(field_name) else True

        cells = (line_ast := self.first_line_AST).cells
        titles = tuple(cell.cell_content for cell in cells)
        self.range = range(0, self.num_fields)
        bads = tuple(i for i in self.range if is_bad(titles[i]))
        if len(bads):
            _whine_about_bad_field_names(listener, bads, line_ast)
            raise stop()
        scn.advance()

        untitleize = _build_untitleizer()
        self.field_name_keys = tuple(untitleize(title) for title in titles)

    field_name_rx = re.compile(r'''^
        [a-zA-Z]  [a-zA-Z-0-9]*  (?: [ ][a-zA-Z0-9]+ ) *
    \Z''', re.VERBOSE)

    def make_sure_the_line_has_at_least_one_cell_and_note_num_fields():
        first_line = scn.peek
        leng = len((ast := line_AST_via_line(first_line)).cells)
        if 0 == leng:
            xx("blank for first line?")
        self.num_fields = leng
        self.first_line_AST = ast

    def make_sure_there_is_at_least_one_line():
        if scn.empty:
            xx("empty line stream")

    def line_AST_via_line(line):
        spans = tuple(spans_via_line(line))
        cells = tuple(cell_sexps_via_spans(spans, line))  # #wish [#613.1]
        last_end = spans[-1][1] if len(spans) else 0
        return ast_via_sexp(('line', cells, line[last_end:]))

    def cell_sexps_via_spans(spans, line):
        prev = 0
        for beg, end in spans:
            head = line[prev: beg]
            tail = line[beg: end]
            yield 'cell', head, tail
            prev = end

    # == Functions that get built

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    from text_lib.magnetics.ast_via_sexp_via_definition import \
        lazy_classes_collection_via_AST_definitions as func
    ast_via_sexp = func(_AST_definitions()).AST_via_sexp

    spans_via_line = _spans_of_old(throwing_listener)

    # == Other local globals

    scnlib = _scnlib()
    scn = scnlib.scanner_via_iterator(lines)
    counter = scnlib.MUTATE_add_counter(scn)

    # ==

    class self:  # #class-as-namespace
        pass

    class stop(RuntimeError):
        pass

    try:  # #here3
        return main()
    except stop:
        pass


def LINES_VIA_SCHEMA_AND_ENTITIES(schema, ents, listener):

    def titleize(k):  # .. #here2
        words = k.split('_')
        word = words[0]
        use_word = ''.join((word[0].upper(), word[1:]))
        words[0] = use_word
        return ' '.join(words)

    def line_via_fixed_number_of_cell_strings(cells):
        pcs = list(stream_join(cells))
        pcs.append('\n')
        return ''.join(pcs)

    stream_join = _build_stream_join(', ')
    ks = schema.field_name_keys
    labels = (titleize(k) for k in ks)
    yield line_via_fixed_number_of_cell_strings(labels)

    def cell_pcs_via_ent(ent):
        dct = ent.core_attributes_dictionary_as_storage_adapter_entity
        for k in ks:
            s = dct[k]
            assert isinstance(s, str)
            yield s

    count = 0
    for ent in ents:
        count += 1
        pcs = cell_pcs_via_ent(ent)
        yield line_via_fixed_number_of_cell_strings(pcs)

    if not count:
        xx("maybe emit a warny warn")


# == Support

def _build_untitleizer():  # inverse of #here2
    def untitleize(title):
        pcs = title.split(' ')
        return '_'.join(untitleize_piece(pc) for pc in pcs)

    def untitleize_piece(pc):
        return rx.sub(lambda md: md[0].lower(), pc)

    rx = re.compile('(?<![A-Z])[A-Z](?=[a-z])')

    return untitleize


# == Whiners

def _whine_about_num_fields_variation(listener, line_ast, lineno, target_num):

    actual_num = len(line_ast.cells)
    if actual_num < target_num:
        is_under = True
    else:
        assert target_num < actual_num
        is_under = False

    def struct():  # #[#612.5] this simple form of jumble
        return {k: v for k, v in details()}

    def details():
        expecting = f"{target_num} fields (had {actual_num})"
        yield 'expecting', expecting
        yield 'reason', f"Wrong number of fields. (Expecting {expecting})"

        # We don't have to flex like this
        if is_under:
            # If you're under, imagine pointing at the beginning of your last f
            use_i = actual_num - 1
        else:
            # If you're over, point at the beginning of the FIRST over field
            use_i = target_num

        pos, line = _position_of_start_of_this_field(use_i, line_ast)

        # If you were under, point at the char slot AFTER your last surface fie
        if is_under:  # (lol it's just the end of the line but whatever)
            pos += len(line_ast.cells[use_i]._to_string())

        yield 'pos', pos
        yield 'line', line

    listener('error', 'structure', 'variation_in_number_of_fields', struct)


def _whine_about_bad_field_names(listener, bads, line_ast):

    bad_i = bads[0]
    beg, first_line = _position_of_start_of_this_field(bad_i, line_ast)
    content = line_ast.cells[bad_i].cell_content

    if True:
        def payloader():
            o = {}
            x = repr(content)
            o['reason'] = f'for now, CSV headers must be [a-z_]+ (had {x})'
            o['line'] = first_line
            o['lineno'] = 1
            o['position'] = beg
            return o
        listener('error', 'structure', 'bad_CSV_header', payloader)


def _position_of_start_of_this_field(cell_offset, line_ast):
    # Adventure mode to reconstruct the line and position of first failure
    # Because OCD we also return the reconstructed whole line (we always want)

    cells = line_ast.cells
    pcs = (*(cell._to_string() for cell in cells), line_ast.line_tail)
    from functools import reduce
    pos = reduce(lambda m, i: m+len(pcs[i]), range(0, cell_offset), 0)
    return pos, ''.join(pcs)


# == Historic

def _spans_of_old(throwing_listener):

    from text_lib.magnetics.string_scanner_via_string import \
        StringScanner as string_scanner_via, \
        pattern_via_description_and_regex_string as o

    zero_or_more_not_special = o('zero or more not special', r'[^,"\\\n\r]*')
    one_or_more_spaces = o('one or more spaces', '[ ]+')

    def spans_via_line(line):

        scn = string_scanner_via(line, throwing_listener)
        begin_pos = scn.pos
        while True:
            scn.skip_required(zero_or_more_not_special)
            if scn.empty:
                xx("line ended without a terminating newline")
            end_pos = scn.pos
            yield begin_pos, end_pos
            char = line[end_pos]

            if ',' == char:
                scn.advance_by_one()
                scn.skip(one_or_more_spaces)
                if scn.empty:
                    xx()
                begin_pos = scn.pos
                continue

            if '\n' == char:
                scn.advance_by_one()
                assert scn.empty
                break

            if '"' == char:
                xx("have fun parsing escaped quotes")

            xx(f"unexpected character {char!r}")

    return spans_via_line


# == Models

_MinimalSchema = _nt('MiniamSchema', ('field_name_keys',))
_MinimalEntity = _nt('MinimalEntity', ('core_attributes_dictionary_as_storage_adapter_entity',))  # noqa: E501


def _AST_definitions():
    yield 'line', 'sexps', 'as', 'cells', 's', 'as', 'line_tail'
    yield 'cell', 's', 's', 'as', 'cell_content'


# == Low-level might abstract

def _build_stream_join(sep):
    def stream_join(itr):  # :[#612.4] near [#611] things we do with scanners
        scn = func(itr)
        yield scn.next()  # ..
        while True:  # ..
            yield sep
            yield scn.next()
            if scn.empty:
                break

    func = _scnlib().scanner_via_iterator
    return stream_join


# == Lazy imports

def _scnlib():
    import text_lib.magnetics.scanner_via as module
    return module


def xx(msg=None):
    raise RuntimeError(msg or "write me")


""" NOTE #here3: We certainly don't read every line/record into memory before
returning. This code is evaluated at traversal time ("lazily") in the context
of the client. Therefor, to raise a `stop()` here wouldn't be caught by our
try/except clause below and would violate the main contract of this idiom:
that such exceptions are a private implementation detail of the module they
are defined / thrown in.

Furthermore, there is no reason to want to raise a want a `stop()` here,
because the only purpose of that idiom is to facilitate unobtrusive withdrawal
when we encouter errors at call time. This is a traversal-time error which has
different constraints.
"""

# #history-A.1 spike initial sketch
# #born as nonworking stub
