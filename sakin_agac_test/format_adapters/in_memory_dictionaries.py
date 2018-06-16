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


class _session_for_sync_request:
    """a minimal, didactic example of an implementation for this API hookout.

    so:
      - the hookout must be a callable that results in an execution context.
        here, we chose to do this simply by using a class but that's by choice.

      - more grownup implementations might worry about closing filehandles
        or even (maybe?) database connections (or whatever)
    """

    def __init__(
            self,
            mixed_collection_identifier,
            modality_resources,
            format_adapter,
            listener,
            ):

        """[constructor..]

        mixed_collection_identifier -- [..] #todo

        modality_resources -- #todo how do we know we're getting the right 1?

        format_adapter -- although typically you are here sitting in the
                    same module that builds this selfsame format adapter,
                    we don't want to rely on that assumption.

        listener -- a callback following our [#017] listener pattern.
                    can be used as a logger. can be used for more, too.
        """

        # for this format adapter the identifier *is* the collection
        self._mixed_collection_identifier = mixed_collection_identifier
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

        return format_adapter.sync_lib.SYNC_REQUEST_VIA_DICTIONARY_STREAM(
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


def _name_value_pairs_via_native_object(dct):
    return ((k, dct[k]) for k in dct)


def _value_readers_via_field_names(*names):
    def reader_for(name):
        def read(native_object):
            return native_object[name]  # [#410.B] death of item class imagine  # noqa: E501
        return read
    return [reader_for(name) for name in names]


def _pop_property(x, name):
    from sakin_agac import pop_property
    return pop_property(x, name)


# --

_functions = {
        'modality_agnostic': {
            'session_for_sync_request': _session_for_sync_request,
            }
        }

FORMAT_ADAPTER = format_adapter_via_definition(
        functions_via_modality=_functions,
        name_value_pairs_via_native_object=_name_value_pairs_via_native_object,
        value_readers_via_field_names=_value_readers_via_field_names,
        format_adapter_module_name=__name__,
        )

# #born.
