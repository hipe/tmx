from unittest import TestCase as unittest_TestCase


# == Integration with particular storage adapters

def build_end_state_of_sync(tc):
    listener, done = em().listener_and_done_via(tc.expect_emissions(), tc)
    near, far = _normalize_these(**tc.given())
    nf = tc.given_near_format_name()
    lines = tuple(_corralpoint(near, far, listener, near_format=nf))
    return _LinesAndEmissionsAsEndState(lines, done())


def _normalize_these(near_collection, producer_script_path):
    return near_collection, producer_script_path


def OUTPUT_LINES_VIA_SYNC__(tc):
    listener = tc.use_listener()
    far = tc.given_producer_script()
    near = tc.given_near_collection_mixed__()
    nf = None if isinstance(near, str) else tc.given_near_format_name()
    lines = _corralpoint(near, far, listener, near_format=nf)
    return tuple(lines)


class _LinesAndEmissionsAsEndState:
    def __init__(self, outputted_lines, aei):
        self.outputted_lines = outputted_lines
        self.actual_emission_index = aei


# == Test "Pure" Syncing (distinct from any near format adapter)

class SyncCase_(unittest_TestCase):

    # -- expecters

    def this_error_(self, *s_a):
        emi, = self.end_state.emissions
        self.assertEqual(emi.channel, s_a)

    def this_error_message_(self, expected_message):
        emi, = self.end_state.emissions
        msg, = emi.to_messages()
        self.assertEqual(msg, expected_message)

    def expect_these_(self, *s_a):
        _ = self.end_state
        self.assertSequenceEqual(_.result, s_a)

    @property
    def end_state(self):  # NOTE - not memoized by default
        return self._build_snapshot_plus(do_listen=False)

    # -- build state

    def build_end_state_while_listening_(self):
        return self._build_snapshot_plus(do_listen=True)

    def _build_snapshot_plus(self, do_listen):
        fc = self.far_collection()
        nc = self.near_collection()
        do_preserve = self.preserve_freeform_order()
        return _build_snapshot(self, fc, nc, do_preserve, do_listen)

    def preserve_freeform_order(self):
        return False


class _build_snapshot:

    def __init__(self, tc, far, near, preserve_freeform_order, do_listen):
        flat_map_opts = {}

        if do_listen:
            listener, emissions = em().listener_and_emissions_for(tc, limit=None)
        else:
            listener = em().throwing_listener

        if preserve_freeform_order:
            flat_map_opts['preserve_freeform_order_and_insert_at_end'] = True

        normal_far_items = ((x, x) for x in far)
        normal_near_items = ((x, x) for x in near)

        flat_map = flat_map_via(normal_far_items, **flat_map_opts)

        _ = _minimal_example_of_using_the_flat_map_for_collection_sync(
                normal_near_items, flat_map, listener)
        new_items = tuple(_)

        self.result = new_items
        if do_listen:
            self.emissions = tuple(emissions)


def _minimal_example_of_using_the_flat_map_for_collection_sync(
        normal_near_pairs, flat_map, listener):

    # First, send each near item into the flat map and follow its directives
    for near_key, near_mixed in normal_near_pairs:
        directives = flat_map.receive_item(near_key)
        for directive in directives:
            if 'pass_through' == directive[0]:
                yield near_mixed
                continue
            if 'insert_item' == directive[0]:
                yield directive[1]
                continue
            if 'merge_with_item' == directive[0]:
                far_mixed = directive[1]
                yield _item_via_collision(near_key, far_mixed, near_key, near_mixed)  # noqa: E501
                continue
            if 'error' == directive[0]:
                listener(*directive)
                return
            assert()

    # Then, ask the flat map to give you any remaining items to insert
    for directive in flat_map.receive_end():
        typ = (frame := list(reversed(directive))).pop()
        if 'insert_item' == typ:
            mixed_far_item, = frame
            yield mixed_far_item
            continue
        if 'error' == typ:
            listener(*directive)
            return
        assert()


def _item_via_collision(far_key, far_s, near_key, near_s):
    # #todo below isn't a thing any more. it's storage adapter's choice
    # (#provision #[#458.6] four args)
    assert(far_s == near_s)
    return near_s.upper()


# == Corralpoints

def _corralpoint(near, far, listener, near_format):  # #corralpoint
    do_diff, cached_document_path, opn = False, None, None

    if not isinstance(far, str):
        from .common_initial_state import FakeProducerScript as cls
        if isinstance(far, dict):
            far = cls(**far)
        else:
            assert isinstance(far, cls)  # #[#022] (Case2664DP)

    if not isinstance(near, str):
        assert hasattr(near, '__next__')
        near_line_iterator = near
        near = '/dev/null/hello-from-DP-we-will-hack-this'
        from .common_initial_state import passthru_context_manager

        def opn(path):
            assert near == path
            return passthru_context_manager(near_line_iterator)

    from data_pipes.cli.sync import _stdout_lines_from_sync as func

    return func(
        near, far, listener, do_diff, near_format, cached_document_path, opn)


def flat_map_via(far_pairs, **opts):
    return _subject_module().flat_map_via_producer_script(far_pairs, *opts)


def _subject_module():
    import data_pipes.magnetics.flat_map_via_far_collection as x
    return x


# == Support

def em():
    import modality_agnostic.test_support.common as em
    return em


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-B.1: for blind rewrite
# #abstracted.
