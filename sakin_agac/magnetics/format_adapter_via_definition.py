"""the idea here is that this is a thing all format adapters must express..

themselves through
reminder:

  - the 'natural key' is not an immutable property of the format adapter
"""

from sakin_agac import (
        sanity,
        )


class _FormatAdapter:

    def __init__(
            self,

            format_adapter_module_name,
            # a human key is derived from this for the [#505] collection API

            functions_via_modality=None,
            # if this format can be used as a "near" collection for syncing

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

        self._value_readers_via_field_names = value_readers_via_field_names

        self._format_name = None

        # KISS properties:

        self.functions_via_modality = functions_via_modality
        self.associated_filename_globs = associated_filename_globs
        self.format_adapter_module_name = format_adapter_module_name

    def collection_reference_via_string(self, coll_id):
        return _CollectionReference(coll_id, self)

    def _open_sync_request(  # #testpoint
            self,
            mixed_collection_identifier,
            modality_resources,
            listener,
            ):

        """at #history-A.2 we changed this to be accessed like other

        hoi-polloi functions that can be associated with the doo-hah adapter
        """

        def dig_f():
            yield ('modality_agnostic', 'sub-section')
            yield ('open_sync_request', 'thing ding two')

        _f = self.DIG_HOI_POLLOI(dig_f(), listener)
        if _f is None:
            return  # #coverpoint5.1 GONE at #history-A.1 (see c.p tombstone)
        return _f(mixed_collection_identifier, modality_resources, self, listener)  # noqa: E501

    def DIG_HOI_POLLOI(self, step_tuples, listener):
        """EXPERIMENT -- like ruby's new `dig` but with extra natural messages

        see provisos of the callee function too..
        """

        def use_step_tuples():
            # cleverly (or not) we DRY into this function this first
            # step-component that we always use (for now) etc

            # the FA might not have defined any such functions at all
            yield ('functions_via_modality', 'property', {'do_splay': False})

            for step_tuple in step_tuples:
                yield step_tuple

        return self._dig_anything(use_step_tuples(), listener)

    def _dig_anything(self, step_tuples, listener):
        """NOTE - no caching - we should be caching maybe
        """

        import sakin_agac.magnetics.via_human_keyed_collection as lib

        def say_collection():
            return 'the %s format adapter' % repr(self.format_name)

        current_node = lib.human_keyed_collection_via_object(self)

        for step_tuple in step_tuples:

            if 2 < len(step_tuple):
                (kwargs,) = step_tuple[2:]
            else:
                kwargs = _empty_hash

            tup = lib.procure(
                human_keyed_collection=current_node,
                needle_function=step_tuple[0],
                listener=listener,
                item_noun_phrase=step_tuple[1],
                say_collection=say_collection,  # ..
                **kwargs,
                )

            if tup is None:
                current_node = None
                break
            current_node = tup[1]  # diregard particular name
        return current_node

    @property
    def name_value_pairs_via_native_object(self):
        return self._name_value_pairs_via_native_object

    def value_readers_via_field_names(self, x):
        return self._value_readers_via_field_names(x)

    @property
    def sync_lib(self):  # #here1
        from . import synchronized_stream_via_far_stream_and_near_stream as x  # noqa: E501
        return x

    @property
    def format_name(self):
        if self._format_name is None:
            import re
            _ = re.search(r'(?<=\.)[^.]+$', self.format_adapter_module_name)[0]
            self._format_name = _
        return self._format_name


class _CollectionReference:

    def __init__(self, s, fa):
        self.collection_identifier_string = s
        self.format_adapter = fa

    def open_sync_request(self, resources, listener):
        return self.format_adapter._open_sync_request(
                self.collection_identifier_string, resources, listener)

    @property
    def format_name(self):
        return self.format_adapter.format_name


_empty_hash = {}


import sys  # noqa: E402
sys.modules[__name__] = _FormatAdapter  # #[#008.G] so module is callable  # noqa: E501

# #history-A.3: as referenced
# #history-A.2: as referenced
# #history-A.1: removed item class ("wrapper")
# #born.
