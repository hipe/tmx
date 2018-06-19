#!/usr/bin/env python3 -W error::Warning::0


"""simply traverse ("dump") the whole collection by expressing each item in

the lingua franca format: the simple JSON object.

possibly useful for piping the collection stream to another process,
or for debugging collections for example in syncing.

the collection is resolved from <collection-identifer>.
"""


def _my_parameters(o, param):

    def __desc(o, style):
        o('the collection is resolved from this')

    o['collection_identifier'] = param(
            description=__desc,
            argument_arity='REQUIRED_FIELD',
            )


def _CLI(sin, sout, serr, argv):

    # parse args

    from script_lib.magnetics import parse_stepper_via_argument_parser_index as stepperer  # noqa: E501
    reso = stepperer.SIMPLE_STEP(
            sin, serr, argv,
            _my_parameters, _desc, stdin_OK=False)
    if not reso.OK:
        return reso.exitstatus
    ci = getattr(reso.namespace, 'collection-identifier')  # #open [#601]

    # -- BEGIN should be abstracted somehow

    def listener(head_channel, *a):
        if 'error' == head_channel:
            nonlocal exitstatus
            exitstatus = 5
        express(head_channel, *a)

    from script_lib.magnetics import listener_via_resources as _
    express = _.listener_via_stderr(serr)
    exitstatus = 0  # innocent until

    # --

    from json import dumps as json_dumps

    with open_dictionary_stream(ci, listener) as dicts:
        # next(dicts)['_is_sync_meta_data']  # shear off
        for dct in dicts:
            sout.write(json_dumps(dct))
            sout.write('\n')
            sout.flush()

    return exitstatus


class open_dictionary_stream:
    """ #[#020.3]. just glue.
    """

    def __init__(self, collection_identifier, listener):
        self._collection_identifier = collection_identifier
        self._listener = listener
        self._OK = True

    def __enter__(self):
        self._OK and self.__resolve_format_adapter()
        self._OK and self.__resolve_sync_request()
        if self._OK:
            with self._opened_sync_request as sync_request:
                yield sync_request.release_sync_parameters()
                for dct in sync_request.release_dictionary_stream():
                    yield dct

    def __exit__(self, *_3):
        return False  # we did not consume the exception

    def __resolve_sync_request(self):

        from script_lib import filesystem_functions as _fsf
        _cref = self._format_adapter.collection_reference_via_string(
                self._collection_identifier)
        _ = _cref.open_sync_request(_fsf, self._listener)
        self._required('_opened_sync_request', _)

    def __resolve_format_adapter(self):

        import sakin_agac.format_adapters as _
        pair = _.procure_format_adapter(
                collection_identifier=self._collection_identifier,
                format_identifier=None,  # maybe an option one day
                listener=self._listener,
                )
        if pair is None:
            self._unable()
        else:
            self._format_adapter = pair[1].FORMAT_ADAPTER

    def _required(self, name, x):
        if x is None:
            self._unable()
        else:
            setattr(self, name, x)

    def _unable(self):
        self._OK = False


_desc = __doc__


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #born.
