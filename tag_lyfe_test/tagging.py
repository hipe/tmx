class TaggingCommonCase:

    def test_100_shadow(self):

        ascii_pieces = []

        _given_string = self.given_string()
        from tag_lyfe.magnetics import tagging_subtree_via_string as mag

        _doc_pairs = mag.doc_pairs_via_string(_given_string)

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

        actual_fingerprint = ''.join(ascii_pieces)
        expected_fingerprint = self.expect_shadow()

        if self.do_trace_only:
            print(f"\nEXP: «{expected_fingerprint}»")
            print(f"ACT: «{actual_fingerprint}»")
        else:
            self.assertEqual(actual_fingerprint, expected_fingerprint)

    do_trace_only = False

# #born.
