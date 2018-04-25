"""the idea here is that this is a thing all format adapters must express..

themselves through
"""


class _SELF:

    def __init__(
            self,
            item_via_collision,
            item_stream_via_native_stream,
            natural_key_via_object,
            ):

        if item_via_collision is not None:
            self._item_via_collision = item_via_collision

        self._item_stream_via_native_stream = item_stream_via_native_stream

        if natural_key_via_object is not None:
            self._natural_key_via_object = natural_key_via_object

    # == BEGIN experiment

    def copy_and_edit(
            self,
            **kwargs,
            ):
        from copy import copy
        me = copy(self)
        me.__reinit(kwargs)
        return me

    def __reinit(self, kwargs):

        k = 'item_via_collision'
        if k in kwargs:
            self._item_via_collision = kwargs.pop(k)

        k = 'item_stream_via_native_stream'
        if k in kwargs:
            self._item_stream_via_native_stream = kwargs.pop(k)

        k = 'natural_key_via_object'
        if k in kwargs:
            self._natural_key_via_object = kwargs.pop(k)

    # == END

    def synchronized_stream_via_these_two(self, new_item_st, orig_item_st):
        import sakin_agac.magnetics.synchronized_stream_via_new_stream_and_original_stream as x  # noqa: E501
        return x(
                new_item_stream=new_item_st,
                original_item_stream=orig_item_st,
                item_via_collision=self._item_via_collision,
                )

    def item_stream_via_native_stream(self, native_stream):
        """ implementation note: currently we evaluate things lazily to

        decide whether we need to build the default function or not.
        this happens on every call to this function.

        in practice we assume this cost is negligible because we don't
        expect this to be called more than 1x per runtime.

        but if we had to, we could make this choice more eagerly somehow.
        """

        f = self._item_stream_via_native_stream
        if f is None:
            f = _item_stream_via_native_stream__via__natural_key_via_object(
                    self._natural_key_via_object)
        return f(native_stream)


def _item_stream_via_native_stream__via__natural_key_via_object(
        natural_key_via_object,
        ):

    def _item_via_object(x):
        _nat_key = natural_key_via_object(x)
        return _Item(_nat_key, x)

    def g(native_stream):
        return (_item_via_object(x) for x in native_stream)

    return g


class _Item:

    def __init__(self, natural_key, NATIVE_OBJECT):
        self.natural_key = natural_key
        self.NATIVE_OBJECT = NATIVE_OBJECT


import sys  # noqa: E402
sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #born.
