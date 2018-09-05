"""several [#417] central conceits of this whole project happen here:

this is where we read the lines of a markdown document, and pass a certain
subslice of those lines over to our synchronization algorithm. the output
of the main function in this module is the new lines of the markdown document
(sort of) after the synchronization has been applied.

(that's central conceit [#417.B] "markdown as datastore". also it's
[#417.C] synchronization.)

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
        synchronized_stream_via_far_stream_and_near_stream as _top_sync,
        )
from sakin_agac import (
        cover_me,
        pop_property,
        )
from modality_agnostic import (
        streamlib,
        )
import contextlib


next_or_none = streamlib.next_or_none


def _could_end_at_any_time(f):
    """custom decorator. this file only.

    the markdown document can end at any time (see [#409])
    """

    def g(self):
        tup = next_or_none(self._near_tagged_stream)
        if tup is None:
            self._close()
        else:
            return f(self, tup)
    return g


@contextlib.contextmanager
def OPEN_NEWSTREAM_VIA(**kwargs):
    """
    (currently our use of context managers is a bit #history-A.1 gung-ho.
    we don't entirely know what we are doing (except #pattern [#419.Z.1]
    nesting context managers) so this particular case may be a case where
    it isn't useful even hypothetically; and in either case it isn't used
    as a context manager practically.)
    """

    yield _Newstream_via(**kwargs).execute()


class _Newstream_via:
    """be LIKE #[#418.Z.3] a context manager class in the typical pattern,

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
            normal_far_stream,
            near_tagged_items,
            near_keyerer,
            far_deny_list,  # may be temporary. see [#418.I.3.2]
            listener,
            ):

        if far_deny_list is not None:
            def f(pair):
                dct = pair[1]
                for key in far_deny_list:
                    dct.pop(key)  # ..
                return pair
            normal_far_stream = (f(x) for x in normal_far_stream)

        # --
        self._normal_far_stream = normal_far_stream
        self._near_tagged_stream = near_tagged_items
        self._near_keyerer = near_keyerer
        self._listener = self.__build_attached_listener(listener)
        # --
        self._state = 'HEAD_LINES'
        self._mutex = None

    def execute(self):  # (would be __enter__())
        del(self._mutex)
        while self._OK:
            tup = self._next_or_none()
            if tup is None:
                break
            yield tup

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
            if self._OK:
                self._move_to('_TRANSITION_TO_CRAZY_TOWN')
            else:
                self._close()
        else:
            cover_me('unexpected tagged item')
        return tup

    def _TRANSITION_TO_CRAZY_TOWN(self):  # (for doc, see outsources below)

        near_st = self.__build_near_ad_hoc_item_stream()

        from . import ordered_nativized_far_stream_via_far_stream_and_near_stream as _  # noqa: E501
        o = _.NATIVIZER_ETC_VIA(  # see
                near_stream=near_st,
                complete_schema=self._complete_schema,
                listener=self._listener)
        if o is None:
            cover_me('neato - we never failed building the nativizer before')
            return

        native_via_item = o.near_item_via_normal_item_dictionary
        self.__proto_row = o.prototype_row
        example_row = o.example_row
        del(o)

        def native_via_key_and_item(far_key, far_item):
            # #coverpoint7.4
            return native_via_item(far_item)

        item_via_collision = self.__procure_item_via_collision()
        if item_via_collision is None:
            return

        pair_via_near = self.__procure_pair_via_near()
        if pair_via_near is None:
            return

        _normal_near_st = (pair_via_near(row_DOM) for row_DOM in near_st)

        _far_st = pop_property(self, '_normal_far_stream')
        _big_deal_stream = _top_sync.stream_of_mixed_via_sync(
                normal_far_stream=_far_st,
                normal_near_stream=_normal_near_st,
                item_via_collision=item_via_collision,
                nativizer=native_via_key_and_item,
                listener=self._listener)

        self._next_big_deal_row = streamlib.next_or_noner(_big_deal_stream)

        self._move_to('OBJECT_ROWS')
        return ('business_object_row', example_row)

    def __procure_item_via_collision(self):
        """
        we get here when the near and far item have the "same" human key.

        .#provision [#418.G] is that we short-circuit out of calling the
        merge callback if the far "record" has no components other than
        the natural key (because why bother, right?)

        but then #provision [#418.H] is that you can provide a function that
        derives arbitrary human keys.

        for now, we skip this heuristic of skipping the merge in those
        cases where you have defined a keyer.. (experimental still:
        see its origin story in the asset file added at #history-A.1.)

        this is perhaps a bit of a feature creep; as it serves a behavior
        that is perhaps more minimally implemented by the data producers,
        so: experimental for now.
        """

        can_short_circuit = self._near_keyerer is None

        def f(far_key, far_dct, near_key, near_row_DOM):
            # realize #provision #[#418.F] four args

            length = len(far_dct)

            if 0 == length:
                cover_me('completely empty far record?')
            elif 1 == length:
                if can_short_circuit:
                    # #coverpoint1.5: short circuit the work
                    result = near_row_DOM
                else:
                    # #coverpoint1.7: let some single-field records thru
                    result = do_merge(far_dct, near_row_DOM)
            else:
                result = do_merge(far_dct, near_row_DOM)
            return result

        def do_merge(far_dct, near_row_DOM):
            return self.__proto_row.new_row_via_far_pairs_and_near_row_DOM__(
                    far_dct.items(), near_row_DOM)
        return f

    def __build_near_ad_hoc_item_stream(self):

        hit_the_end = True
        for tup in self._near_tagged_stream:
            typ, row_DOM = tup
            if 'business_object_row' == typ:
                yield row_DOM
            else:
                hit_the_end = False
                self._TUP_ON_DECK = tup
                break

        """(we don't know why but you don't need to and must not close
        yourself even when you hit the end of the whole document here.
        #coverpoint9.1.1)
        """

        self._did_hit_the_end_here = hit_the_end

    def __procure_pair_via_near(self):

        def key_via_row_DOM_normally(row_DOM):
            # for now KISS and #provision [#418.I.2] (leftmost is guy)
            return row_DOM.cel_at_offset(0).content_string()

        f_f = pop_property(self, '_near_keyerer')
        if f_f is None:
            use_key_via_row_DOM = key_via_row_DOM_normally
        else:
            # #coverpoint1.6
            use_key_via_row_DOM = f_f(
                    key_via_row_DOM_normally,
                    self._complete_schema,
                    self._listener)

            if use_key_via_row_DOM is None:
                return  # bruh

        def pair_via_near(row_DOM):
            k = use_key_via_row_DOM(row_DOM)
            if k is None:
                cover_me("no gigo, let's catch this early")
            return (k, row_DOM)

        return pair_via_near

    def OBJECT_ROWS(self):
        x = self._next_big_deal_row()
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
        del(self._near_tagged_stream)
        del(self._state)

    def _move_to(self, s):
        self._state = s

    def __build_attached_listener(self, orig_listener):
        def f(typ, *a):
            if 'error' == typ:
                self._OK = False  # #here1
            orig_listener(typ, *a)
        self._OK = True
        return f


def _import_sibling_module(s):  # #experiment #track [#020.4]
    """
    you know how we can do `from . import foo_faa` to reach a module relative

    to the module the code appears in? we want the same kind of thing, but
    not have to be "inside" the module the code appears in.
    """

    from importlib import import_module
    return import_module('..%s' % s, __name__)


OPEN_NEWSTREAM_VIA.sibling_ = _import_sibling_module  # #testpoint

# #history-A.2: big refactor, go gung-ho with context managers. extracted.
# #history-A.1: add experimental feature "sync keyerser"
# #born.
