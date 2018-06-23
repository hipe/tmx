"""the [#409.A] central conceit of this whole lyfe happens in this module:

this is where we read the lines of a markdown document, and pass a certain
subslice of those lines over to our synchronization algorithm. the output
of the main function in this module is the new lines of the markdown document
(sort of) after the synchronization has been applied.

by "sort of" we mean this: the result of the function is actually a stream
of tuples, where each first element of each tuple is a "category" (type) of
element (roughly corresponding to the names of the states in our [#409]
parser state machine), and each second element is mixed (but either a line
or a `to_string()`-able).

we intend for this to be "modality agnostic" - this module does not "know"
whether it's running under a CLI or elsewhere.

we thought that you would want a [#411] tagged stream processor to produce
your result; but in fact we do something simpler.
"""

from sakin_agac.magnetics import (
        synchronized_stream_via_new_stream_and_original_stream as _top_sync,
        )
from sakin_agac import (
        cover_me,
        pop_property,
        )
from modality_agnostic import (
        streamlib as _sl,
        )
import sys


next_or_none = _sl.next_or_none


def _could_end_at_any_time(f):
    """custom decorator. this file only.

    the markdown document can end at any time (see [#409])
    """

    def g(self):
        tup = next_or_none(self._tagged_stream)
        if tup is None:
            self._close()
        else:
            return f(self, tup)
    return g


def _NEWSTREAM_VIA(**kwargs):
    return _Newstream_via(**kwargs).execute()


class _Newstream_via:
    """be LIKE #[#410.N] a context manager class in the typical pattern,

    whose element are..
    our (tagged maybe) output lines (in some whatever parse tree format)

    whereby:

      - like any processor, we expect to traverse through a particular state
        graph; in this case [#409] our conception of the markdown document.
        (the method has a name in all caps IFF it corresponds to a state.)

      - when we get to the target markdown table, we do a crazy thing to pass
        the rows of the markdown table (as business object rows) to the
        synchronizer.

      - when we 'return' from the synchronization (by having exhausted it),
        we've got to transition somehow back into our own stream, to output
        the remaining lines of the markdown document.

    relevant state-specific concerns will be discussed below.
    """

    def __init__(
            self,

            # the streams:
            far_dictionary_stream,
            near_tagged_items,

            # the required sync parameters:
            natural_key_field_name,
            farstream_format_adapter,

            # pseudo-optional sync parrameters (not optional because bugsource)
            far_traversal_is_ordered,
            sync_keyerser,

            listener,
            ):

        self._far_dictionary_stream = far_dictionary_stream
        self._tagged_stream = near_tagged_items
        self._natural_key_field_name = natural_key_field_name
        self._listener = self.__build_attached_listener(listener)
        self._far_traversal_is_ordered = far_traversal_is_ordered
        self._sync_keyerser = sync_keyerser
        # --
        self._natural_key_via_far_user_item_unsanitized, = farstream_format_adapter.value_readers_via_field_names(natural_key_field_name)  # noqa: E501
        self._name_value_pairs_via_far_native_object = farstream_format_adapter.name_value_pairs_via_native_object  # noqa: E501
        self._state = 'HEAD_LINES'
        self._proto_row = '_proto_row_initially'
        self._did_see_first_business_object_row = False
        self._mutex = None

    def execute(self):  # (would be __enter__())
        del(self._mutex)
        while self._OK:
            x = self._next_or_none()
            if x is None:
                break
            yield x

    @_could_end_at_any_time
    def HEAD_LINES(self, tup):
        typ = tup[0]
        if 'head_line' == typ:
            pass
        elif 'table_schema_line_one_of_two' == typ:
            # NOTE we don't even take the liner, we don't care
            self._move_to('SECOND_TABLE_LINE')
        else:
            cover_me('unexpected tagged item')
        return tup

    @_could_end_at_any_time
    def SECOND_TABLE_LINE(self, tup):

        typ = tup[0]
        if 'table_schema_line_two_of_two' == typ:
            _custom_hybrid = tup[1]
            self._complete_schema = _custom_hybrid.complete_schema
            self.__init_these_two_mappers_which_could_fail()
            if self._OK:
                self._move_to('_TRANSITION_TO_CRAZY_TOWN')
            else:
                self._close()
        else:
            cover_me('unexpected tagged item')
        return tup

    def _TRANSITION_TO_CRAZY_TOWN(self):

        _item_via_collision = self.__build_item_via_collision()

        _far_item_wrapperer = self.__build_far_item_wrapperer()

        _near_ad_hoc_item_stream = self.__build_near_ad_hoc_item_stream()

        self._big_deal_stream = _top_sync.stream_of_mixed_via_sync(

                # far
                far_stream=pop_property(self, '_far_dictionary_stream'),
                natural_key_via_far_user_item=pop_property(self, '_nat_key_via_far_item'),  # noqa: E501
                far_item_wrapperer=_far_item_wrapperer,
                far_traversal_is_ordered=pop_property(self, '_far_traversal_is_ordered'),  # noqa: E501

                # near
                near_stream=_near_ad_hoc_item_stream,
                natural_key_via_near_user_item=pop_property(self, '_nat_key_via_near_item'),  # noqa: E501

                # the rest
                item_via_collision=_item_via_collision,
                listener=self._listener)

        self._move_to('OBJECT_ROWS')
        return self._next_or_none()

    def __build_item_via_collision(self):
        """
        we get here when the near and far item have the "same" human key.

        .#coverpoint1.6 provisions a way to provide a function so that we
        have a "derived" human key value (for use in fuzzy matching).
        (this feature is #experimental.) this means that the near and far
        records that "match" by human key need not actually have the same
        human key value ("content string").

        but a #coverpoint1.5 holds that we won't invoke the machinery
        of a record merge if the far record has no fields other than the
        human key (because why bother, right?)

        so the combination of these two together raises the question:
        if you're fuzzy matching (deriving human keys) and also the above
        condition is met, what do? answer: yes do the merge.

        (this is a heuristic behavior decision born out of convenience:
        see its origin story in the asset file added at #history-A.1.)

        this is perhaps a bit of a feature creep; as it serves a behavior
        that is perhaps more minimally implemented by the data producers,
        so: experimental for now.
        """

        def item_via_collision(far_native_object, near_item):

            near_row_DOM = near_item.ROW_DOM_

            far_pairs = self._name_value_pairs_via_far_native_object(
                    far_native_object)

            far_pairs = list(far_pairs)  # flatten it if it's a generator

            length = len(far_pairs)

            if 0 == length:
                cover_me('completely empty far record?')
            elif 1 == length:
                if self._sync_keyerser is None:
                    # #coverpoint1.5: short circuit the work
                    return near_row_DOM
                else:
                    pass  # #coverpoint1.7: let the single-field record thru

            _prototype_row = self._prototype_row_as_late_as_possible()

            return _prototype_row.new_row_via_far_pairs_and_near_row_DOM__(
                    far_pairs, near_row_DOM)
        return item_via_collision

    def __build_far_item_wrapperer(self):

        name_value_pairs_via_far_native_object = self._name_value_pairs_via_far_native_object  # noqa: E501

        def build_wrapper(result_categories, listener):

            # make a prototype row from a real, encountered row.
            # do this only once you've acutally seen such a row in the near doc
            prototype_row = self._prototype_row_as_late_as_possible()

            if prototype_row is None:
                return

            def wrap(native_object):
                _pairs = name_value_pairs_via_far_native_object(native_object)
                _wrapped = prototype_row.new_via_name_value_pairs(_pairs)
                return (result_categories.OK, _wrapped)
            return wrap
        return build_wrapper

    def _prototype_row_as_late_as_possible(self):
        return getattr(self, self._proto_row)()

    def _proto_row_initially(self):
        del(self._proto_row)
        self.__actual_proto_row = self.__build_proto_row()
        self._proto_row = '_proto_row_subsequently'
        return self._proto_row_subsequently()

    def _proto_row_subsequently(self):
        return self.__actual_proto_row

    def __build_proto_row(self):
        if self._did_see_first_business_object_row:
            return self.__build_proto_row_when_seen()
        else:
            self._error("can't sync because no first business object row")

    def __build_proto_row_when_seen(self):

        _row = pop_property(self, '_first_business_object_row')

        from . import prototype_row_via_example_row_and_schema_index as x
        return x(
                natural_key_field_name=self._natural_key_field_name,
                example_row=_row,
                complete_schema=self._complete_schema,
                )

    def __build_near_ad_hoc_item_stream(self):

        def item_via_native_object(x):
            # only for the first row we encounter,
            # do this thing (per [#408.E])
            self._did_see_first_business_object_row = True
            self._first_business_object_row = x
            nonlocal item_via_native_object
            item_via_native_object = _Item
            return item_via_native_object(x)

        _Item = self.__build_near_item_class()

        hit_the_end = True
        for tup in self._tagged_stream:
            typ, x = tup
            if 'business_object_row' == typ:
                _item = item_via_native_object(x)
                yield _item
            else:
                hit_the_end = False
                self._TUP_ON_DECK = tup
                break

        """(we don't know why but you don't need to and must not close
        yourself even when you hit the end of the whole document here.
        #coverpoint9.1.1)
        """

        self._did_hit_the_end_here = hit_the_end

    def __build_near_item_class(self1):

        class _NearItem:
            """
            #[#401.B] track item classes
            #todo we want to get rid of this - it does nothing at writing
            """

            def __init__(self2, row_DOM):
                self2.ROW_DOM_ = row_DOM

            def to_line(self2):
                return self2.ROW_DOM_.to_line()

        return _NearItem

    def OBJECT_ROWS(self):
        x = next_or_none(self._big_deal_stream)
        if x is None:
            if self._OK:
                if self._did_hit_the_end_here:
                    pass  # #coverpoint7.5
                else:
                    self._move_to('TAIL_LINES')
                    return pop_property(self, '_TUP_ON_DECK')
            else:
                return ('markdown_table_unable_to_be_synced_against_', None)
        else:
            return ('business_object_row', x)

    @_could_end_at_any_time
    def TAIL_LINES(self, tup):
        return tup

    def _next_or_none(self):
        return getattr(self, self._state)()

    def _close(self):
        del(self._tagged_stream)
        del(self._state)

    def _move_to(self, s):
        self._state = s

    def __init_these_two_mappers_which_could_fail(self):

        use_keyer_far = pop_property(self, '_natural_key_via_far_user_item_unsanitized')  # noqa: E501
        use_keyer_near = self._complete_schema.field_reader(self._natural_key_field_name)  # noqa: E501

        identifier = self._sync_keyerser
        if identifier is not None:
            # #coverpoint1.6
            near_f = use_keyer_near
            far_f = use_keyer_far
            use_keyer_near = None
            use_keyer_far = None
            from sakin_agac.magnetics import (
                    function_via_function_identifier as f_f
                    )
            sync_keyers = f_f(identifier, self._listener)
            if sync_keyers is None:
                self._OK = False  # in case no error was emitted (seen #here1)
            else:
                use_keyer_near, use_keyer_far = sync_keyers(near_f, far_f)

        if self._OK:
            self._nat_key_via_far_item = use_keyer_far
            self._nat_key_via_near_item = use_keyer_near

    def _error(self, message):
        from modality_agnostic import listening as li
        error = li.leveler_via_listener('error', self._listener)
        error(message)

    def __build_attached_listener(self, orig_listener):
        def f(typ, *a):
            if 'error' == typ:
                self._OK = False  # #here1
            orig_listener(typ, *a)
        self._OK = True
        return f


def _import_sibling_module(s):  # #experiment #track [#020.4]
    from importlib import import_module
    return import_module('..%s' % s, __name__)


_NEWSTREAM_VIA.sibling_ = _import_sibling_module

sys.modules[__name__] = _NEWSTREAM_VIA

# #history-A.1: add experimental feature "sync keyerser"
# #born.
