def assert_sequence_equals_recursive(act, exp, tc, depth=0):  # depth not used
    for i in range(0, max(len(act), len(exp))):
        act_ = act[i]
        exp_ = exp[i]
        if isinstance(exp_, str):
            tc.assertEqual(act_, exp_)
        elif isinstance(exp_, tuple):
            tc.assertIsInstance(act_, tuple)
            assert_sequence_equals_recursive(act_, exp_, tc, depth+1)
        else:
            assert(exp_ is None)
            tc.assertIsNone(act_)


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

    from modality_agnostic import io as io_lib
    _spy_IO = io_lib.write_only_IO_proxy(write=write)

    return lines, _spy_IO
    # (abstracted at #history-A.1)


class _UNINDENT_SINGLETON:
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


unindent = _UNINDENT_SINGLETON()

# #history-A.1
# #abstracted.
