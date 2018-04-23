#!/usr/bin/env python3 -W error::Warning::0

_description_of_sync = """the sync utility
is a bold and important experiment
EDIT
"""


def __my_parameters(o, param):

    o['from_thing'] = param(
            description='«help for from_thing»',
            )

    def __thing_two_desc(o, style):
        o('«help for {}'.format(style.em('to_thing')))
        o('2nd line')

    o['to_thing'] = param(
            description=__thing_two_desc,
            )

    def _plus_etc(s):
        def f(o, style):
            o("{} (try 'help')".format(s))
        return f

    o['from_format'] = param(
            description=_plus_etc('«the from_format»'),
            argument_arity='OPTIONAL_FIELD',
            )

    o['to_format'] = param(
            description=_plus_etc('«the to_format»'),
            argument_arity='OPTIONAL_FIELD',
            )


def _myCLI(sin, sout, serr, argv):

    from script_lib.magnetics import (
            parse_stepper_via_argument_parser_index as stepperer,
            )
    reso = stepperer.SIMPLE_STEP(
            serr, argv, __my_parameters, _description_of_sync)
    if reso.OK:
        print("OK! : {}".format(reso.namespace))
        return 0
    else:
        return reso.exitstatus


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    _exitstatus = _myCLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #history-A.1: replace hand-written argparse with agnostic modeling
# #born.
