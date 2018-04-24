"""the idea here is that this is a thing all format adapters must express..

themselves through
"""


class _SELF:

    def __init__(
            self,
            item_stream_via_native_stream,
            thing_two,
            ):

        if item_stream_via_native_stream is None:
            item_stream_via_native_stream = _item_stream_via_stream_default

        self.item_stream_via_native_stream = item_stream_via_native_stream


def _item_stream_via_stream_default(
        stream,
        natural_key_via_object,
        ):

    def _item_via_object(x):
        _nat_key = natural_key_via_object(x)
        return _Item(_nat_key, x)

    return (_item_via_object(x) for x in stream)


class _Item:

    def __init__(self, nat_key, x):
        self.natural_key = nat_key
        self.NATIVE_OBJECT = x


import sys  # noqa: E402
sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #born.
