from tag_lyfe.the_query_model import in_subtree_match_any_one_


class UnsanitizedInValuesFunction:

    def __init__(self, strings):
        self._strings = strings

    def sanitize_plus(self, listener, tagging_query):
        ss = self._strings
        del self._strings
        return _InValuesFunction(ss, tagging_query)


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

    def to_words(self):
        yield '('
        for w in self._strings:
            yield w
        yield ')'


# #born.
