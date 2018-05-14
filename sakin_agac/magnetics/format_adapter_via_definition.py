"""the idea here is that this is a thing all format adapters must express..

themselves through
reminder:

  - the 'natural key' is not an immutable property of the format adapter
"""

from sakin_agac import (
        cover_me,
        sanity,
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

            format_adapter_module_name,
            # a human key is derived from this for the [#505] collection API

            functions_via_modality=None,
            # if this format can be used as a "near" collection for syncing

            session_for_sync_request=None,
            # for far collections not near

            name_value_pairs_via_native_object=None,
            # for far collection, it must provide this per [#408.E]

            value_readers_via_field_names=None,
            # for target near collection, calculate field readers dynamically

            associated_filename_globs=(),
            ):

        # properties with ad-hoc normalization/validation slash

        # # this is a common error that *really* trips us up) #open [#412]

        if str is type(associated_filename_globs):
            sanity('you meant to put a tuple not a string here')

        # # this should be abstracted if pattern

        x = name_value_pairs_via_native_object
        if x is not None:
            # (so we can know right away that the problem was it wasn't set)
            self._name_value_pairs_via_native_object = x

        # properties that are stored as private because we get fancy:

        self._session_for_sync_request = session_for_sync_request
        self._value_readers_via_field_names = value_readers_via_field_names

        # KISS properties:

        self.functions_via_modality = functions_via_modality
        self.associated_filename_globs = associated_filename_globs
        self.format_adapter_module_name = format_adapter_module_name

    def session_for_sync_request_(
            self,
            mixed_collection_identifier,
            modality_resources,
            listener,
            ):

        _f = self._use_session_for_sync_request()
        _ = _f(mixed_collection_identifier, modality_resources, self, listener)
        return _  # #todo

    @property
    def name_value_pairs_via_native_object(self):
        return self._name_value_pairs_via_native_object

    def value_readers_via_field_names(self, x):
        return self._value_readers_via_field_names(x)

    @this_one_pattern('session_for_sync_request')
    def _use_session_for_sync_request(self):
        pass

    @property
    def sync_lib(self):  # #here1
        from . import synchronized_stream_via_new_stream_and_original_stream as x  # noqa: E501
        return x


import sys  # noqa: E402
sys.modules[__name__] = _FormatAdapter  # #[#008.G] so module is callable  # noqa: E501

# #history-A.1: removed item class ("wrapper")
# #born.
