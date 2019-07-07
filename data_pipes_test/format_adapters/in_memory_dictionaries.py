"""the purpose of this is to drive forward the development of format ..

..adapters with a trivially simple case, one that should probably never
be useful in production.

(the question of whether the above provision is the case is #track [#410.L])

(specifically it makes a format adapter for an array of dictionaries.)

  - for one thing, if this *is* useful, don't be afraid to move it and
    its test node into the asset tree
"""

from sakin_agac.magnetics import (
        format_adapter_via_definition,
        )


class _open_traversal_request:
    """a minimal, didactic example of an implementation for this API hookout.

    so:
      - the hookout must be a callable that results in an execution context.
        here, we chose to do this simply by using a class but that's by choice.

      - more grownup implementations might worry about closing filehandles
        or even (maybe?) database connections (or whatever)
    """

    def __init__(self, trav_req):
        self._init(** trav_req.to_dictionary())

    def _init(
            self,
            cached_document_path,
            collection_identifier,
            format_adapter,
            datastore_resources,
            listener):

        # for this format adapter the identifier *is* the collection
        self._mixed_collection_identifier = collection_identifier
        self._format_adapter = format_adapter

    def __enter__(self):  # how to be an execution context
        """for this format adapter, converting our native stream to the target

        stream shape is trivial because we are already in that item shape
        """

        x = _pop_property(self, '_mixed_collection_identifier')

        if isinstance(x, tuple):
            use_stream = iter(x)
            self._exit_me = None
        elif hasattr(x, '__enter__'):
            use_stream = x.__enter__()
            self._exit_me = x
        else:
            raise Exception("can we keep this simple? had %s" % type(x))

        format_adapter = _pop_property(self, '_format_adapter')

        return _sync_lib().SYNC_RESPONSE_VIA_DICTIONARY_STREAM(
                use_stream,
                format_adapter,
                )

    def __exit__(self, exception_class, exception, traceback):
        """(we have no open resources to close but you might)"""

        em = _pop_property(self, '_exit_me')
        if em is not None:
            return em.__exit__(exception_class, exception, traceback)
        else:
            return False


def _native_item_normalizer(dct):
    return dct  # [#418.E.2] for now dictionary is the standard


def _value_readers_via_field_names(*names):
    def reader_for(name):
        def read(normal_dict):
            return normal_dict[name]
        return read
    return [reader_for(name) for name in names]


def _pop_property(x, name):
    from sakin_agac import pop_property
    return pop_property(x, name)


# --

_functions = {
        'modality_agnostic': {
            'open_filter_request': _open_traversal_request,
            'open_sync_request': _open_traversal_request,
            }
        }

FORMAT_ADAPTER = format_adapter_via_definition(
        functions_via_modality=_functions,
        native_item_normalizer=_native_item_normalizer,
        value_readers_via_field_names=_value_readers_via_field_names,
        format_adapter_module_name=__name__,
        )


def _sync_lib():
    import sakin_agac.magnetics.synchronized_stream_via_far_stream_and_near_stream as _  # noqa: E501
    return _

# #born.
