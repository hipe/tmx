from modality_agnostic.memoization import lazy
import unittest


class SyncCase_(unittest.TestCase):

    # -- expecters

    def this_error_(self, *s_a):
        em, = self.end_state_().emissions
        self.assertEqual(em.channel, s_a)

    def this_error_message_(self, msg):
        em, = self.end_state_().emissions
        _act = em.to_string()
        self.assertEqual(_act, msg)

    def expect_these_(self, *s_a):
        _ = self.end_state_()
        self.assertSequenceEqual(_.result, s_a)

    def end_state_(self):  # NOTE - not memoized by default
        return self.__build_snapshot_plus()

    # -- build state

    def build_end_state_while_listening_(self):
        return self.__build_snapshot_plus(do_listen=True)

    def __build_snapshot_plus(self, **kwargs):
        return _build_snapshot(
                self.far_collection(),
                self.near_collection(),
                self.preserve_freeform_order(),
                **kwargs)

    def preserve_freeform_order(self):
        return False


class _build_snapshot:

    def __init__(self, far, near, preserve_freeform_order, do_listen=False):

        if do_listen:
            from modality_agnostic.test_support.listener_via_expectations import (  # noqa: E501
                listener_via_emission_receiver)
            emissions = []
            listener = listener_via_emission_receiver(emissions.append)
            add_these = {'listener': listener}
        else:
            add_these = {}

        if preserve_freeform_order:
            add_these['preserve_freeform_order_and_insert_at_end'] = True

        _normal_far_st = ((x, x) for x in far)
        _normal_near_st = ((x, x) for x in near)

        _st = _subject_module().stream_of_mixed_via_sync(
            normal_far_stream=_normal_far_st,
            normal_near_stream=_normal_near_st,
            item_via_collision=_item_via_collision,
            **add_these)

        self.result = tuple(x for x in _st)
        if do_listen:
            self.emissions = tuple(emissions)


def _item_via_collision(far_key, far_s, near_key, near_s):
    # (#provision #[#458.6] four args)
    assert(far_s == near_s)
    return near_s.upper()


def collection_reference_via_(collection_identifier, listener):
    from data_pipes import common_producer_script
    _ = common_producer_script.common_CLI_library()
    return _.collection_reference_via_(collection_identifier, listener)


def _same_listener():
    from modality_agnostic import listening
    return listening.throwing_listener


def _identity(x):
    return x


def _subject_module():
    import data_pipes.magnetics.synchronized_stream_via_far_stream_and_near_stream as x  # noqa: E501
    return x

# #abstracted.
