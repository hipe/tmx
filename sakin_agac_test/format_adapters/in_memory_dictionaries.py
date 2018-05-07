"""the purpose of this is to drive forward the development of format ..

..adapters with a trivially simple case, one that should probably never
be useful in production.

(specifically it makes a format adapter for an array of dictionaries.)

  - for one thing, if this *is* useful, don't be afraid to move it and
    its test node into the asset tree
"""

from sakin_agac.magnetics import (
        format_adapter_via_definition,
        )


def _sync_request_via_etc(native_stream, format_adapter):
    """for this format, converting our native stream to the target is..

    straightforward because we already are a dictionary stream.
    """

    _WEE = format_adapter.sync_lib.SYNC_REQUEST_VIA_DICTIONARY_STREAM(
            native_stream,
            format_adapter,
            )
    return _WEE  # #todo


def _value_readers_via_field_names(*names):
    def reader_for(name):
        def read(native_object):
            return native_object[name]  # [#410.B] death of item class imagine  # noqa: E501
        return read
    return [reader_for(name) for name in names]


FORMAT_ADAPTER = format_adapter_via_definition(
        THIS_PRETEND_THING_IS_REQUIRED=True,
        sync_request_via_native_stream=_sync_request_via_etc,
        value_readers_via_field_names=_value_readers_via_field_names,
        )

# #born.
