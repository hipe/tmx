def maybe_express_help_for_format(cli, arg):
    """if the user passes the string "help" for the argument, display

    help for that format and terminate early. otherwise, do nothing.
    """

    if 'help' != arg:
        return

    o = cli.stderr.write
    o('the filename extension can imply a format adapter.\n')
    o('(or you can specify an adapter explicitly by name.)\n')
    o('known format adapters (and associated extensions):\n')

    out = cli.stdout.write  # imagine piping output (! errput) (Case3067DP)
    count = 0

    from kiss_rdb import SPLAY_OF_STORAGE_ADAPTERS
    _ = SPLAY_OF_STORAGE_ADAPTERS()

    for (k, ref) in _:
        _storage_adapter = ref()
        mod = _storage_adapter.module
        if mod.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES:
            _these = mod.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS
            _these = ', '.join(_these)
            _surface = f'({_these})'
        else:
            _surface = '(schema-based)'
        out(f'    {k} {_surface}\n')
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


# #history-A.4: become not executable any more
# #history-A.3: no more sync-side stream-mapping
# #history-A.2 can be temporary. as referenced.
# #history-A.1: begin become library, will eventually support "map for sync"
# #born.
