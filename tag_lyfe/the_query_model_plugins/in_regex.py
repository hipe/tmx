from tag_lyfe.the_query_model import in_subtree_match_any_one_


class UnsanitizedInRegex:

    def __init__(self, hacky_string):
        self._hacky_string = hacky_string

    def sanitize_plus(self, listener, tagging_query):

        # (at writing you can assume the hacky string has at least 1 char)

        self._tagging_query = tagging_query
        self._listener = listener

        s = self._hacky_string
        del self._hacky_string

        last_char = s[-1]

        if '/' == last_char:
            self._regex_string = s[0:-1]  # don't use the ending elimiter
            self._end_delimiter = last_char
            if 0 == len(self._regex_string):
                self._when_empty_regexp()
            else:
                return self._when_maybe_OK()
        else:
            self._regex_string = s  # use the whole string
            self._end_delimiter = ''
            self._when_no_ending_delimiter_found()

    def _when_maybe_OK(self):
        import re
        e = None
        try:
            rx = re.compile(self._regex_string)
        except re.error as e_:
            e = e_
            pass
        if e is None:
            return _InRegexFunction(rx, self._regex_string, self._tagging_query)  # noqa: E501
        else:
            self._when_regex_compile_error(e)

    def _when_regex_compile_error(self, e):
        def plus_or_minus(length):
            # back the arrowhead off of the entire regex, so it points at '/'
            _offset = -1 * len(self._regex_string)
            # advance the arrowhead to points to whatever is being referred to
            return e.pos + _offset - 1
        self._bad_regex(str(e), plus_or_minus)

    def _when_no_ending_delimiter_found(self):
        self._bad_regex("no ending delimiter found. expecting '/'", 1)

    def _when_empty_regexp(self):
        self._bad_regex('empty regex not allowed', 0)

    def _bad_regex(self, line1, plus_or_minus):

        def _():
            # awful. meh
            _ = self._tagging_query.to_string()
            _1 = f'{_} in /'
            if callable(plus_or_minus):
                use_plus_or_minus = plus_or_minus(len(_1))
            else:
                use_plus_or_minus = plus_or_minus - 1  # ????
            _2 = self._regex_string
            _3 = self._end_delimiter
            line2 = f'{_1}{_2}{_3}'
            _bars = '-' * (len(line2) + use_plus_or_minus)
            line3 = f'{_bars}^'
            yield line1
            yield line2
            yield line3
        self._listener('error', 'expression', 'parse_error', 'bad_regex', _)


class _InRegexFunction:

    def __init__(self, rx, rx_string, tagging_query):

        def f(tagging):
            subtagging = tagging_query.dig_recursive_(tagging)
            if subtagging is None:
                xx('no such sub tagging')
            elif subtagging.is_deep:  # then it has a value (child)
                subsubtagging = subtagging.subcomponents[0]
                needle = subsubtagging.body_slot.self_which_is_string
                md = rx.search(needle)
                if md is None:
                    pass  # (Case8020)
                else:
                    return True
            else:
                xx('tagging has no value')  # #cp

        self._test = f
        self._regex_string = rx_string

    def yes_no_match_via_tag_subtree(self, subtree):
        return in_subtree_match_any_one_(subtree, self._test)

    def to_words(self):
        return (self.to_string(),)

    def to_string(self):
        return f'/{self._regex_string}/'


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #born.
