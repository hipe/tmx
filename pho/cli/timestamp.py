#!/usr/bin/env python3

from script_lib.cheap_arg_parse import cheap_arg_parse
from script_lib.cheap_arg_parse_branch import cheap_arg_parse_branch


_default_ts_path = 'z/times'
_default_ss_ID_ID = 'spreadsheet-ID-TIMESTAMPS'
_default_sheet_name = 'The Timestamp Sheet'
_default_cell_range = 'A2:C'


def _default_OTP():
    return _gs_lib().SERIALIZED_OAUTH_TOKEN_PATH


def _default_OCP():
    return _gs_lib().OAUTH_CREDENTIALS_PATH


# ==== BRANCH CLI COMMAND ====

# (we don't really want it to be a branch. we like the original interface.)


def cli_for_production():
    def enver():
        from os import environ
        return environ
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv, enver))


def _CLI(sin, sout, serr, argv, enver):
    def description():
        yield "(Currently this is just an API for other CLI's"
        yield "(in other environments) to call. BUT: this can be invoked"
        yield "directly too. NOTE we are not marreid to this branch-node"
        yield "design. experimental)"

    return cheap_arg_parse_branch(
            sin, sout, serr, argv, _commands(), description, enver)


def _commands():
    yield 'sync', lambda: _sync_CLI
    yield 'qq-mm', lambda: _qq_mm_CLI


# ==== SYNC CLI COMMAND ====

def _sync_CLI(sin, sout, serr, argv, enver=None):
    if enver and (s := enver().get('TMX_USE_THIS_PROGRAM_NAME')):
        argv[0] = s
    return cheap_arg_parse(
            _do_sync_CLI, sin, sout, serr, argv,
            tuple(_sync_params()), enver=enver)


def _sync_params():
    def default(s):
        return f'default: {s}'

    yield ('--timestamp-file=PATH', default(_default_ts_path))
    yield ('--spreadsheet-ID-ID=ID_ID', default(_default_ss_ID_ID))
    yield ('--sheet-name=NAME', default(_default_sheet_name))
    yield ('--cell-range=A1_RANGE', default(_default_cell_range))
    yield ('--oauth-token-path=PATH', default(_default_OTP()))
    yield ('--oauth-credentials-path', default(_default_OCP()))
    yield ('-n', '--dry-run', 'read from sheet but do not write to it')


def _do_sync_CLI(
        monitor, sin, sout, serr, enver,
        timestamp_file_path, ss_ID_ID, sheet_name,
        cell_range, oauth_token_path, oauth_creds_path, is_dry_run):

    "Have you ever been to sync town"

    import kiss_rdb.storage_adapters_.google_sheets as gs
    import pho.magnetics.timestamp_records_via_lines as ts

    timestamp_file_path is None and (timestamp_file_path := _default_ts_path)
    ss_ID_ID is None and (ss_ID_ID := _default_ss_ID_ID)
    sheet_name is None and (sheet_name := _default_sheet_name)
    cell_range is None and (cell_range := _default_cell_range)
    oauth_token_path is None and (oauth_token_path := _default_OTP())
    oauth_creds_path is None and (oauth_creds_path := _default_OCP())
    listener = monitor.listener

    si = gs.SpreadsheetIdentifierEXPERIMENTAL(spreadsheet_ID_ID=ss_ID_ID)
    cypher = gs.build_live_cypher()
    ss_ID = cypher.spreadsheet_ID_via_identifier(si)
    tra = gs.LiveTransactor(ss_ID, oauth_token_path, oauth_creds_path)

    # (not sure where to put this yet. definitely not here)
    cell_formats = (
        {'numberFormat': {'type': 'DATE', 'pattern': 'mm-dd'}},
        {'numberFormat': {'type': 'TIME', 'pattern': 'hh:mm'}},
        None)

    sch = gs.Schema(sheet_name, cell_range, cell_formats=cell_formats)
    col = gs.Collection(tra, sch)

    with open(timestamp_file_path) as lines:
        local_normals_itr = ts.normal_structs_via_lines(lines)
        remote_norms = col.values_get_all_native_records(listener)
        if not isinstance(remote_norms, list):
            raise "where"
        remote_norms_itr = iter(remote_norms)
        tup = ts.reference_and_normal_entities_to_sync_(
            local_normals_itr, remote_norms_itr, listener)

    ref, add_me = tup
    rows = ts.records_to_push_via_entities_to_push_(ref, add_me)
    rows = tuple(rows)
    leng = len(rows)

    if not leng:
        serr.write("all up to date? no new rows to push.\n")
        return 0

    for row in rows:
        a, b, c = row
        sout.write('(%7s, %7s, %s)\n' % (repr(a), repr(b), repr(c)))

    serr.write(f"({leng} row(s) to push)\n")

    if is_dry_run:
        return 0

    res = col.insert_records_at_top_natively(rows, listener)
    serr.write(f"batch update response: {res}\n")
    return monitor.exitstatus


# ==== THE IMAGINARY SECOND COMMAND ====

def _qq_mm_CLI(sin, sout, serr, argv, enver=None):
    return cheap_arg_parse(
            _do_qq_mm_CLI, sin, sout, serr, argv,
            tuple(_qq_mm_params()), enver=enver)


def _qq_mm_params():
    yield ('-c', '--xx-yy-option', 'desco one', 'desco two')
    yield ('-z', '--xx-yy-option-two', 'desco one', 'desco two')


def _do_qq_mm_CLI(monitor, sin, sout, serr, enver, *wat):
    "(stub for an additional command, for development & visual testing)"

    write_me()


# ====

def _gs_lib():
    import kiss_rdb.storage_adapters_.google_sheets as gs
    return gs


def write_me():
    raise RuntimeError("write me")


if '__main__' == __name__:
    cli_for_production()

# #born
