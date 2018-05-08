from sakin_agac.magnetics import (
        synchronized_stream_via_new_stream_and_original_stream as _sync,
        )
from sakin_agac import (
        cover_me,
        pop_property,
        )
from modality_agnostic import (
        streamlib as _streamlib,
        )
from . import (
        tagged_native_item_stream_via_line_stream as _tagged_streamer,
        )
import sys


next_or_none = _streamlib.next_or_none


def _NEWSTREAM_VIA_ETC(
        # NOTE - INTERFACE CONSTANTLY CHANGING AND THAT'S OK
        # the streams:
        farstream_items,
        nearstream_path,

        # the sync parameters:
        natural_key_field_name,
        farstream_format_adapter,

        # only if you're ballsy:
        listener=None,
        ):

    def __main():
        ok and __prepare_sync_args()
        if ok:
            return __build_generator()

    def __build_generator():

        _tagged_st = _tagged_streamer(nearstream_path, listener)

        processor = _CustomProcessor(
                tagged_stream=_tagged_st,
                sync_args=sync_args,
                natural_key_field_name=natural_key_field_name,
                listener=listener,
                )

        while ok:
            x = processor.gets()
            if x is None:
                break
            yield x

    def __prepare_sync_args():

        _etc_f = farstream_format_adapter.name_value_pairs_via_native_object
        _far_f, = farstream_format_adapter.value_readers_via_field_names(natural_key_field_name)  # noqa: E501

        nonlocal sync_args
        sync_args = {
            'name_value_pairs_via_far_native_object': _etc_f,
            'far_item_stream': farstream_items,
            'natural_key_via_far_item': _far_f,

            # 'near_item_stream': provided #here1,
            # 'natural_key_via_near_item': provided #here2

            'item_via_collision': _item_via_collision,
            'listener': listener,
            }

    sync_args = None
    ok = True

    return __main()


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


class _CustomProcessor:
    """be a stream instance (through use of gets) whose elements are..

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
            tagged_stream,
            sync_args,
            natural_key_field_name,
            listener,
            ):

        self._tagged_stream = tagged_stream
        self._sync_args = sync_args
        self._natural_key_field_name = natural_key_field_name
        self._state = 'HEAD_LINES'
        self._listener = listener

    def gets(self):
        return getattr(self, self._state)()

    @_could_end_at_any_time
    def HEAD_LINES(self, tup):
        typ = tup[0]
        if 'head_line' == typ:
            pass
        elif 'table_schema_line_one_of_two' == typ:
            self._schema_row_one = tup[1]
            self._state = 'SECOND_TABLE_LINE'
            pass
        else:
            cover_me('unexpected tagged item')
        return tup

    @_could_end_at_any_time
    def SECOND_TABLE_LINE(self, tup):
        typ = tup[0]
        if 'table_schema_line_two_of_two' == typ:
            self._schema_row_two = tup[1]
            self._state = '_TRANSITION_TO_CRAZY_TOWN'
        else:
            cover_me('unexpected tagged item')
        return tup

    def _TRANSITION_TO_CRAZY_TOWN(self):

        self.__init_schema_index()

        _nat_key_via = self.__flush_natural_key_via_etc()

        _far_item_wrapperer = self.__build_far_item_wrapperer()

        _near_item_stream = self.__build_near_item_stream()

        _sync_args = pop_property(self, '_sync_args')

        self._big_deal_stream = _sync.SELF(
                near_item_stream=_near_item_stream,  # :#here1
                natural_key_via_near_item=_nat_key_via,  # :#here2
                far_item_wrapperer=_far_item_wrapperer,
                ** _sync_args)

        self._state = 'OBJECT_ROWS'
        return self.gets()

    def __build_far_item_wrapperer(self):

        name_value_pairs_via_far_native_object = self._sync_args.pop(
                'name_value_pairs_via_far_native_object')

        def build_wrapper(result_categories, listener):

            # make a prototype row from a real, encountered row.
            # do this only once you've acutally seen such a row in the near doc
            prototype_row = self.__build_prototype_row()

            def wrap(native_object):
                _pairs = name_value_pairs_via_far_native_object(native_object)
                _wrapped = prototype_row.new_via_name_value_pairs(_pairs)
                return (result_categories.OK, _wrapped)
            return wrap
        return build_wrapper

    def __build_prototype_row(self):

        _row = pop_property(self, '_first_business_object_row')
        _sch2 = pop_property(self, '_schema_row_two')

        from . import prototype_row_via_example_row_and_schema_index as x
        return x(
                example_row=_row,
                schema_index=self._SCHEMA_INDEX,
                row_schema_for_alignment=_sch2,
                )

    def __build_near_item_stream(self):

        def item_via_native_object(x):
            # only for the first row we encounter,
            # do this thing (per [#408.E])
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
        if hit_the_end:
            self._close()

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

    def __flush_natural_key_via_etc(self):  # assumes ..
        _natural_key_field_name = pop_property(self, '_natural_key_field_name')
        return self._SCHEMA_INDEX.field_reader(_natural_key_field_name)

    def __init_schema_index(self):
        _schema_row = pop_property(self, '_schema_row_one')
        from . import schema_index_via_schema_row as x
        self._SCHEMA_INDEX = x.SELF(_schema_row)

    def OBJECT_ROWS(self):
        x = next_or_none(self._big_deal_stream)
        if x is None:
            self._state = 'TAIL_LINES'
            return pop_property(self, '_TUP_ON_DECK')
        else:
            return ('takashi', x)

    @_could_end_at_any_time
    def TAIL_LINES(self, tup):
        return tup

    def _close(self):
        del(self._tagged_stream)
        del(self._state)


def _item_via_collision(far_item, near_item):
    cover_me('wahoo')


sys.modules[__name__] = _NEWSTREAM_VIA_ETC

# #born.
