#!/usr/bin/env python3 -W error::Warning::0


"""simply traverse ("dump") the whole collection by expressing each item in

the lingua franca format: the simple JSON object.

possibly useful for piping the collection stream to another process,
or for debugging collections for example in syncing.

the collection is resolved from <collection-identifer>.
"""
# NOTE above is expressed in helpscreen :[#415]


def parameters_for_the_script_called_stream_(o, param):

    def __desc(o, style):
        o('the collection is resolved from this')

    o['collection_identifier'] = param(
            description=__desc,
            argument_arity='REQUIRED_FIELD',
            )


def _CLI(sin, sout, serr, argv):

    # parse args

    reso = _parse_args(sin, serr, argv)
    if not reso.OK:
        return reso.exitstatus
    coll_id = getattr(reso.namespace, 'collection-identifier')  # #open [#601]

    # work

    import script.json_stream_via_url_and_selector as siblib

    listener, exitstatuser = siblib.listener_and_exitstatuser_for_CLI(serr)

    visit = siblib.JSON_object_writer_via_IO_downstream(sout)

    with open_traversal_stream(coll_id, listener) as dcts:

        trav_params = next(dcts)  # ..
        metadata_row_dict = trav_params.to_dictionary()
        visit(metadata_row_dict)
        for dct in dcts:
            visit(dct)

    return exitstatuser()


def _parse_args(sin, serr, argv):
    from script_lib.magnetics import parse_stepper_via_argument_parser_index as _  # noqa: E501
    return _.SIMPLE_STEP(
            sin, serr, argv, parameters_for_the_script_called_stream_,
            stdin_OK=False,
            description=_desc,
            )


class open_traversal_stream:
    """ #[#020.3]. just glue.
    """

    def __init__(self, collection_identifier, listener, intention=None):
        self._intention = intention
        self._collection_identifier = collection_identifier
        self._listener = listener
        self._OK = True

    def __enter__(self):
        self._OK and self.__resolve_format_adapter()
        self._OK and self.__resolve_traversal_request()
        if self._OK:
            with self._opened_traversal_request as trav_request:
                yield trav_request.release_traversal_parameters()
                for dct in trav_request.release_dictionary_stream():
                    yield dct

    def __exit__(self, *_3):
        return False  # we did not consume the exception

    def __resolve_traversal_request(self):

        from script_lib import filesystem_functions as fsf
        coll_ref = self._format_adapter.collection_reference_via_string(
                self._collection_identifier)

        typ = self._intention  # pop_property
        if typ is None:
            typ = 'sakin_agac_synchronization'  # universally implicit default
        if 'sakin_agac_synchronization' == typ:
            trav_req = coll_ref.open_sync_request(fsf, self._listener)
        elif 'tag_lyfe_filter' == typ:
            trav_req = coll_ref.open_filter_request(fsf, self._listener)
        else:
            raise Exception('sanity')

        self._required('_opened_traversal_request', trav_req)

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
    from json_stream_via_url_and_selector import normalize_sys_path_
    normalize_sys_path_()
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #born.