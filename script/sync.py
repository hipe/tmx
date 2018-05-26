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


class _CLI:  # #coverpoint

    def __init__(self, sin, sout, serr, argv):
        self._sin = sin
        self._sout = sout
        self._serr = serr
        self._argv = argv

    def execute(self):
        self._exitstatus = 5
        self._OK = True
        self._OK and self.__be_sure_interactive()
        self._OK and self.__NEXT_THING()
        return self._pop_property('_exitstatus')

    def __be_sure_interactive(self):
        if not self._sin.isatty():
            self.__when_STDIN_is_noninteractive()

    def __when_STDIN_is_noninteractive(self):
        serr = self._serr
        serr.write("cannot yet read from STDIN.\n")
        serr.write("(but maybe one day if there's interest.)\n")
        self._fail_generically()

    def _fail_generically(self):
        self._stop(5)

    def _stop(self, exitstatus):
        self._exitstatus = exitstatus
        self._OK = False

    def _pop_property(self, prop):
        from sakin_agac import pop_property
        return pop_property(self, prop)


def _resolve_namespace_via_parse_args_USE_ME(serr, argv, __my_parameters):

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
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #history-A.1: replace hand-written argparse with agnostic modeling
# #born.
