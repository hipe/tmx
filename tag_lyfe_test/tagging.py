class TaggingCommonCase:

    def test_100(self):

        # == TODO: break this all down
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

        print(f"\nEXP: {expected_fingerprint}")
        print(f"ACT: {actual_fingerprint}")
        if expected_fingerprint != actual_fingerprint:
            print("\n\nNOT THE SAME!\n\n")

        # == TODO: end break this all down

# #born.
