from sakin_agac import sanity
from modality_agnostic.memoization import memoize
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

        _normal_far_st = ((x, x) for x in far)
        _normal_near_st = ((x, x) for x in near)

        _st = _subject_module().stream_of_mixed_via_sync(
            normal_far_stream=_normal_far_st,
            normal_near_stream=_normal_near_st,
            item_via_collision=_item_via_collision,
            **add_these
            )

        self.result = tuple(x for x in _st)
        if do_listen:
            self.emissions = tuple(emissions)


def _item_via_collision(far_key, far_s, near_key, near_s):
    # (#provision #[#418.F] four args)
    None if far_s == near_s else sanity()
    return near_s.upper()


def NORMALIZE_NEAR_ETC_AND_FAR(far_dicts):

    import sakin_agac_test.format_adapters.in_memory_dictionaries as _
    _far_FA = _.FORMAT_ADAPTER

    _far_col_ref = _far_FA.collection_reference_via_string(far_dicts)

    _ = _mag_wee().OPEN_FAR_SESSION(_far_col_ref, None, None)

    with _ as far_session:
        None if far_session.OK else sanity()
        _normal_far_st = far_session.release_normal_far_stream()
        dct = far_session.TO_NRTP__()
        ary = [x for x in _normal_far_st]

    _nkr = __unpack_these(dct)

    return _nkr, ary


def NORMALIZE_FAR(callback, far_path):

    _far_col_ref = collection_reference_via_(far_path, __file__)

    _ = _mag_wee().OPEN_FAR_SESSION(_far_col_ref, None, __file__)

    with _ as far_session:
        None if far_session.OK else sanity()
        _normal_far_st = far_session.release_normal_far_stream()
        result = callback(_normal_far_st)
    return result


def __unpack_these(dct):
    if dct is None:
        result = None
    else:
        def yuck(custom_near_keyer_for_syncing=None):
            return custom_near_keyer_for_syncing
        result = yuck(**dct)
    return result


def open_tagged_doc_line_items__(mixed_near):
    _ = _mag_sync().OPEN_NEWSTREAM_VIA
    _ = _.sibling_('tagged_native_item_stream_via_line_stream')
    return _.OPEN_TAGGED_DOC_LINE_ITEM_STREAM(mixed_near, __file__)


def collection_reference_via_(collection_identifier, listener):
    import script.stream as _  # #[#410.Q] this script as lib only
    return _.collection_reference_via_(collection_identifier, listener)


@memoize
def _mag_wee():
    return _sub_mag('.ordered_nativized_far_stream_via_far_stream_and_near_stream')  # noqa: E501


@memoize
def _mag_sync():
    return _sub_mag('.synchronized_stream_via_far_stream_and_near_stream')


def _sub_mag(which):
    import importlib
    import sakin_agac.format_adapters.markdown_table.magnetics as _
    return importlib.import_module(which, _.__name__)


def _identity(x):
    return x


def _subject_module():
    import sakin_agac.magnetics.synchronized_stream_via_far_stream_and_near_stream as x  # noqa: E501
    return x

# #abstracted.
