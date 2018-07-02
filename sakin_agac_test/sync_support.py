from sakin_agac import sanity
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
                listener_via_emission_receiver
                )
            emissions = []
            listener = listener_via_emission_receiver(emissions.append)
            add_these = {'listener': listener}
        else:
            add_these = {}

        if preserve_freeform_order:
            add_these['preserve_freeform_order_and_insert_at_end'] = True

        _st = subject_module_().stream_of_mixed_via_sync(
            natural_key_via_far_user_item=_identity,
            far_stream=far,
            natural_key_via_near_user_item=_identity,
            near_stream=near,
            item_via_collision=_item_via_collision,
            **add_these
            )

        self.result = tuple(x for x in _st)
        if do_listen:
            self.emissions = tuple(emissions)


def _item_via_collision(far_s, near_s):
    None if far_s == near_s else sanity()
    return near_s.upper()


def _identity(x):
    return x


def subject_module_():
    import sakin_agac.magnetics.synchronized_stream_via_new_stream_and_original_stream as x  # noqa: E501
    return x


# #abstracted.
