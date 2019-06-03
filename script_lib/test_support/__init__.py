class _UNINDENT_SINGLETON:
    # experiment in OCD in how we implement this, all just not to load re

    def __init__(self):
        self._is_first_call = True

    def __call__(self, s):  # s = big string
        if '' == s:
            return  # (Case407_120 in kiss_rdb_test (at writing))

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

# #abstracted.
