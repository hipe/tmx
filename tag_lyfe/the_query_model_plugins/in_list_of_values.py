from tag_lyfe.the_query_model import (
        in_subtree_match_any_one_,
        wordable_via_string_)
from tag_lyfe import (
        pop_property)


class UnsanitizedInValuesFunction:

    def __init__(self, strings):
        self._strings = strings

    def sanitize_plus(self, listener, tagging_query):
        return _InValuesFunction(pop_property(self, '_strings'), tagging_query)


class _InValuesFunction:

    def __init__(self, strings, tagging_query):

        def f(tagging):
            subtagging = tagging_query.dig_recursive_(tagging)
            if subtagging is None:
                return  # (Case6020)
            elif subtagging.is_deep:  # then it has a value (child)
                subcomponents = subtagging.subcomponents
                subsubtagging = subcomponents[0].body_slot
                needle = subsubtagging.self_which_is_string  # ..
                if needle in strings:  # (easy for now)
                    if 1 < len(subcomponents):
                        return True  # (Case6060) hi.
                    else:
                        return True  # (Case6050) hi.
                else:
                    return False  # (Case6040)
            else:
                return  # (Case6030)

        self._test = f
        self._tagging_query = tagging_query
        self._strings = strings

    def yes_no_match_via_tag_subtree(self, subtree):
        return in_subtree_match_any_one_(subtree, self._test)

    def wordables_(self):  # hook-in for [#707.F] wordables
        yield _open_paren_wordable
        for s in self._strings:
            yield wordable_via_string_(s)  # ick/meh
        yield _close_paren_wordable


_open_paren_wordable = wordable_via_string_('(')
_close_paren_wordable = wordable_via_string_(')')


# #born.
