"""
"collection-level synchronization"

at #history-A.2 when we spiked the new [#447] "interleaving" algorithm, we
preserved this one (for practical reasons)
"""

from data_pipes_test.sync_support import SyncCase_
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(SyncCase_):
    def preserve_freeform_order(self):
        return True
    do_debug = False


class Case0747_none_down_on_to_none_produces_none(CommonCase):

    def test(self):
        self.expect_these_()

    def far_collection(self):
        return ()

    def near_collection(self):
        return ()


class Case0749_none_down_on_to_some_is_unsurprising(CommonCase):

    def test(self):
        self.expect_these_('a', 'b', 'c')

    def far_collection(self):
        return ()

    def near_collection(self):
        return ('a', 'b', 'c')


class Case0751_some_down_on_to_none_is_unsurprising(CommonCase):

    def test(self):
        self.expect_these_('d', 'e', 'f')

    def far_collection(self):
        return ('d', 'e', 'f')

    def near_collection(self):
        return ()


class Case0752_duplicate_key_far(CommonCase):

    def test_100_this_error(self):
        self.this_error_('error', 'expression', 'duplicate_key')

    def test_200_this_error_message(self):
        _exp = "duplicate key in far traversal: 'a'"
        self.this_error_message_(_exp)

    @shared_subject
    def end_state(self):
        return self.build_end_state_while_listening_()

    def far_collection(self):
        return ('a',
                'b',
                'a')

    def near_collection(self):
        return ('c',
                'd')


class Case0754_duplicate_key_near(CommonCase):

    def test_100_this_error(self):
        self.this_error_('error', 'expression', 'duplicate_key')

    def test_200_this_error_message(self):
        _exp = "duplicate key in near traversal: 'c'"
        self.this_error_message_(_exp)

    @shared_subject
    def end_state(self):
        return self.build_end_state_while_listening_()

    def far_collection(self):
        return ('a',
                'd')

    def near_collection(self):
        return ('b',
                'c',
                'c')


class Case0755_some_down_on_to_some_no_collisions_appends(CommonCase):

    def test(self):
        self.expect_these_('a', 'b', 'c', 'd', 'e', 'f')

    def far_collection(self):
        return ('d', 'e', 'f')

    def near_collection(self):
        return ('a', 'b', 'c')


class Case0757_weird_order_is_OK_here(CommonCase):

    def test_100_inserted_at_end(self):
        self.expect_these_(
                'd',
                'c',
                'b',
                'a')

    def far_collection(self):
        return ('b',
                'a')

    def near_collection(self):
        return ('d',
                'c')


class Case0758_some_down_on_to_some_yes_collisions(CommonCase):

    def test(self):
        self.expect_these_('a', 'B', 'c', 'D', 'e', 'f')

    def far_collection(self):
        return ('b', 'd', 'e', 'f')

    def near_collection(self):
        return ('a', 'b', 'c', 'd')


if __name__ == '__main__':
    unittest.main()

# #history-A.2: when we spiked the interleaving algorithm
# #history-A.1: removed use of format adapter from this test
# #born.
