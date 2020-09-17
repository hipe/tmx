"""
the birth of this test file coincided with the introduction of the new
test synchronization algorithm (interleaving) which became the default.
(all in [#447]).

some of the numbers of test cases line up with test cases in a sibling.
"""

from data_pipes_test.sync_support import SyncCase_
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(SyncCase_):
    def preserve_freeform_order(self):
        return False

    do_debug = False


class Case0262_none_down_on_to_none_produces_none(CommonCase):
    # NOTE at writing, this is the only case with external references

    def test_010_magnetic_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_this_case(self):
        self.expect_these_()

    def far_collection(self):
        return ()

    def near_collection(self):
        return ()


class Case0264_none_down_to_one_out_of_order_is_not_OK(CommonCase):
    # disorder in the near traversal is a problem even

    def test_100_this_error(self):
        self.this_error_('error', 'expression', 'disorder')

    def test_200_this_error_message(self):
        _exp = "near traversal is not in order ('z' then 'q')"
        self.this_error_message_(_exp)

    def test_300_got_this_far(self):
        self.expect_these_('z')

    @shared_subject
    def end_state(self):
        return self.build_end_state_while_listening_()

    def far_collection(self):
        return ()

    def near_collection(self):
        return ('z', 'q', 'y')


class Case0265_none_down_on_to_some_is_unsurprising(CommonCase):

    def test(self):
        self.expect_these_('a', 'b', 'c')

    def far_collection(self):
        return ()

    def near_collection(self):
        return ('a', 'b', 'c')


class Case0267_some_down_on_to_none_out_of_order_not_OK(CommonCase):
    # disorder in the far traversal is not OK even if it's just in the rundown.

    def test_100_this_error(self):
        self.this_error_('error', 'expression', 'disorder')

    def test_200_this_error_message(self):
        _exp = "far traversal is not in order ('v' then 'f')"
        self.this_error_message_(_exp)

    def test_300_got_this_far(self):
        self.expect_these_('m', 'v')

    @shared_subject
    def end_state(self):
        return self.build_end_state_while_listening_()

    def far_collection(self):
        return ('m', 'v', 'f')

    def near_collection(self):
        return ()


class Case0268_some_down_on_to_none_is_unsurprising(CommonCase):

    def test(self):
        self.expect_these_('d', 'e', 'f')

    def far_collection(self):
        return ('d', 'e', 'f',)

    def near_collection(self):
        return ()


class Case0270_duplicate_key_near(CommonCase):

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


class Case0271_weird_order_is_bad_in_far_here(CommonCase):

    def test_100_this_error(self):
        self.this_error_('error', 'expression', 'disorder')

    def test_200_this_error_message(self):
        _exp = "far traversal is not in order ('b' then 'a')"
        self.this_error_message_(_exp)

    @shared_subject
    def end_state(self):
        return self.build_end_state_while_listening_()

    def far_collection(self):
        return ('b',
                'a')

    def near_collection(self):
        return ('c',)


class Case0273_interleave_no_collision_both_sides_already_sorted(CommonCase):

    def test(self):
        self.expect_these_(
                # 'x',  # the example record stays in the same place ##here1
                'a',  # this one came from far, got bumped into front
                'b',  # here's the original first one from near
                'c',  # flip to far: first of two from far
                'd',  # second of two from far
                'e')  # flip back to near

    def far_collection(self):
        return ('a',
                'c',
                'd')

    def near_collection(self):
        return (  # 'x',  # leave brittney alone ##here1
                'b',
                'e')


class Case0274_some_down_on_to_some_yes_collisions(CommonCase):
    # item-level merge

    def test(self):
        self.expect_these_(
                'a',
                'B',
                'c',
                'D',
                'e',
                'f')

    def far_collection(self):
        return ('b',
                'd',
                'e',
                'f')

    def near_collection(self):
        return ('a',
                'b',
                'c',
                'd')


class Case0275_bigger_example_of_disorder(CommonCase):

    def test_100_this_error(self):
        self.this_error_('error', 'expression', 'disorder')

    def test_200_this_error_message(self):
        _exp = "far traversal is not in order ('v' then 'a')"
        self.this_error_message_(_exp)

    def test_300_got_this_far(self):
        self.expect_these_(
                'p',
                'q',
                'r',
                's',
                't',
                'u',
                'v',
                # 'a',  # these..
                # 'c',  # three..
                # 'b',  # ..were just "run down", no check
                )

    @shared_subject
    def end_state(self):
        return self.build_end_state_while_listening_()

    def far_collection(self):
        return ('p',
                'r',
                's',
                'v',
                'a',  # yikes out of order
                'c',
                'b')  # yikes out of order

    def near_collection(self):
        return ('q',
                't',
                'u')


def _subject_module():
    import data_pipes.magnetics.flat_map_via_far_collection as _  # noqa: E501
    return _


if __name__ == '__main__':
    unittest.main()

"""
:#here1: markdown documents
"""
# #born.
