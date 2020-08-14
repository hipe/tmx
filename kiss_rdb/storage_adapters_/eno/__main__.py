def _CLI_for_crazy_visual_test(sin, sout, serr, argv):
    try:
        return _do_crazy_CLI(sout, serr, argv)
    except _Stop_On_CLI_Error as e:
        return e.exitstatus


def _do_crazy_CLI(sout, serr, argv):

    bash_argv = list(reversed(argv))
    prog_name = bash_argv.pop()

    def bash_argv_pop(moniker):
        if len(bash_argv):
            return bash_argv.pop()
        serr.write(f"expecting {moniker}\n")
        raise _Stop_On_CLI_Error(usage())

    def unexpected():
        serr.write("unexpected argument(s)\n")
        return usage()

    def usage():
        serr.write(f"usage: {prog_name}")
        _ = test_names_alternation()
        serr.write(f' <collection-path> {_} [test-specific args..]\n')
        return 44

    def test_names_alternation():
        _ = ' | '.join(f'"{k}"' for k in tests.keys())
        return f'{{{_}}}'

    def test(f):  # #decorator
        tests[f.__name__] = f
        return f

    tests = {}

    @test
    def BIG_THING():
        return _the_main_experiment(sout, serr, coll)

    @test
    def RETRIEVE_ENTITY():
        entity_id = bash_argv_pop('<entity-id>')
        from kiss_rdb.magnetics_.identifier_via_string import \
            identifier_via_string_

        listener = _listener_via_IO(serr)
        iden = identifier_via_string_(entity_id, listener)
        if iden is None:
            return 3
        ent = coll.retrieve_entity_as_storage_adapter_collection(
                iden, listener)
        if not ent:
            return 3
        serr.write('(retrieve OK)\n')
        return 0

    @test
    def TRAVERSE_IDENTIFIERS():
        if len(bash_argv):
            return unexpected()
        idens = coll.to_identifier_stream_as_storage_adapter_collection(None)
        for iden in idens:
            serr.write(f'NEATO: {iden.to_string()}\n')
        return 0

    if 0 == len(bash_argv) or '-' == (coll_path := bash_argv.pop())[0]:
        return usage()

    test_name = bash_argv_pop('<test-name>')
    f = tests.get(test_name)
    if f is None:
        serr.write(f'expecting {test_names_alternation()}')
        serr.write(f' had {repr(test_name)}\n')
        return 3

    from kiss_rdb.storage_adapters_.eno import collection_via_collection_path_
    coll = collection_via_collection_path_(coll_path)
    return tests[test_name]()


def _the_main_experiment(sout, serr, coll):

    from kiss_rdb.storage_adapters_.eno.blocks_via_path_ import \
        _existing_entity_blocks_via_BoT

    mon = coll.monitor_via_listener_(_listener_via_IO(serr))
    for path in coll.to_file_paths_():
        serr.write(f'PATH: {path}\n')

        body_of_text = coll.body_of_text_via_(path=path)

        for entb in _existing_entity_blocks_via_BoT(body_of_text, coll, mon):
            serr.write('  ENTITY:\n')

            for line in entb.to_lines():
                serr.write(f'    IDENTITY LINE: {line}')
                break
            # (SKIPPING rest of lines from above)

            for attr_block in entb.to_attribute_block_stream():
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


def _CLI(sin, sout, serr, argv):
    raise RuntimeError("we made this unreachable at #history-A.1 but etc")

    # == BEGIN experiment (take this out and it still works)
    from os import PathLike

    class Xx(PathLike):
        def __fspath__(self):
            return _experiment()

    argv[0] = Xx()
    # == END

    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            _do_CLI, sin, sout, serr, argv,
            formal_parameters=(('file', 'some eno file'),),
            description_template_valueser=lambda: {})


def _do_CLI(mon, sin, sout, serr, file_path):
    """ad-hoc develoment utility for seeing a parsed eno document as a dump.

    not complete. (This was really just tooling to find the cause of a "bug"
    that turned out to be us cutting off the trailing newline on every
    multi-line text field because that's how the eno markup works.)
    """

    if True:
        with open(file_path) as fh:
            big_string = fh.read()

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


def _experiment():
    here = __file__
    _tail = here[here.index('kiss_rdb'):]  # not robust
    from os.path import dirname
    _inner = dirname(_tail)
    from os import sep as path_separator
    _mod_name = _inner.replace(path_separator, '.')
    return f'py -m {_mod_name}'


def _profile_via(el):
    for m in ('yields_empty', 'yields_field', 'yields_fieldset',
              'yields_fieldset', 'yields_section'):
        if getattr(el, m)():
            yield m


if '__main__' == __name__:
    import sys as o
    exit(_CLI_for_crazy_visual_test(o.stdin, o.stdout, o.stderr, o.argv))

# #history-A.1
# #born.
