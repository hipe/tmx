"""this is the next level up from "argument parser index"

you want to use this magnetic directly if your parse will require only
one "step", that is, it is not a deeply recursive tree of branch nodes
but rather only a flat list of parameters.
"""


from script_lib import (
        cover_me,
        )


class _SELF:
    """(the conceit is that you could override particular behaviors)"""

    def __init__(
            self,
            argument_parser,
            moniker,
            element_dictionary,
            ):

        self._element_dictionary = element_dictionary
        self._argument_parser = argument_parser
        self._moniker = moniker

    def step_for_branch_against_modality_resources(self, rsx):

        e, ns = self._error_or_namespace(rsx)
        if e is not None:
            return self._when_argument_parser_threw_interruption(rsx, e)
        elif ns.chosen_sub_command:
            return self.__when_sub_command_chosen(rsx, ns)
        else:
            return self.__when_no_sub_command(rsx)

    def _step_against_modality_resources(self, rsx):

        e, ns = self._error_or_namespace(rsx)
        if e is not None:
            return self._when_argument_parser_threw_interruption(rsx, e)
        else:
            return _NamespaceStepResolution(ns)

    def _error_or_namespace(self, rsx):

        import script_lib.magnetics.fixed_argument_parser_via_argument_parser as ap_lib  # noqa: E501
        e = None
        ns = None
        try:
            ns = self._argument_parser.parse_args(rsx.ARGV_stream)
        except ap_lib.Interruption as e_:
            e = e_
        return e, ns

    def __when_no_sub_command(self, rsx):
        import script_lib as sl
        io = rsx.stderr
        io.write('expecting sub-command.\n')  # NEWLINE
        self._argument_parser.print_usage(io)
        return _InterruptedStepResolution(sl.GENERIC_ERROR)

    def _when_argument_parser_threw_interruption(self, rsx, e):

        msg = e.message
        if msg is not None:
            _use_message = _ugh_string_yadda_from_message(msg, self._moniker)
            rsx.stderr.write(_use_message)  # assume NEWLINE
        return _InterruptedStepResolution(e.exitstatus)

    def __when_sub_command_chosen(self, rsx, ns):
        cmd = self._element_dictionary[_name_via_slug(ns.chosen_sub_command)]
        if cmd.is_branch_node:
            cover_me('deep microservice trees')
        else:
            return _ExecutableTerminalStepResolution(ns, cmd, rsx)


# == BEGIN
def _SIMPLE_STEP(serr, argv, parameters_definition, description):
    """#NOT_COVERED experiment (at #history-A.2)"""

    from script_lib.magnetics import (
            argument_parser_index_via_stderr_and_command_stream as mag,
            deque_via_ARGV as argv_stream_f,
            resources_via_ARGV_stream_and_stderr_and_stdout as rsx_f,
            )

    from modality_agnostic.magnetics import (
            parameter_via_definition as param_f,
            )

    params_d = {}
    parameters_definition(params_d, param_f)
    argv_stream = argv_stream_f(argv)
    _prog = argv_stream.popleft()

    _ap = mag.argument_parser_via_parameter_dictionary(
            stderr=serr,
            prog=_prog,
            description=description,
            parameter_dictionary=params_d,
            )

    _stepper = _SELF(_ap, 'i am moniker', params_d)

    _rsx = rsx_f(argv_stream, serr, None)

    _reso = _stepper._step_against_modality_resources(_rsx)
    return _reso


_SELF.SIMPLE_STEP = _SIMPLE_STEP
# == END


#
# step resolution classes
#

class _NamespaceStepResolution:

    def __init__(self, namespace):
        self.namespace = namespace

    @property
    def OK(self):
        return True

    @property
    def is_terminal(self):
        return True


class _ExecutableTerminalStepResolution:

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


class _InterruptedStepResolution:
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
    """ugh - at #history-A.1 elsewhere, when we added the name to the

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

import sys  # noqa E402
sys.modules[__name__] = _SELF

# == END

# #history-A.2 (as referenced, can be temporary)
# #abstracted.
