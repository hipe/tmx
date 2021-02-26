"""
Experimental re-framing of this file (at #history-B.4):

This module used to be the __main__.py which had an initial novelty but
started to show strain. 👉 Doesn't lend itself well to testing 👉 Can't be
loaded easily as a module. So it experienced "erosion" and became way broken.

Now the new way:
- We almost called this "utilities". It's "tooling".
- It's meant to help inspect, troubleshoot, maybe integrity check, mainbe maint
- Be able to load as a module (for complex testing if you wish)
- Be able to run as a standalone CLI for now
- For now, library assets, CLI and doctests where you can all in this file
- It's not visible in the main UI for now
- Get the doctests to run from unittests, hopefully early
"""


def _cli_for_production():
    from sys import stdin, stdout, stderr, argv
    exit(_CLI_for_crazy_visual_test(stdin, stdout, stderr, argv))


def _CLI_for_crazy_visual_test(sin, sout, serr, argv):
    try:
        return _do_toolkit_CLI(sout, serr, argv, _external_functions)
    except _Stop_On_CLI_Error as e:
        return e.exitstatus


def _do_toolkit_CLI(sout, serr, argv, efx):

    bash_argv = list(reversed(argv))
    long_prog_name = bash_argv.pop()

    def bash_argv_pop(moniker):
        if len(bash_argv):
            return bash_argv.pop()
        serr.write(f"expecting {moniker}\n")
        raise _Stop_On_CLI_Error(usage())

    def unexpected():
        serr.write("unexpected argument(s)\n")
        return usage()

    def usage():
        from os.path import basename
        prog_name = basename(long_prog_name)
        serr.write(f"usage: {prog_name}")
        _ = test_names_alternation()
        serr.write(f' <collection-path> {_} [test-specific args..]\n')
        return 44

    def test_names_alternation():
        _ = ' | '.join(f'"{k}"' for k in tests.keys())
        return f'{{{_}}}'

    def command(f):  # #decorator
        tests[f.__name__] = f
        return f

    tests = {}

    @command
    def BIG_AUDIT_TRAIL():
        eid = bash_argv_pop('<entity-id>')
        mon = efx.monitor_via_stderr(serr)
        return _big_audit_trail(sout, eid, coll, mon)

    @command
    def TRAVERSE_AND_EXPLAIN():
        return _traverse_and_explain_whole_collection(sout, serr, coll)

    @command
    def RETRIEVE_ENTITY():
        entity_id = bash_argv_pop('<entity-id>')
        ent = _retrieve(entity_id, coll, listener)
        if not ent:
            return 3
        serr.write('(retrieve OK)\n')
        return 0

    @command
    def ENTITY_RETRIEVAL():
        entity_id = bash_argv_pop('<entity-id>')
        retr = _retrieval(entity_id, coll, listener)
        assert retr.entity
        assert retr.entity_section
        assert retr.file_reader
        assert retr.file_reader.body_of_text
        eid = retr.entity.identifier.to_string()
        serr.write(f"(retrieval of {eid!r} exposed four things)\n")
        return 0

    @command
    def TRAVERSE_IDENTIFIERS():
        if len(bash_argv):
            return unexpected()
        with _open_traverse_idens(coll) as idens:
            for iden in idens:
                serr.write(f'NEATO: {iden.to_string()}\n')
        return 0

    if 0 == len(bash_argv) or '-' == (coll_path := bash_argv.pop())[0]:
        return usage()

    test_name = bash_argv_pop('<test-name>')
    f = tests.get(test_name)
    if f is None:
        serr.write(f'{test_name!r} is not a test\n')
        serr.write(f'Available tests: {test_names_alternation()}\n')
        return 3

    listener = _listener_via_IO(serr)

    from kiss_rdb.storage_adapters_.eno import \
        mutable_eno_collection_via as func
    coll = func(coll_path, rng=None, listener=listener)
    if coll is None:
        return 123
    return tests[test_name]()


# ci = collection implementation


def _big_audit_trail(sout, eid, coll, mon):
    def summarize(o):
        sout.writelines(o.to_summary_lines())

    ci = coll.custom_functions
    itr = ci.AUDIT_TRAIL_FOR(eid, mon)
    if itr:
        typ, o = next(itr)
        assert 'entity_snapshot' == typ
        summarize(o)

        for typ, o in itr:
            assert 'entity_edit' == typ
            summarize(o)

            typ, o = next(itr)
            assert 'entity_snapshot' == typ

    return mon.returncode


def _traverse_and_explain_whole_collection(sout, serr, coll):  # #testpoint
    from kiss_rdb.storage_adapters_.eno._blocks_via_path import \
        document_sections_via_BoT_ as sects_via

    serr = sout  # (oops) Write to stdout not stderr (changed now)
    del sout

    cf = coll.custom_functions

    mon = cf.monitor_via_listener_(_listener_via_IO(serr))

    from kiss_rdb.storage_adapters_.eno import \
        body_of_text_ as body_of_text_via

    for path in cf.to_file_paths_():
        serr.write(f'PATH: {path}\n')

        body_of_text = body_of_text_via(path=path)

        for entb in sects_via(body_of_text, cf, mon):

            if entb.is_pass_thru_block:
                serr.write(f"  PASS THRU BLOCK (type: {entb.block_type_name})\n")  # noqa: E501
                for line in entb.to_lines():
                    serr.write(f'    LINE: {line}')
                continue

            serr.write('  ENTITY:\n')

            for line in entb.to_lines():
                serr.write(f'    IDENTITY LINE: {line}')
                break
            # (SKIPPING rest of lines from above)

            for attr_block in entb.attribute_blocks:
                serr.write('    ATTRIBUTE:\n')

                # lines = tuple(attr_block.to_lines())

                head_lines = tuple(attr_block.to_head_anchored_body_lines())
                tail_lines = tuple(attr_block.to_tail_anchored_comment_or_whitespace_lines())  # noqa: E501

                for line in head_lines:
                    serr.write(f'      LINE: {line}')

                for line in tail_lines:
                    serr.write(f'      WS: {line}')

        serr.write('END OF FILE\n')
    return 0 if mon.OK else 55


def _listener_via_IO(io):
    def listener(sev, shape, cat, *rest):
        *chan_tail, payloader = rest
        io.write(repr((sev, shape, cat, *chan_tail)))
        io.write(' ')
        if 'structure' == shape:
            sct = payloader()
            excerpt = (sct.get('reason') or sct['reason_tail'],)
        else:
            assert('expression' == shape)
            excerpt = tuple(payloader())
        io.write(repr(excerpt))
        io.write('\n')
    return listener


class _Stop_On_CLI_Error(RuntimeError):
    def __init__(self, exitstatus):
        self.exitstatus = exitstatus


# ==

def _do_CLI_NOT_USED(sin, sout, serr, file_path, rscr):
    """ad-hoc develoment utility for seeing a parsed eno document as a dump.

    not complete. (This was really just tooling to find the cause of a "bug"
    that turned out to be us cutting off the trailing newline on every
    multi-line text field because that's how the eno markup works.)
    """

    if True:
        with open(file_path) as fh:
            big_string = fh.read()

    mon = rscr().monitor
    from enolib import parse as enolib_parse
    doc = enolib_parse(big_string)

    def recurse(parent, depth=0):
        margin = margin_for(depth)
        _elements = parent.elements()
        for el in _elements:
            _these = tuple(_profile_via(el))
            one, = _these  # ..
            if 'yields_section' == one:
                sect = el.to_section()
                sout.write(f'{margin}{sect.string_key()}:\n')
                recurse(sect, depth+1)
            elif 'yields_field' == one:
                field = el.to_field()
                k = field.string_key()
                v = field.required_string_value()
                if '\n' in v:
                    sout.write(f'{margin}{k}: ')
                    sout.write(repr(v))
                    sout.write('\n')
                else:
                    sout.write(f'{margin}{k}: {v}\n')
            else:
                raise Exception(f'do me: {one}')

    def margin_for(depth):
        if len(ocd_cache) <= depth:
            for i in range(len(ocd_cache), depth+1):
                ocd_cache.append(' ' * i)
        return ocd_cache[depth]

    ocd_cache = []

    recurse(doc)
    return mon.exitstatus


def _profile_via(el):
    for m in ('yields_empty', 'yields_field', 'yields_fieldset',
              'yields_fieldset', 'yields_section'):
        if getattr(el, m)():
            yield m


# ==

def _retrieve(eid, coll, listener=None):
    """
    >>> coll = _collection_via_dict({'a': 'B', 'c': 'D'})
    >>> _retrieve('c', coll)
    'D'

    >>> _retrieve('e', coll, lambda *_: None)

    """

    return coll.retrieve_entity(eid, listener)


def _retrieval(eid, coll, listener=None):
    ci = coll.custom_functions
    idener = ci.build_identifier_function_(listener)
    iden = idener(eid)
    if iden is None:
        return
    retr, = ci.entity_retrievals((iden,), listener)
    return retr


def _open_traverse_idens(coll):
    """
    >>> coll = _collection_via_dict({'a': 'B', 'c': 'D'})
    >>> with _open_traverse_idens(coll) as idens:
    ...     result = tuple(iden.to_primitive() for iden in idens)
    >>> result
    ('a', 'c')
    """

    def two_opener():
        return coll.open_schema_and_entity_traversal(None)

    from kiss_rdb.magnetics.via_collection import conversions_ as liber
    return liber().open_traverse_identifiers_via_two_opener(two_opener)


def _collection_via_dict(dct):
    from kiss_rdb.magnetics.via_collection import \
        collection_via_dictionary as func
    return func(dct)


# ==

class _external_functions:  # #class-as-namespace

    def monitor_via_stderr(serr):
        from script_lib.magnetics.error_monitor_via_stderr import func
        return func(serr, default_error_exitstatus=4)
        # (keep the default returncode lower than git returncodes, (e.g 128))


# ==

def xx(msg=None):
    raise RuntimeError(f"write me{f': {msg}' if msg else ''}")


# ==

HELLO_I_AM_ENO_TOOLKIT_ = True  # #tespoint (only)


if '__main__' == __name__:
    _cli_for_production()

# #history-B.4
# #history-A.1
# #born.
