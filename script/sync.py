#!/usr/bin/env python3 -W error::Warning::0

_description_of_sync = """
description: for a given particular natural key field name, for each item

in the "near collection", see if you can pair it up with an item in the
"far collection" based on that natural key field name.

(the natural key field name is "declared" by the far collection.)

for each given near item, when a corresponding far item exists by the above
criteria, the values of those components in the near item that exist in the
far item are clobbered with the far values.

(the near item can have field names not in the far item, but if the far item
has field names not in the near item, we express this as an error and halt
further processing.)

(after this item-level merge, the far item is removed from a pool).

at the end of all this, each far item that had no corresponding near item
(i.e. that did not "pair up") is simply appended to the near collection.

(this is a synopsis of an algorithm that is described [#407] more formally.)
"""


def _my_parameters(o, param):

    o['near_collection'] = param(
            description='«help for near_collection»',
            )

    def __thing_two_desc(o, style):
        o('«help for {}'.format(style.em('far_collection')))
        o('2nd line')

    o['far_collection'] = param(
             description=__thing_two_desc,
             )

    def _plus_etc(s):
        def f(o, style):
            o("{} (try 'help')".format(s))
        return f

    o['near_format'] = param(
            description=_plus_etc('«the near_format»'),
            argument_arity='OPTIONAL_FIELD',
            )

    o['far_format'] = param(
            description=_plus_etc('«the far_format»'),
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
        self._OK and self.__resolve_namespace_via_parse_args()
        self._OK and self.__NEXT_THING()
        return self._pop_property('_exitstatus')

    def __resolve_namespace_via_parse_args(self):

        from script_lib.magnetics import (
                parse_stepper_via_argument_parser_index as stepperer,
                )

        reso = stepperer.SIMPLE_STEP(
                self._serr, self._argv, _my_parameters, _description_of_sync)
        if reso.OK:
            self._namespace = reso.namespace
        else:
            self._stop(reso.exitstatus)  # #coverpoint6.1.2

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


if __name__ == '__main__':
    import sys as o
    o.path.insert(0, '')
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #history-A.1: replace hand-written argparse with agnostic modeling
# #born.
