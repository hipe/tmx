def cli_for_production():
    from sys import stdout, stderr, argv
    exit(_CLI(None, stdout, stderr, argv))


def _CLI(sin, sout, serr, argv):
    from script_lib.cheap_arg_parse_branch import cheap_arg_parse_branch as br
    return br(sin, sout, serr, argv, _children())


def _children():
    yield 'parse-identifier', lambda: _CLI_for_child_1


def _CLI_for_child_1(sin, sout, serr, argv, en=None):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
        _do_CLI_for_child_1, sin, sout, serr, argv, _foz_for_child_1, None, en)


_foz_for_child_1 = (
    ('-h', '--help', 'this screen'),
    ('string', 'a string to parse as an identifier'),
)


def _do_CLI_for_child_1(mon, sin, sout, serr, input_string):
    "attempt to parse an identifier, see what goes wrong"

    def listener(sev, shape, category, *rest):
        assert 'error' == sev
        assert 'structure' == shape
        detailer, = rest  # ..
        deets = detailer()
        serr_write_line(deets['reason'])
        one, two = deets['build_two_lines_of_ASCII_art']()
        serr_write_line(one)
        serr_write_line(two)

    def serr_write_line(content):
        serr.write(content)
        serr.write('\n')

    cstack = ({'path': 'pretend-path.file', 'lineno': 1},)
    from . import _build_identifier_parser as func
    parser = func(listener, lambda: cstack)
    iden = parser(input_string)
    if iden is None:
        return 4  # assuing emitted

    sout.write('parsed!\n')
    sout.write(f'integer: {iden._integer}\n')
    x = iden._sub_component_primitive
    sout.write(f'sub-component: {x}\n')
    return 0


if '__main__' == __name__:
    cli_for_production()

# #born
