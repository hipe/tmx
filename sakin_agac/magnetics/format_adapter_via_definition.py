"""the idea here is that this is a thing all format adapters must express..

themselves through
reminder:

  - the 'natural key' is not an immutable property of the format adapter
"""


from sakin_agac import (
        cover_me,
        )


def this_one_pattern(s):

    def g(f):
        attr = "_%s" % s

        def h(self):
            x = getattr(self, attr)
            if x is None:
                cover_me('create a defaults namespace')
            return x
        return h
    return g


class _FormatAdapter:

    def __init__(
            self,

            THIS_PRETEND_THING_IS_REQUIRED,
            # while #open [#401.C] we're gonna require one thing, a placeholder

            sync_request_via_native_stream=None,
            # for far collections not near

            name_value_pairs_via_native_object=None,
            # for far collection, it must provide this per [#408.E]

            value_readers_via_field_names=None,
            # for target near collection, calculate field readers dynamically

            item_via_collision=None,
            MODULE_NAME=None,
            ):

        x = name_value_pairs_via_native_object
        if x is not None:
            # (so we can know right away that the problem wasit wasn't set)
            self._name_value_pairs_via_native_object = x

        self._sync_request_via_native_stream = sync_request_via_native_stream
        self._value_readers_via_field_names = value_readers_via_field_names

        self.MODULE_NAME = MODULE_NAME
        self.ITEM_VIA_COLLISION = 'ihi'

    def sync_request_via_native_stream(self, native_stream):

        _f = self._use_sync_request_via_native_stream()
        return _f(native_stream, self)  # @#here1

    @property
    def name_value_pairs_via_native_object(self):
        return self._name_value_pairs_via_native_object

    def value_readers_via_field_names(self, x):
        return self._value_readers_via_field_names(x)

    @this_one_pattern('sync_request_via_native_stream')
    def _use_sync_request_via_native_stream(self):
        pass

    @property
    def sync_lib(self):  # #here1
        from . import synchronized_stream_via_new_stream_and_original_stream as x  # noqa: E501
        return x


import sys  # noqa: E402
sys.modules[__name__] = _FormatAdapter  # #[#008.G] so module is callable  # noqa: E501

# #history-A.1: removed item class ("wrapper")
# #born.
