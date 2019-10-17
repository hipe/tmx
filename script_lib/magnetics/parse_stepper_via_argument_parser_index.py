"""this is the next level up from "argument parser index"

you want to use this magnetic directly if your parse will require only
one "step", that is, it is not a deeply recursive tree of branch nodes
but rather only a flat list of parameters.
"""

from script_lib import cover_me


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
def _SIMPLE_STEP(
        sin, serr, argv, parameters_definition,
        stdin_OK=None,
        **platform_kwargs
        ):

    """#NOT_COVERED experiment (at #history-A.2)"""

    from script_lib import cheap_arg_parse as argparse_lib
    from script_lib.magnetics import (
            deque_via_ARGV as argv_stream_f,
            resources_via_ARGV_stream_and_stderr_and_stdout as rsx_f)
    from modality_agnostic.magnetics import (
            formal_parameter_via_definition as param_f)
    argv_stream = argv_stream_f(argv)
    prog = argv_stream.popleft()

    if stdin_OK is None:
        pass
    elif stdin_OK:
        # a script that says that "STDIN is OK" signals that it is OK to run
        # the script NON-interactively; however here we do no special handling
        # or passing-on of the STDIN resource. (not covered, develpoped
        # visually at #history-A.3)
        pass
    elif sin.isatty():
        pass
    else:
        serr.write('this fellow does not read from STDIN.\n')
        serr.write("try '{} -h'\n".format(prog))
        return _InterruptedStepResolution(5)

    params_d = {}
    parameters_definition(params_d, param_f)

    _ap = argparse_lib.argument_parser_via_parameter_dictionary__(
            stderr=serr,
            prog=prog,
            parameter_dictionary=params_d,
            **platform_kwargs
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

    OK = True
    is_terminal = True


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

        # == BEGIN #history-A.4 temporary retro-fitting. normally the error
        # monitor ('s listener) would be injected and we would use the e.m
        # to determine our exitstatus.
        # but this whole topic module will be re-written or sunsetted.

        from script_lib.magnetics import error_monitor_via_stderr

        def extraneous_f():
            _em = error_monitor_via_stderr(rsx.stderr)
            return _em.listener
        # == END
        return extraneous_f

    OK = True
    is_terminal = True


class _InterruptedStepResolution:
    """when we fail to procure an interpretation, this is the result structure

    """

    def __init__(self, es):
        self.exitstatus = es

    OK = False
    is_terminal = True


#
# private support functions
#

def _ugh_string_yadda_from_message(message, this_one_name):
    """ugh - at #history-A.1 elsewhere, when we added the name to the

    `add_subparsers` it screwed up the way messages are created.
    why would you want an internal data member name to show up in a
    user-facing message?  #[#020.2] get it together `argparse`
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


import sys  # noqa E402
sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #history-A.4 (as referenced, can be temporary)
# #history-A.3 (as referenced, can be temporary)
# #history-A.2 (as referenced, can be temporary)
# #abstracted.
