"""this is the next level up from "argument parser index"

you want to use this magnetic directly if your parse will require only
one "step", that is, it is not a deeply recursive tree of branch nodes
but rather only a flat list of parameters.
"""


from script_lib import (
        cover_me,
        )


class _Me:
    """(the conceit is that you could override particular behaviors)"""

    def __init__(self, argument_parser_index):
        self._argument_parser = argument_parser_index.argument_parser
        self._dictionary = argument_parser_index.command_dictionary
        self._moniker = argument_parser_index.this_one_name__

    def step_against_modality_resources(self, rsx):

        import script_lib.magnetics.fixed_argument_parser_via_argument_parser as ap_lib  # noqa: E501

        e = None
        try:
            ns = self._argument_parser.parse_args(rsx.ARGV_stream)
        except ap_lib.Interruption as e_:
            e = e_

        if e:
            return self.__when_argument_parser_threw_interruption(rsx, e)
        elif ns.chosen_sub_command:
            return self.__when_success(rsx, ns)
        else:
            return self.__when_no_sub_command(rsx)

    def __when_no_sub_command(self, rsx):
        import script_lib as sl
        io = rsx.stderr
        io.write('expecting sub-command.\n')  # NEWLINE
        self._argument_parser.print_usage(io)
        return _FailureStepResolution(sl.GENERIC_ERROR)

    def __when_argument_parser_threw_interruption(self, rsx, e):

        msg = e.message
        if msg is not None:
            _use_message = _ugh_string_yadda_from_message(msg, self._moniker)
            rsx.stderr.write(_use_message)  # assume NEWLINE
        return _FailureStepResolution(e.exitstatus)

    def __when_success(self, rsx, ns):
        cmd = self._dictionary[_name_via_slug(ns.chosen_sub_command)]
        if cmd.is_branch_node:
            cover_me('deep microservice trees')
        else:
            return _OhSnapStepResolution(ns, cmd, rsx)


#
# step resolution classes
#

class _OhSnapStepResolution:

    def __init__(self, namespace, cmd, rsx):
        self.__modality_resources = rsx
        self._namespace = namespace  # #testpoint (property name)
        self._command = cmd  # #testpoint (property name)

    def FLUSH_TO_EXECUTABLE(self):  # non-idempotent
        cmd = self._command
        del self._command
        return cmd.EXECUTABLE_VIA_RESOURCER(self)

    def flush_modality_agnostic_listener_builder(self):

        rsx = self.__modality_resources
        del self.__modality_resources

        from script_lib.magnetics import listener_via_resources as o

        def extraneous_f():
            _listener = o.listener_via_stderr(rsx.stderr)  # maybe more later
            return _listener
        return extraneous_f

    @property
    def OK(self):
        return True

    @property
    def is_terminal(self):
        return True


class _FailureStepResolution:
    """when we fail to procure an interpretation, this is the result structure

    """

    def __init__(self, es):
        self.exitstatus = es

    @property
    def OK(self):
        return False

    @property
    def is_terminal(self):
        return True


#
# private support functions
#

def _ugh_string_yadda_from_message(message, this_one_name):
    """ugh - at #history-A.1 elswhere, when we added the name to the

    `add_subparsers` it screwed up the way messages are created.
    why would you want an internal data member name to show up in a
    user-facing message?  #[#006.B] get it together `argparse`
    """

    import re
    m = re.search(
            '^([^:]+: error: )argument '+this_one_name+': (.+)\\Z',
            message, re.DOTALL)
    if m:
        return ''.join(m.groups())  # EMPTY_S
    else:
        return message


def _name_via_slug(name):
    return name.replace('-', '_')  # DASH, UNDERSCORE


# == BEGIN #callable-module-hack

class _MeAsCallable:
    def __call__(self, x):
        return _Me(x)

import sys  # noqa E402
sys.modules[__name__] = _MeAsCallable()

# == END
# #abstracted.
