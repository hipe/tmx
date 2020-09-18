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
        self.multi_depth_value_dictionaries_as_storage_adapter = f


def _traverse_via_upstream(opened, listener):

    pairs_via_line = __pairserer(listener)

    is_empty = True
    for first_line in opened:  # #once
        first_pairs = pairs_via_line(first_line)
        is_empty = False
        lineno = 1
        break

    if is_empty:
        return

    keys = __for_now_extremely_strict(first_pairs, first_line, listener)
    if keys is None:
        return

    num_cels_required = len(first_pairs)
    rang = range(0, num_cels_required)

    for line in opened:
        lineno += 1
        pairs = pairs_via_line(line)

        leng = len(pairs)
        if leng != num_cels_required:
            xx()

        dct = {}  # used to do comprehension but it got too crazy
        for i in rang:
            beg, end = pairs[i]
            if beg == end:
                continue  # [#873.5] no None, no empty string
            content = line[beg:end]
            dct[keys[i]] = content
        yield dct


def __for_now_extremely_strict(pairs, first_line, listener):

    result = []  # ick/meh

    import re
    rx = re.compile(r'[a-z_]+$')

    for beg, end in pairs:
        content = first_line[beg:end]
        if rx.match(content):
            result.append(content)
            continue

        def payloader():
            o = {}
            x = repr(content)
            o['reason'] = f'for now, CSV headers must be [a-z_]+ (had {x})'
            o['line'] = first_line
            o['lineno'] = 1
            o['position'] = beg
            return o
        listener('error', 'structure', 'bad_CSV_header', payloader)
        return

    return tuple(result)


def __pairserer(listener):

    from kiss_rdb.magnetics.string_scanner_via_string import (
            StringScanner, pattern_via_description_and_regex_string as o)

    zero_or_more_not_special = o('zero or more not special', r'[^,"\\\n\r]*')
    one_or_more_spaces = o('one or more spaces', '[ ]+')

    def pairser(line):
        pairs = []

        scn = StringScanner(line, listener)
        begin_pos = scn.pos
        while True:
            w = scn.skip_required(zero_or_more_not_special)
            assert(w is not None)
            if scn.empty:
                xx()  # line ended without a terminating newline
            end_pos = scn.pos
            pairs.append((begin_pos, end_pos))
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
                assert(scn.empty)
                break

            if '"' == char:
                xx()

            xx()

        return tuple(pairs)
    return pairser


def xx():
    raise Exception('write me')

# #history-A.1 spike initial sketch
# #born as nonworking stub
