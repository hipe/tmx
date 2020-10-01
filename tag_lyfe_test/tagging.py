from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject


class TaggingCommonCase:

    def expect_shadow(self, expected_shadow):
        ascii_pieces = []
        top_thing = self.end_state

        def sep():
            ascii_pieces.append('s' * len(s))

        def tag():
            _ = ast._to_string()
            ascii_pieces.append('T' * len(_))

        for doc_pair in top_thing.doc_pairs:
            s = doc_pair.not_tag
            ast = doc_pair.tag
            if ast is None:
                sep()
            else:
                sep()
                tag()

        actual_shadow = ''.join(ascii_pieces)

        if self.do_trace_only:
            print(f"\nEXP: «{expected_shadow}»")
            print(f"ACT: «{actual_shadow}»")
        else:
            self.assertEqual(actual_shadow, expected_shadow)

    @property
    def end_state(self):
        return self._build_end_state()

    def _build_end_state(self):

        _given_string = self.given_string()
        from tag_lyfe.magnetics import tagging_subtree_via_string as mag

        return mag.doc_pairs_via_string(_given_string)

    do_trace_only = False


class _MetaClass(type):  # #cp

    def __init__(cls, name, bases, clsdict):
        if len(cls.mro()) > 2:
            _add_common_case_memoizing_methods(cls)
        super().__init__(name, bases, clsdict)


def _add_common_case_memoizing_methods(cls):
    @shared_subject
    def end_state(self):
        return self._build_end_state()
    cls.end_state = end_state


class TaggingCommonCasePlusMemoization(
        TaggingCommonCase,
        metaclass=_MetaClass,
        ):
    pass


# #born.
