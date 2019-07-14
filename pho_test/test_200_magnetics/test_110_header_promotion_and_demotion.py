from pho_test import document_state as doc_state_lib
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


class _CommonCase(unittest.TestCase):

    def build_state(self):
        return doc_state_lib.document_state_via_fragments(
                self.given_fragments())


# (110-119)

class Case112_one_fragment_with_heading_and_leading_header(_CommonCase):

    def test_100_heading_of_first_fragment_becomes_doc_title(self):
        self.assertEqual(self.state.document_title, 'dogs are great')

    def test_200_header_gets_pushed_down_one_level(self):  # provision [#883.3]
        self.assertEqual(self.state.first_section.header.depth, 2)

    def test_300_header_gets_pushed_down_for_subsequent_section(self):
        self.assertEqual(self.state.section_at(1).header.depth, 2)

    @property
    @shared_subject
    def state(self):
        return self.build_state()

    def given_fragments(self):
        yield 'dogs are great', ('#ha ha', 'so good', '#h3', 'yup')


class Case115_nonfirst_fragment_headings(_CommonCase):

    def test_100_turn_nonfirst_fragment_heading_into_header(self):
        self.assertEqual(self._this_header().text, 'dogs are cool\n')

    def test_200_this_header_becomes_the_common_depth(self):
        self.assertEqual(self._this_header().depth, 2)

    def _this_header(self):
        return self.state.section_at(1).header

    @property
    @shared_subject
    def state(self):
        return self.build_state()

    def given_fragments(self):
        yield 'dogs', ('#h', 'xx1')
        yield 'dogs are cool', ('xx3',)


class Case118_nonfirst_fragments_with_heading_and_headers(_CommonCase):

    def test_100_headers_are_bumped_down_a_level_EVERYTHING(self):
        state = self.build_state()

        hdr = state.section_at(1).header
        assert(hdr.text == 'dogs are cool\n')
        self.assertEqual(hdr.depth, 2)

        hdr = state.section_at(2).header
        assert(hdr.text == 'loved dog #1\n')
        self.assertEqual(hdr.depth, 3)

        hdr = state.section_at(3).header
        assert(hdr.text == 'loved dog #2\n')
        self.assertEqual(hdr.depth, 3)

    def given_fragments(self):
        yield 'dogs', ('#h', 'xx1')
        yield 'dogs are cool', ('#loved dog #1', 'abc', '#loved dog #2', 'xx')


class Case121_nonfirst_fragments_with_NO_heading_YES_headers(_CommonCase):

    def test_100_headers_are_NOT_bumped_down_a_level_EVERYTHING(self):
        state = self.build_state()

        hdr = state.section_at(1).header
        assert(hdr.text == 'loved dog #1\n')
        self.assertEqual(hdr.depth, 2)

        hdr = state.section_at(2).header
        assert(hdr.text == 'loved dog #2\n')
        self.assertEqual(hdr.depth, 2)

    def given_fragments(self):
        yield 'dogs', ('#h', 'xx1')
        yield None, ('#loved dog #1', 'abc', '#loved dog #2', 'xx')


if __name__ == '__main__':
    unittest.main()

# #born.
