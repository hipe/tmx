from _common_state import (
        fixture_directory,
        )
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )
import unittest


_CommonCase = unittest.TestCase


class Case162_MONO_CASE(_CommonCase):

    def test_100_lines_are_okay_probably(self):
        lines, _, _ = self.custom_end_state()
        self.assertEqual(lines[0].index('digraph g {'), 0)
        self.assertIn(len(lines), range(17, 30))

    def test_150_lines_are_NOT_newline_terminated(self):
        lines, _, _ = self.custom_end_state()
        self.assertEqual(lines[0], 'digraph g {')
        self.assertEqual(lines[-1], '}')

    def test_200_emits_a_summary(self):
        _, payloader_BE_CAREFUL_HOT, chan = self.custom_end_state()
        self.assertSequenceEqual(chan, ('info', 'structure', 'summary'))
        sct = payloader_BE_CAREFUL_HOT()
        import re
        md = re.match(
                r'^graph reflects relationships among (\d+) fragments\.$',
                sct['message'])
        self.assertIn(int(md[1]), range(6, 10))

    @shared_subject
    def custom_end_state(self):

        directory = fixture_directory('collection-00500-intro')

        from pho.magnetics_.graph_via_collection import (
            output_lines_via_collection_path)

        def run(listener):
            _itr = output_lines_via_collection_path(directory, listener)
            return tuple(_itr)  # you have to do it in here to reach the emits

        from modality_agnostic.test_support import (
                structured_emission as se_lib)

        listener, payloader = se_lib.listener_and_emissioner_for(self)
        lines = run(listener)
        chan, payloader_BE_CAREFUL_HOT = payloader()

        return lines, payloader_BE_CAREFUL_HOT, chan


if __name__ == '__main__':
    unittest.main()

# #born.
