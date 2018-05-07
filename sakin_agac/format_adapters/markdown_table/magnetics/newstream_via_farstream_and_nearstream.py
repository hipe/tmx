from sakin_agac.magnetics import (
        synchronized_stream_via_new_stream_and_original_stream as _sync,
        )
from sakin_agac import (
        cover_me,
        release,
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

        _far_f, = farstream_format_adapter.value_readers_via_field_names(natural_key_field_name)  # noqa: E501

        nonlocal sync_args
        sync_args = {
            'far_item_stream': farstream_items,
            'natural_key_via_far_item': _far_f,

            # 'near_item_stream': provided #here1,
            # 'natural_key_via_near_item': provided #here2

            'item_via_collision': _item_via_collision,
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
            self._schema_row = tup[1]
            self._state = 'SECOND_TABLE_LINE'
            pass
        else:
            cover_me('unexpected tagged item')
        return tup

    @_could_end_at_any_time
    def SECOND_TABLE_LINE(self, tup):
        typ = tup[0]
        if 'table_schema_line_two_of_two' == typ:
            self._state = '_TRANSITION_TO_CRAZY_TOWN'
        else:
            cover_me('unexpected tagged item')
        return tup

    def _TRANSITION_TO_CRAZY_TOWN(self):

        _near_item_stream = self.__build_near_item_stream()

        _this_etc = self._will_break_this_up()

        _sync_args = self._release('_sync_args')

        self._big_deal_stream = _sync.SELF(
                near_item_stream=_near_item_stream,  # :#here1
                natural_key_via_near_item=_this_etc,  # :#here2
                ** _sync_args)

        self._state = 'OBJECT_ROWS'
        return self.gets()


    def __build_near_item_stream(self):

        _Item = self.__build_near_item_class()

        hit_the_end = True
        for tup in self._tagged_stream:
            typ, x = tup
            if 'business_object_row' == typ:
                _item = _Item(x)
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
            """

            def __init__(self2, row_DOM):
                self2.ROW_DOM_ = row_DOM

            def to_line(self2):
                return self2.ROW_DOM_.to_line()

        return _NearItem

    def _will_break_this_up(self):
        schema_row = self._release('_schema_row')
        natural_key_field_name = self._release('_natural_key_field_name')
        # == == ==
        _field_readerer = schema_row.build_field_readerer__()
        return _field_readerer(natural_key_field_name)

    def OBJECT_ROWS(self):
        x = next_or_none(self._big_deal_stream)
        if x is None:
            self._state = 'TAIL_LINES'
            return self._release('_TUP_ON_DECK')
        else:
            return ('takashi', x)

    @_could_end_at_any_time
    def TAIL_LINES(self, tup):
        return tup

    def _close(self):
        del(self._tagged_stream)
        del(self._state)

    _release = release


def _item_via_collision(far_item, near_item):
    cover_me('wahoo')


sys.modules[__name__] = _NEWSTREAM_VIA_ETC

# #born.
