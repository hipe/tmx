from tag_lyfe.the_query_model import (
        in_subtree_match_any_one_,
        wordable_via_string_,
        )
from tag_lyfe import (
        pop_property,
        )


class UnsanitizedInValuesFunction:

    def __init__(self, strings):
        self._strings = strings

    def sanitize_plus(self, listener, tagging_query):
        return _InValuesFunction(pop_property(self, '_strings'), tagging_query)


class _InValuesFunction:

    def __init__(self, strings, tagging_query):

        def f(tagging):
            sub_tagging = tagging_query.dig_recursive_(tagging.root_node)
            if sub_tagging is None:
                return  # #coverpoint1.13.2
            elif sub_tagging.is_deep:  # then it has a value (child)
                sub_sub_tagging = sub_tagging.child
                needle = sub_sub_tagging.tag_stem
                if needle in strings:  # (easy for now)
                    if sub_sub_tagging.is_deep:
                        return True  # #coverpoint1.13.6 hi.
                    else:
                        return True  # #coverpoint1.13.5 hi.
                else:
                    return False  # #coverpoint1.13.4
            else:
                return  # #coverpoint1.13.3

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