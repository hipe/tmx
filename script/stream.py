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


def my_parameters_(o, param):

    def _far_coll_desc(o, style):
        _ = style.em('far_collection')
        o(f'«help for {_}')
        o('2nd line')

    o['far_collection'] = param(
             description=_far_coll_desc,
             )

    o['far_format'] = param(
            description=try_help_('«the far_format»'),
            argument_arity='OPTIONAL_FIELD',
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


def maybe_express_help_for_format_(cli, arg):

    if 'help' == arg:
        return _do_express_help_for_formats(cli)
    else:
        return _OK_simply


def _do_express_help_for_formats(cli):

    o = cli.stderr.write
    o('the filename extension can imply a format adapter.\n')
    o('(or you can specify an adapter explicitly by name.)\n')
    o('known format adapters (and associated extensions):\n')

    out = cli.stdout.write  # #coverpoint6.3: imagine piping output (! errput)

    count = 0
    for (k, mod) in _format_adapters_module().to_name_value_pairs():
        _these = ', '.join(mod.FORMAT_ADAPTER.associated_filename_globs)
        out(f'    {k} ({_these})\n')
        count += 1
    o(f'({count} total.)\n')
    return _stop_early


"""
our experimental new "CLI visitor" internal API:

objectives:

  - DRY things across CLI's without *too much* API
  - more specifically, we really don't want to have a CLI base class

easy provisions:

  - a call to such a visitor will always result in a custom object (i.e
    never None or False)
  - the result object will always have `result.OK` which is always True or
    False. (False doesn't necessarily mean an error occured.)
  - IFF False, will always provide a `result.exitstatus` which is an integer.

fun provisions:

  - will have a `result.result_values` that is either None or a dictionary
"""


class parse_args_:

    def __init__(self, cli, argv, define_params, desc):
        from script_lib.magnetics import (
                parse_stepper_via_argument_parser_index as stepperer,
                )
        reso = stepperer.SIMPLE_STEP(
                cli.stdin, cli.stderr, argv, define_params,
                description=desc,
                )
        ok = reso.OK
        self.OK = ok
        if ok:
            self.result_values = {'namespace': reso.namespace}
        else:
            self.exitstatus = reso.exitstatus


def must_be_interactive_(cli):

    if cli.stdin.isatty():
        return _OK_simply
    else:
        o = cli.stderr.write
        o('cannot yet read from STDIN.\n')
        o('(but maybe one day if there\'s interest.)\n')
        return _not_OK_generically


def listener_for_(cli):
    """
    pass-thru all emissions, but whenever an emission begins with 'error',

    set an errorstatus and return early.
    """

    from script_lib.magnetics import listener_via_resources as lib
    express = lib.listener_via_stderr(cli.stderr)

    def f(head_channel, *a):
        if 'error' == head_channel:
            # (there can be multiple such emissions)
            cli.stop_via_exitstatus_(6)  # meh
        express(head_channel, *a)
    return f


class _stop_early:  # #class-as-namespace
    OK = False
    exitstatus = 0


class _not_OK_generically:  # #class-as-namespace
    OK = False
    exitstatus = 5


class _OK_simply:  # #class-as-namespace
    OK = True
    result_values = None


def try_help_(s):
    def f(o, style):
        o(f"{s} (try 'help')")
    return f


def collection_reference_via_(
        collection_identifier,
        listener,
        format_identifier=None,
        ):
    pair = _format_adapters_module().procure_format_adapter(
            collection_identifier=collection_identifier,
            format_identifier=format_identifier,
            listener=listener,
            )
    if not pair:
        return
    FA_NAME, format_adapter_module = pair
    _fa = format_adapter_module.FORMAT_ADAPTER
    _ref = _fa.collection_reference_via_string(collection_identifier)
    return _ref  # #todo


def _format_adapters_module():
    """by putting this in a function that is called 3x in this file..

    (virtually a singleton object), we free ourselves from passing it from
    the higher-level modality- to the lower-level API-endpiont; so that
    callers to the latter need not concern themselves with it as a
    parameter. (but note it's a challenge to OCD that this is called 2x
    per typical invocation.)
    """

    import sakin_agac.format_adapters as mod
    return mod


if __name__ == '__main__':
    from json_stream_via_url_and_selector import normalize_sys_path_
    normalize_sys_path_()
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #history-A.1: begin become library, will eventually support "map for sync"
# #born.
