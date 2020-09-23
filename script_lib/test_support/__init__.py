def lines_and_spy_io_for_test_context(tc, dbg_msg_head):  # #:[#605.1]
    lines = []

    assert(not hasattr(tc, 'is_first_debug'))
    tc.is_first_debug = True

    def write(s):
        assert(re.match(r'[^\r\n]*\n\Z', s))  # [#607.I]
        if tc.do_debug:
            from sys import stderr
            if tc.is_first_debug:
                tc.is_first_debug = False
                stderr.write('\n')  # _eol
            stderr.write(f"{dbg_msg_head}{s}")
        lines.append(s)
        return len(s)
    import re

    from modality_agnostic import write_only_IO_proxy
    _spy_IO = write_only_IO_proxy(write=write)

    return lines, _spy_IO
    # (abstracted at #history-A.1)


class _build_unindent:
    # experiment in OCD in how we implement this, all just not to load re

    def __init__(self):
        self._is_first_call = True

    def __call__(self, s):  # s = big string

        if '' == s:
            return  # (Case4258KR)

        import re

        if self._is_first_call:
            self._is_first_call = False
            self._the_first_run_of_whitespace_rx = re.compile(r'^(\n)([ ]+)')
            self._line_rx = re.compile('([^\n]*\n)')

        md = self._the_first_run_of_whitespace_rx.match(s)

        margin = md[2]

        margin_rx = re.compile(margin)  # yikes

        length = len(s)
        cursor = md.end(1)

        line_rx = self._line_rx

        while True:
            # advance over the margin
            md = margin_rx.match(s, cursor)
            if md is not None:
                # if it didn't match then there's blank line
                cursor = md.end()
            if length == cursor:
                break
            md = line_rx.match(s, cursor)
            yield md[1]
            cursor = md.end()


unindent = _build_unindent()

# assert_sequence_equals_recursive moved to client at #history-B.2.1

# #history-B.2.1
# #history-A.1
# #abstracted.
