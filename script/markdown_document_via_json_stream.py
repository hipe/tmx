#!/usr/bin/env python3 -W error::Warning::0

"""experiment.."""

# #[#410.N] a thing that generates markdown, in spite of `sync` existing


def _run_CLI(sin, sout, serr, argv):  # #testpoint

    from script_lib.magnetics import (
            common_upstream_argument_parser_via_everything,
            )

    _exitstatus = common_upstream_argument_parser_via_everything(
            cli_function=_CLI_body,
            std_tuple=(sin, sout, serr, argv),
            argument_moniker='<script>',
            ).execute()
    return _exitstatus


def _CLI_body(arg, prog, sout, serr):

    from script_lib.magnetics import listener_via_resources as _
    listener = _.listener_via_stderr(serr)

    _coll_id = collection_identifier_via_parsed_arg_(arg)
    from script.sync import collection_reference_via_ as _

    coll_ref = _(_coll_id, listener)
    if coll_ref is None:
        return 5

    _ = coll_ref.open_sync_request(None, listener)
    with _ as trav_req:
        trav_req.release_traversal_parameters()  # ignored for now
        dcts = trav_req.release_dictionary_stream()
        dct = next(dcts)
        dct['_is_branch_node'] or cover_me()
        express_table = _table_writer(sout, dcts)
        dct = express_table(dct)
        while dct is not None:
            sout.write('\n')
            dct = express_table(dct)
    return 0


_CLI_body.__doc__ = __doc__


def _table_writer(sout, dcts):
    def o(line):
        sout.write(line + '\n')

    def once():
        o('|(example)|#example|')
        nonlocal once

        def once():
            pass

    def f(dct):
        o(f'### {dct["label"]}')
        o('|document node|about|')
        o('|---|---|')  # black friday needs at least three
        once()  # ballsy that a mutlitable document will etc
        result = None
        for dct in dcts:
            if '_is_branch_node' in dct:
                result = dct
                break
            _markdown_link = _markdown_link_via(dct)
            o(f'|{_markdown_link}||')
        return result
    return f


def _markdown_link_via(dct):  # repeating this but meh for now
    _use_label = dct['label']
    _use_url = dct['url']
    return f'[{_use_label}]({_use_url})'


def collection_identifier_via_parsed_arg_(arg):
    typ = arg.argument_type
    if 'stdin_as_argument' == typ:
        return __collection_identifier_via_stdin(arg.stdin)
    elif 'path_as_argument' == typ:
        return arg.path
    else:
        cover_me(typ)


def __collection_identifier_via_stdin(stdin):
    import json
    _itr = (json.loads(s) for s in stdin)
    from sakin_agac import context_manager_via_iterator_ as _
    return _(_itr)


def cover_me(s=None):
    raise Exception('cover me' if s is None else f'cover me: {s}')


if __name__ == '__main__':
    import sys as o
    o.path[0] = ''
    _exitstatus = _run_CLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #born.
