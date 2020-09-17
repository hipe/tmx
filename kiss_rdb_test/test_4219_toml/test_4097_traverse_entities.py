from kiss_rdb_test.common_initial_state import \
        debugging_listener as _debugging_listener, \
        unindent as _unindent
import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    def is_head_block_with_this_many_lines(self, hb, num):
        _actual = len(hb._head_block_lines)
        self.assertEqual(_actual, num)

    def is_attributes_table_with_this_name(self, mde, id_s):
        self.assertEqual(mde.table_type, 'attributes')
        self.assertEqual(mde.identifier_string, id_s)

    def when_expecting_failure_count_and_structure(self):
        item_count, chan, payloader = self._item_count_and_only_emission()
        self.assertSequenceEqual(chan, ('error', 'structure', 'input_error'))
        sct = payloader()
        return item_count, sct

    def _item_count_and_only_emission(self):
        listener, emissions = em.listener_and_emissions_for(self, limit=1)
        itr = self._iterator_via_run(listener)
        item_count = 0
        for _ in itr:
            item_count += 1
        emi, = emissions
        return item_count, emi.channel, emi.payloader

    def the_rest(self):
        return self.head_block_and_rest[1]

    def head_block(self):
        return self.head_block_and_rest[0]

    def when_expecting_success_head_block_and_rest(self):
        itr = self.when_expecting_success_iterator()
        return (next(itr), itr)

    def when_expecting_success_iterator(self):
        _listener = _debugging_listener() if False else _no_listener
        return self._iterator_via_run(_listener)

    def _iterator_via_run(self, listener):
        _given_lines = self.given_lines()
        return block_stream_via_file_lines(_given_lines, listener)

    do_debug = False


class Case4094_simplified_typical(CommonCase):

    def test_100_head_block_looks_good(self):
        self.is_head_block_with_this_many_lines(self.head_block(), 2)

    def test_200_the_rest_looks_good(self):
        itr = self.the_rest()
        mde = next(itr)
        self.is_attributes_table_with_this_name(mde, 'AA')
        mde = next(itr)
        self.is_attributes_table_with_this_name(mde, 'BB')
        mde = next(itr)
        self.is_attributes_table_with_this_name(mde, 'CC')
        for _ in itr:
            self.fail()

    @shared_subject
    def head_block_and_rest(self):
        return self.when_expecting_success_head_block_and_rest()

    def given_lines(self):
        return _unindent("""
        # hi hungry i'm dad

        [item.AA.attributes]
        xx = "yy"
        zz = "qq"

        [item.BB.attributes]
        # comment here OK
        aa = "bb"

        [item.CC.attributes]
        dd = "ee"
        """)


class Case4095_effectively_empty_file_of_course_has_head_block(CommonCase):

    def test_100_head_block_looks_good(self):
        lines = self.head_block()._head_block_lines
        self.assertEqual(lines[0], "# hi hunger i'm dad. blank line next.\n")
        self.assertEqual(lines[1], '\n')
        self.assertEqual(len(lines), 2)

    def test_200_the_rest_is_nothing(self):
        itr = self.the_rest()
        for _ in itr:
            self.fail()

    @shared_subject
    def head_block_and_rest(self):
        return self.when_expecting_success_head_block_and_rest()

    def given_lines(self):
        return _unindent("""
        # hi hunger i'm dad. blank line next.

        """)


class Case4096_truly_empty_file_has_no_head_block(CommonCase):

    def test_100_whatever(self):
        itr = self.when_expecting_success_iterator()
        for _ in itr:
            self.fail()

    def given_lines(self):
        return ()


class Case4097_error_in_table_start_line(CommonCase):  # #midpoint

    def test_100_some_error_structure_detail(self):
        sct = self.count_and_structure[1]
        self.assertEqual(sct['lineno'], 2)
        self.assertEqual(sct['expecting'], 'keyword "item"')

    def test_200_it_does_not_yield_even_one_entity(self):
        count = self.count_and_structure[0]
        self.assertEqual(count, 0)

    @shared_subject
    def count_and_structure(self):
        return self.when_expecting_failure_count_and_structure()

    def given_lines(self):
        return _unindent("""
        # hi dad
        [items.QQ]
        no = "see"
        """)


class Case4098_error_in_attribute_value_passes_thru_for_now(CommonCase):

    def test_100_head_block_looks_good(self):
        self.is_head_block_with_this_many_lines(self.head_block(), 1)

    def test_200_the_invalid_toml_was_parsed(self):
        eb, = tuple(self.the_rest())  # entity block
        _ab = eb._body_blocks[0]  # attribute block
        _line = _ab.line
        self.assertEqual(_line, 'yes = see\n')

    @shared_subject
    def head_block_and_rest(self):
        return self.when_expecting_success_head_block_and_rest()

    def given_lines(self):
        return _unindent("""
        # hi dad
        [item.QQ.attributes]
        yes = see
        """)


class Case4100_one_no_head(CommonCase):

    def test_100_head_block_looks_good(self):
        self.is_head_block_with_this_many_lines(self.head_block(), 0)

    def test_200_the_rest_looks_good(self):
        mde, = tuple(self.the_rest())
        self.is_attributes_table_with_this_name(mde, 'QQ')

    @shared_subject
    def head_block_and_rest(self):
        return self.when_expecting_success_head_block_and_rest()

    def given_lines(self):
        return _unindent("""
        [item.QQ.attributes]
        no = "see"
        """)


class Case4101_two_yes_head(CommonCase):

    def test_100_head_block_looks_good(self):
        self.is_head_block_with_this_many_lines(self.head_block(), 1)

    def test_200_the_rest_looks_good(self):
        itr = self.the_rest()
        mde = next(itr)
        self.assertEqual(mde.table_type, 'meta')
        self.assertEqual(mde.identifier_string, 'AA')
        mde = next(itr)
        self.is_attributes_table_with_this_name(mde, 'BB')
        for _ in itr:
            self.fail()

    @shared_subject
    def head_block_and_rest(self):
        return self.when_expecting_success_head_block_and_rest()

    def given_lines(self):
        return _unindent("""
        # hi dad
        [item.AA.meta]
        [item.BB.attributes]
        no = "see"
        """)


class Case4111_integrate_filter_by_tags(CommonCase):

    def test_100_result(self):
        self.my_case.expect_these_two_entities(self)

    def test_200_statistics(self):
        self.my_case.expect_the_appropriate_statistics(self)

    def given_collection(self):
        _lines = _unindent("""
        [item.ENA.attributes]
        hi_one = "this is #red"

        [item.ENB.attributes]
        hi_two = "this is #green"

        [item.ENC.attributes]
        hi_three = "this is #blue"
        """)
        itr = block_stream_via_file_lines(_lines)
        _head_block = next(itr)
        _head_block.hello_head_block__
        return tuple(itr)

    @shared_subject
    def end_state(self):
        return self.my_case.build_end_state(self)

    @property
    def my_case(self):
        from kiss_rdb_test.filter_canon import (
            case_of_one_column_match_two_out_of_three)
        return case_of_one_column_match_two_out_of_three


def block_stream_via_file_lines(given_lines, listener=None):
    return _subject_module().block_stream_via_file_lines(given_lines, listener)


def _subject_module():
    from kiss_rdb.storage_adapters_.toml import blocks_via_file_lines as _
    return _


_no_listener = None


if __name__ == '__main__':
    unittest.main()

# #born.
