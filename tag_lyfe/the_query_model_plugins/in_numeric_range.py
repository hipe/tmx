from tag_lyfe.the_query_model import in_subtree_match_any_one_
from tag_lyfe import pop_property
import re


class UnsanitizedInRange:

    def __init__(self, begin_AST, end_AST):
        self._begin_easy_number = begin_AST
        self._end_easy_number = end_AST

    def sanitize_plus(self, listener, tagging_query):
        beg = pop_property(self, '_begin_easy_number')
        end = pop_property(self, '_end_easy_number')
        beg_num = beg._number
        end_num = end._number
        NOT_NECESSARILY_VALID = _InRangeFunction(beg, end, tagging_query)
        if beg_num >= end_num:
            def _():
                _head = tagging_query.to_string()
                _bad_tail = NOT_NECESSARILY_VALID.to_string()
                good_head = f'{_head} in '
                yield f'end must be greater than beginning ({beg_num!r} is not less than {end_num!r})'  # noqa: E501
                yield f'{good_head}{_bad_tail}'
                bars = '-' * len(good_head)
                yield f'{bars}^'

            listener('error', 'expression', 'parse_error', 'backwards_range', _)  # noqa: E501
        else:
            return NOT_NECESSARILY_VALID  # now it's valid


class _InRangeFunction:

    def __init__(self, beg, end, tagging_query):

        beg_num = beg._number
        end_num = end._number

        def f(tagging):
            subtagging = tagging_query.dig_recursive_(tagging)
            if subtagging is None:
                xx('no such sub tagging')
            elif subtagging.is_deep:  # then it has a value (child)
                subsubtagging = subtagging.subcomponents[0]
                needle = subsubtagging.body_slot.self_which_is_string
                md = _number_rx.search(needle)
                if md is None:
                    # tagging value does not look like num (Case7020)
                    pass
                else:
                    int_part, float_part = md.groups()
                    if float_part is None:
                        use_number = int(md[0])
                    else:
                        use_number = float(md[0])
                    if use_number < beg_num:
                        pass  # too low (Case7030)
                    elif use_number <= end_num:
                        return True
                    else:
                        pass  # too high (Case7040)
            else:
                xx('tagging has no value')

        self._test = f
        self._begin = beg
        self._end = end

    def yes_no_match_via_tag_subtree(self, subtree):
        return in_subtree_match_any_one_(subtree, self._test)

    def wordables_(self):  # hook-in for [#707.F] wordables
        yield self

    def to_string(self):
        return f'{self._begin._string}..{self._end._string}'


_number_rx = re.compile(r'^(-?\d+)(\.\d+)?$')


class EasyNumber:

    def __init__(self, number, string):
        self._number = number
        self._string = string


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #born.
