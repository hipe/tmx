"""
when we say a record is "nativized", we mean that it appears as a markdown

row, and that it takes on the formatting of the particular document (per the
[#418.D] example row). this magnetic is mostly concerned with facilitating the
creation of the "nativizer". what follows is a deeper explanation of all that.

(as an aside, not the name of this magnetic is figurative. it does not in
fact produce an ordered, nativized far stream on its own; rather the
client *may* produce something similar using the components produced by
this magnetic.)

the "central conceit" of our client is that it takes a stream of normal
records (dictionaries) and in effect turns them into markdown table rows,
sort of.

for markdown table rows as they sometimes (but not always) occur as
surface phenomena, they can carry some "information" in them that is not
present in a normal record; namely the particular use of spacing (if any).

generaly our design guidelines are:

  - it's better to try to infer this kind of thing from the peculiarities
    of the existing document rather than making heuristic decisions.

  - it's better to [same] rather than adding configuration options for it.

(but note:)

  - the idea of supporting ASCII formatting is now flagged as a possible
    [#415.S] misfeature, but we aren't yet sure so the behavior is intact.

given the above design guidelines, we pull off :[#408.E]: a particularly
dastardly bit of hackery that we try to centralize here: the "prototype row":

our nascent, experimental convention is that the first row of the markdown
table is used *only* as an example, to show how to format other rows.
(again we may either eliminate this a misfeature, or fold it in so that the
first row is seen as a business record too (isn't it?))

what makes this tricky is the stream-centric nature of the synchronization:
in ideal cases our synchronization algorithms work by processing both streams
item by item in their order with no large-scale caching, so that
synchronization can scale linearly to very large datasets (both near and far).

but note you can't output a "nativized" far item until you've seen the
[#418.D] example row, which is why the example row must be a non-participating
row that always appears first.

so this magnetic tries to thread the needle: it uses a "random access"
paradigm for the first record, then expects the rest is used streamily.
"""


from sakin_agac import (
        cover_me,
        pop_property,
        )
from modality_agnostic import (
        streamlib as _,
        )
import sys

next_or_none = _.next_or_none


class _Worker:
    """discussion: there is some confusion over whether we should take

    normal dictionaries or native objects.
    """

    def __init__(
            self,
            far_native_stream,
            far_map,
            far_keyer,
            far_is_ordered,
            near_stream,
            complete_schema,
            listener
            ):

        self._far_native_stream = far_native_stream
        self._far_map = far_map
        self._far_keyer = far_keyer
        self._far_is_ordered = far_is_ordered

        self._near_stream = near_stream

        self._nkfn = complete_schema.natural_key_field_name__()
        self._complete_schema = complete_schema
        self._listener = listener
        self._mutex = None
        self._OK = True

    def execute(self):
        del(self._mutex)
        self._OK and self.__resolve_example_row()
        self._OK and self.__resolve_prototype_row_via_example_row()
        self._OK and self.__init_far_KV_pairs()
        self._OK and self.__resolve_ordered_far_key_value_pairs()
        self._OK and self.__resolve_nativizer()
        if self._OK:
            return self

    def __resolve_nativizer(self):
        """
        finally, for whichever particular ordering algorithm is being used,
        it's going to need to be able to make new rows out of new far items.
        (inserts).
        """

        nv_pairs_via_native_item = pop_property(self, '_far_map')
        near_item_via_NV_pairs = self.prototype_row.new_via_name_value_pairs

        def near_item_via_far_item(native_far_item):
            _NV_pairs = nv_pairs_via_native_item(native_far_item)
            return near_item_via_NV_pairs(_NV_pairs)

        self.near_item_via_far_item = near_item_via_far_item

    def __resolve_ordered_far_key_value_pairs(self):
        """
        - when the ordered-ness of the far stream is either declared to be
          not ordered or no declaration is made, assume it's not ordered.

        - (if it's declared to be ordered but in actuality the traversal
          comes out not ordered, it's GIGO #cover-me)

        - new at the birth of this file, all traversals used in
          synchronizations must be ordered.

        - therefor, for all effective declaration of orderedness other than
          True, we've got to do a #big-flush (a redis-like scenario) and
          read the whole doo-hah into memory.
        """

        if self._far_is_ordered is True:
            cover_me("OK if you say so")
        else:
            self.__resolve_ordered_far_key_value_pairs_via_big_flush()

    def __resolve_ordered_far_key_value_pairs_via_big_flush(self):
        """yikes
        """

        big_list = []
        sanity = 200  # ##[#410.R]
        count = 0
        for kv_pair in pop_property(self, '_far_KV_pairs'):
            count += 1
            if sanity == count:
                cover_me('redis etc')
            big_list.append(kv_pair)

        big_list.sort(key=lambda kv_pair: kv_pair[0])
        self.ordered_far_key_value_pairs = big_list

    def __init_far_KV_pairs(self):
        """
        this should be the only place in the universe that we apply the far
        keyer.

        this is cached because it can take work to make keys

        this is in its own step because maybe 
        """

        _native_st = pop_property(self, '_far_native_stream')

        key_via_far = pop_property(self, '_far_keyer')

        def f(item):
            key = key_via_far(item)
            if key is None:
                cover_me("nil key")
            return (key, item)

        self._far_KV_pairs = (f(item) for item in _native_st)

    def __resolve_prototype_row_via_example_row(self):
        from . import prototype_row_via_example_row_and_schema_index as _
        self.prototype_row = _(
                natural_key_field_name=self._nkfn,
                example_row=self.example_row,
                complete_schema=self._complete_schema,
                )

    def __resolve_example_row(self):
        item = next_or_none(self._near_stream)
        if item is None:
            cover_me("apparently you never covered this - no example row")
            _tmpl = "can't sync because no first business object row"
            self._emit('error', 'expression', 'no_prototype_row', _tmpl, ())
        else:
            item.HELLO_POINTLESS_ITEM_WRAPPER_CLASS()
            self.example_row = item.ROW_DOM_

    def _emit(self, *chan, tmpl, tup):
        def msg_f():
            yield tmpl.format(*tup)
        if 'error' == chan[0]:
            self._OK = False
        self._listener(*chan, msg_f)


def _worker_wrapper(**kwargs):
    return _Worker(**kwargs).execute()


sys.modules[__name__] = _worker_wrapper

# #abstracted.
