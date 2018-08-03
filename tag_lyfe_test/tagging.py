from modality_agnostic.memoization import (  # noqa: E402
        dangerous_memoize as shared_subject,
        )


class TaggingCommonCase:

    def expect_shadow(self, expected_shadow):

        ascii_pieces = []

        _doc_pairs = self.end_state()  # ..

        def sep():
            ascii_pieces.append('s' * len(doc_pair.separator_string))

        def tag():
            _ = doc_pair.tagging.to_string()
            ascii_pieces.append('T' * len(_))

        for _ in _doc_pairs:
            doc_pair = _
            if doc_pair.is_end_piece:
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

    def _build_end_state(self):
        return tuple(super()._build_end_state())


# #born.
