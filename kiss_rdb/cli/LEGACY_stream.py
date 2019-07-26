"""simply traverse ("dump") the whole collection by expressing each item in

the lingua franca format: the simple JSON object.

possibly useful for piping the collection stream to another process,
or for debugging collections for example in syncing.
"""
# NOTE above is expressed in helpscreen :[#415]
# #[#874.5] file used to be executable script and may need further changes
# #[#874.9] file is "LEGACY"

from kiss_rdb import dictionary_dumper_as_JSON_via_output_stream

_is_entrypoint_file = __name__ == '__main__'


def _my_parameters(o, param):

    common_parameters_from_the_script_called_stream_(o, param)

    def dsc_for_etc():  # be like [#511.3]
        yield 'apply any custom mappers, keyers, etc for syncing.'
        yield 'with this, you see exactly what the syncing operation sees.'
        yield 'without this, you see the "raw" output of the producer script.'
        # this feature is :[#458.I.3.1] (cross-referenced to here)

    o['apply_sync_related_functions'] = param(
            description=dsc_for_etc,
            argument_arity='FLAG',
            )


def common_parameters_from_the_script_called_stream_(o, param):

    def _far_coll_desc(style):  # [#511.4] linser with styler
        _ = style.em('far_collection')
        yield f'«help for {_}'
        yield '2nd line'

    o['far_collection'] = param(
             description=_far_coll_desc,
             )


class _CLI:  # #open [#607.4] de-customize this custom CLI

    def __init__(self, sin, sout, serr, argv):
        self.stdin = sin
        self._sout = sout
        self.stderr = serr
        self.ARGV = argv
        self.OK = True
        self.exitstatus = 0

    def execute(self):
        # stopping early is (Case3063DP)
        must_be_interactive_(self)
        self.OK and parse_args_(self, '_namespace', _my_parameters, _desc)
        self.OK and self.__init_attributes_via_namespace()
        self.OK and maybe_express_help_for_format_(self, self._coll_id)
        self.OK and setattr(self, '_listener', listener_for_(self))
        self.OK and self.__work()
        return self.exitstatus

    def __work(self):
        if self._yes_apply_sync_related_funcs:
            self.__work_complicated()
        else:
            self.__work_simple()

    def __work_complicated(self):
        sout = self._sout

        pairs = _traversal_stream_for_sync(
                cached_document_path=None,
                collection_identifier=self._coll_id,
                listener=self._listener)

        if pairs is None:
            raise Exception('cover me - the above failed')

        for (key, dct) in pairs:
            sout.write(f'{key}  {dct}\n')

    def __work_simple(self):

        visit = dictionary_dumper_as_JSON_via_output_stream(self._sout)

        _ = open_traversal_stream_TEMPORARY_LOCATION(
                cached_document_path=None,  # (we don't test CLI)
                collection_identifier=self._coll_id,
                intention=None,
                listener=self._listener)

        with _ as dcts:
            trav_params = next(dcts)  # ..
            metadata_row_dict = trav_params.to_dictionary()
            visit(metadata_row_dict)
            for dct in dcts:
                visit(dct)

    def __init_attributes_via_namespace(self):
        # (unlike sibling at namespace, we'll use attrs instead of a dict.)
        ns = _pop_property(self, '_namespace')
        self._yes_apply_sync_related_funcs = ns.apply_sync_related_functions
        self._coll_id = getattr(ns, 'far-collection')  # #open [#601]


def _traversal_stream_for_sync(  # #testpoint
        cached_document_path,
        collection_identifier,
        listener):

    coll_ref = collection_reference_via_(collection_identifier, listener)
    if coll_ref is None:
        return

    _fsf = _filesystem_functions()
    from kiss_rdb.storage_adapters_.markdown_table.magnetics_ import (
        normal_far_stream_via_collection_reference as _)

    far_sess_cm = _.OPEN_FAR_SESSION(
        far_collection_reference=coll_ref,
        cached_document_path=cached_document_path,
        datastore_resources=_fsf,
        listener=listener)

    with far_sess_cm as far_sess:
        if not far_sess.OK:
            return
        far_st = far_sess.release_normal_far_stream()
        for pair in far_st:
            yield pair


class open_traversal_stream_TEMPORARY_LOCATION:
    """ #[#020.3]. just glue.

    [#874.7] non-CLI should not load CLI to use this
    """

    def __init__(
            self,
            intention,
            cached_document_path,
            collection_identifier,
            listener,
            ):
        self._intention = intention
        self._collection_identifier = collection_identifier
        self._cached_document_path = cached_document_path
        self._listener = listener
        self.OK = True

    def __enter__(self):

        _ = _pop_property(self, '_collection_identifier')
        coll_ref = collection_reference_via_(_, self._listener)
        if coll_ref is None:
            return

        intention = _pop_property(self, '_intention')
        if intention is None:
            intention = 'sakin_agac_synchronization'  # noqa: E501 - universally implicit default

        _meth_name = _method_name_via_intention(intention)

        _meth = getattr(coll_ref, _meth_name)

        trav_cm = _meth(
                cached_document_path=self._cached_document_path,
                datastore_resources=_filesystem_functions,
                listener=self._listener)

        if trav_cm is None:
            return

        with trav_cm as trav_response:
            yield trav_response.release_traversal_parameters()
            for dct in trav_response.release_dictionary_stream():
                yield dct

    def __exit__(self, *_3):
        return False  # we did not consume the exception


_desc = __doc__


def maybe_express_help_for_format_(cli, arg):
    """if the user passes the string "help" for the argument, display

    help for that format and terminate early. otherwise, do nothing.
    """

    if 'help' == arg:
        return _do_express_help_for_formats(cli)


def _do_express_help_for_formats(cli):

    o = cli.stderr.write
    o('the filename extension can imply a format adapter.\n')
    o('(or you can specify an adapter explicitly by name.)\n')
    o('known format adapters (and associated extensions):\n')

    out = cli.stdout.write  # imagine piping output (! errput) (Case3067DP)

    count = 0
    for (k, mod) in _format_adapters_module().to_name_value_pairs():
        _these = ', '.join(mod.FORMAT_ADAPTER.associated_filename_globs)
        out(f'    {k} ({_these})\n')
        count += 1
    o(f'({count} total.)\n')
    cli.exitstatus = 0  # because [#608.7] it was "guilty till proven innocent"
    cli.OK = False  # this is "stop early" in [#608.6] speak


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


all this is now labelled as :[#608.5]. (compare to [#608.6]).
"""


def parse_args_(cli, write_attr, params, desc):

    # (at #history-A.2 archived [#608.5] old way)

    reso = _parse_args(cli, cli.ARGV, params, desc)
    ok = reso.OK
    cli.OK = ok  # make extra unnecessary contact for now..
    if ok:
        setattr(cli, write_attr, reso.namespace)
    else:
        cli.exitstatus = reso.exitstatus


def _parse_args(cli, argv, define_params, desc):

        from script_lib.magnetics import (
                parse_stepper_via_argument_parser_index as stepperer)

        reso = stepperer.SIMPLE_STEP(
                cli.stdin, cli.stderr, argv, define_params,
                stdin_OK=False,  # ..
                description=desc,
                )
        return reso


def must_be_interactive_(cli):

    # (at #history-A.2 removed [#608.5] as old way)

    if cli.stdin.isatty():
        pass  # OK
    else:
        o = cli.stderr.write
        o('cannot yet read from STDIN.\n')
        o('(but maybe one day if there\'s interest.)\n')
        cli.exitstatus = 5  # generic_failure_exitstatus
        cli.OK = False


def listener_for_(cli):
    """
    pass-thru all emissions, but whenever an emission begins with 'error',

    set an errorstatus and return early.
    """

    from script_lib.magnetics import listener_via_stderr
    express = listener_via_stderr(cli.stderr)

    def f(head_channel, *a):
        if 'error' == head_channel:
            # (there can be multiple such emissions)
            # at #history-A.2 we changed this to be the direct way
            cli.exitstatus = 6  # meh
            cli.OK = False
        express(head_channel, *a)
    return f


def try_help_(s):
    def lineser(style):  # [#511.3] lineser and [#511.4] styler
        style.hello_styler()
        yield f"{ s } (try 'help')"
    return lineser


def _method_name_via_intention(intention):
    if 'sakin_agac_synchronization' == intention:
        return 'open_sync_request'
    else:
        assert('tag_lyfe_filter' == intention)
        return 'open_filter_request'


def collection_reference_via_(
        collection_identifier,
        listener,
        format_identifier=None,
        ):
    pair = _format_adapters_module().procure_format_adapter(
            collection_identifier=collection_identifier,
            format_identifier=format_identifier,
            listener=listener)
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

    import kiss_rdb.LEGACY_format_adapter_collection as mod
    return mod


def _filesystem_functions():
    from script_lib import filesystem_functions as _
    return _


def _pop_property(self, var):  # #cp
    x = getattr(self, var)
    delattr(self, var)
    return x


if _is_entrypoint_file:
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #history-A.2 can be temporary. as referenced.
# #history-A.1: begin become library, will eventually support "map for sync"
# #born.
