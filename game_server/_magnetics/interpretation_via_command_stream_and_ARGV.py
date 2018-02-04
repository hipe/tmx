"""an exemplary instance of our modality-agnostic 'injection' pattern:

wrap the modality-specific unsanitized request data (the ARGV) in a subject
(the "interpretation maker") and "inject" it into the microservice.

then, as the "invocation" is being processed, the subject (once injected)
receives the command collection from the service..

from these two elements (the ARGV and the collection of commands), the
subject's charge is to parse the one against the other and produce an
"interpretation" object (or on failure produce a result object that knows
a suggested exitstatus).

because the order feels somewhat counterintuitive (ARGV *then* commands)
and also is somewhat arbitrary, we have given the module a name that
flattens this order out of it (in part in case we want to change it, the
rename won't be drastic.)
"""

from game_server import lazy

def interpretation_builder_via_modality_resources(
      ARGV,
      stdout,
      stderr,
    ):
    """currently the only entrypoint into this module (file)"""
    return _InterpretationBuilder(ARGV, stdout, stderr)


class _InterpretationBuilder:
    """doubles as both a "modality resources" and the thing that is injected..

    should not be frozen because it should release the ARGV it is built with.

    this is the central algorithm of this whole module (file). at its
    essence it's a tail-call recursion (if you like) implemented as a loop:

    imagine your microservice as a tree of commands (API endpoints).
    every node in this tree is either a branch node or a (terminal) command.

    (we *could* broaden the definition of "command" to include branch nodes
    because they sort of have their own behavior for certain modalities and
    certain requests, but branch nodes don't do business operations so keep
    this in mind if you think of them as commands.)

    for our purposes, a branch node is nothing more than a thing that can
    produce a stream of microservice tree nodes.

    model the root of the microservice itself as such a branch node.

    so, here's one approach:
        current branch node = the root of the application
        begin do-while loop:
            resolve a step-resolution given current branch node
            if resolution is terminal (viz fail or command), break.
            since result is non terminal, assume it is (or wraps) a branch node.
            let current branch node be that branch node and repeat loop.
        return current resolution

    the above will likely work for most of our endpoint trees. BUT there's
    a chance we will want to support single-command microservices. in such
    cases the root of the endpoint tree is itself terminal. we can rearrange
    the loop to accomodate this provision but still behave identically to
    the above algorithm too, if we factor out the assumption that our
    beginning node is a branch node.

        current endpoint tree node = application root
        begin do-while loop:
            resolution = ( current endpoint tree node ).( step against upstream )
            if resolution is terminal, break
            current endpoint tree node = resolution
            repeat
        return resolution

    it's basically the same algorithm, but we've just got to make sure that
    our `( step against upstream )` is something like a method implemented
    for two classes, one branchy and one terminal-y.

    :[#012]
    """

    def __init__(self,
      ARGV,
      stdout,
      stderr,
    ):
        from collections import deque
        self.ARGV_stream = deque(ARGV)
        self.stdout = stdout ; self.stderr = stderr

    def interpretation_via_command_stream(self, command_stream):

        current_tree_node = self.__flush_root_tree_node(command_stream)
        # --
        while True:  # PEP 315 (rejected) - there is no `do while` loop
            resolution = current_tree_node.step_against_modality_resources(self)
            if resolution.is_terminal: break
            current_tree_node = resolution.microservice_tree_branch_node

        return resolution

    def __flush_root_tree_node(self, command_stream):
        return _AdaptedMicroserviceTreeBranchNode(
          command_stream = command_stream,
          program_name_up_to_node = self.ARGV_stream.popleft(),
            # `sys.argv` has program name as first element. argparse does not.
        )

class _AdaptedMicroserviceTreeBranchNode:
    """(could allow this to be immutable if it was necessary)"""

    def __init__(self,
      command_stream,
      program_name_up_to_node,
    ):
        self.command_stream = command_stream
        self.program_name_up_to_node = program_name_up_to_node

    def step_against_modality_resources(self, rsx):
        ap, ci = self.__flush_argument_parser_and_command_index(rsx)
        e = None
        try:
            ns = ap.parse_args(rsx.ARGV_stream)
        except _MyInterruption as e_:
            e = e_

        if e:
            return _when_argument_parser_threw_interruption(rsx, e)
        else:
            if ns.chosen_sub_command:
                return _when_oh_snap(ns, ci, rsx)
            else:
                return _when_no_sub_command(rsx, ap)

    def __flush_argument_parser_and_command_index(self, rsx):
        s = self.program_name_up_to_node ; del self.program_name_up_to_node
        ap = _start_argument_parser(s)
        _hack_argument_parser(ap, rsx)
        st = self.command_stream ; del self.command_stream
        ci = _command_index_via_these(ap, st, rsx)
        return ap, ci

#
# argument parsing case behaviors, experimentally as functions
#

def _when_oh_snap(ns, ci, rsx):
    cmd = ci[_name_via_slug(ns.chosen_sub_command)]
    if cmd.is_branch_node:
        cover_me('deep microservice trees')
    else:
      return _OhSnapStepResolution(ns, cmd, rsx)

def _when_no_sub_command(rsx, ap):
    io = rsx.stderr
    io.write('expecting sub-command.'+NEWLINE)
    ap.print_usage(io)
    return _FailureStepResolution(_GENERIC_ERROR)

def _when_argument_parser_threw_interruption(rsx, e):

    message = e.message
    if message is not None:
        message = __ugh_string_yadda_from_message(message)
        rsx.stderr.write(message)  # assume NEWLINE
    return _FailureStepResolution(e.exitstatus)

def __ugh_string_yadda_from_message(message):
    # ugh - at #history-A.1 when we added the name to the `add_subparsers`
    # it screwed up the way messages are created. why would you want an
    # internal data member name to show up in a user-facing message?
    # #[#006.B] get it together `argparse`

    import re
    m = re.search('^([^:]+: error: )argument '+_THIS_NAME+': (.+)\\Z', message, re.DOTALL)
    if m:
        return ''.join(m.groups())  # EMPTY_S
    else:
        return message

#
# step resolution classes
#

class _OhSnapStepResolution:

    def __init__(self, namespace, cmd, rsx):
        self.__modality_resources = rsx
        self._namespace = namespace  # #testpoint (property name)
        self._command = cmd  # #testpoint (property name)

    def FLUSH_TO_EXECUTABLE(self):  # non-idempotent
        rsx = self.__modality_resources ; del self.__modality_resources
        self.__listener_builder = _build_listener_builder(rsx)
        cmd = self._command ; del self._command
        return cmd.EXECUTABLE_VIA_RESOURCER(self)

    def flush_modality_agnostic_listener_builder(self):
        f = self.__listener_builder ; del self.__listener_builder ; return f

    @property
    def OK(self):
        return True

    @property
    def is_terminal(self):
        return True


class _FailureStepResolution:
    """when we fail to procure an interpretation, this is the result structure"""

    def __init__(self, es):
        self.exitstatus = es

    @property
    def OK(self):
        return False

    @property
    def is_terminal(self):
        return True

#
# build argument parser
#

def _command_index_via_these(ap, command_stream, rsx):
    """BOTH mutates argument parser AND results in an index of commands added."""

    d = {}
    subparsers = ap.add_subparsers(dest = _THIS_NAME)
    for cmd in command_stream:
        k = cmd.name
        if k in d:
            _msg = "name collision - multiple commands named '%s'"
            cover_me(_msg % k)
        d[k] = cmd
        _add_command_to_argument_parser(subparsers, cmd, rsx)
    return d


class _add_command_to_argument_parser:
    """the bulk of the work of our modality-specific adapatation of parameters"""

    def __init__(self, subparsers, cmd, rsx):

        f = cmd.description
        if f is not None:
            desc_s = _string_via_description_function(f)
        else:
            desc_s = ( "«desc for subparser (place 2) '%s'»\nline 2" % cmd.name )

        self._count_of_positional_args_added = 0

        ap = subparsers.add_parser(
            _slug_via_name(cmd.name),
            help='«help for command»',
            description=desc_s,
            add_help=False,
        )
        _hack_argument_parser(ap, rsx)
        self._parser = ap
        d = cmd.formal_parameter_dictionary
        for name in d:
            self.__add_parameter(d[name], name)

    def __add_parameter(self, param, name):
        """[#013] discusses different ways to conceive of parameters ..

        in terms of ther argument arity. here we could either follow the
        "lexicon" (`is_required`, `is_flag`, `is_list`) or the numbers. we
        follow the numbers for no good reason..
        """

        r = param.argument_arity_range
        min = r.start ; max = r.stop
        if min is 0:
            if max is 0:
                self.__add_flag(param, name)
            elif max is 1:
                self.__add_optional_field(param, name)
            else:
                if max is not None: sanity()
                self.__add_optional_list(param, name)
        else:
            if min is not 1: sanity()
            if max is 1:
                self.__add_required_field(param, name)
            else:
                if max is not None: sanity()
                self.__add_required_list(param, name)

    def __add_required_field(self, param, name):
        """purely from an interpretive standpoint, we could express any number..

        of required fields as positional arguments when as a CLI command.
        HOWEVER from a usability standpoint, as an #aesthetic-heuristic
        we'll say experimentally that THREE is the max number of positional
        arguments a command should have.
        """
        if 3 > self._count_of_positional_args_added:
            self._count_of_positional_args_added += 1
            self.__do_add_required_field(param, name)
        else:
            cover_me('many required fields')

    def __add_required_list(self, param, name):  # category 5
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name),
            nargs='+',
            # action = 'append', ??
        )

    def __do_add_required_field(self, param, name):  # category 4
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name),
        )

    def __add_optional_list(self, param, name):  # category 3
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name),
            nargs='*',
            # action = 'append', ??
        )

    def __add_optional_field(self, param, name):  # category 2
        self._parser.add_argument(
            ( _DASH_DASH + _slug_via_name(name) ),
            ** self._common_kwargs(param, name),
            metavar = _infer_metavar_via_name(name),
        )

    def __add_flag(self, param, name):  # category 1
        self._parser.add_argument(
            ( _DASH_DASH + _slug_via_name(name) ),
            ** self._common_kwargs(param, name),
            action = 'store_true',  # this is what makes it a flag
        )

    def _common_kwargs(self, param, name):

        s = param.generic_universal_type
        if s is not None:
            implement_me()

        d = {}
        f = param.description
        if f is not None:
            d['help'] = _string_via_description_function(f)
        else:
            d['help'] = ("«the '%s' parameter»" % name)  # ..
        return d


#
# argument parser (build with functions not methods, expermentally)
#

def _string_via_description_function(f):
    s_a = []
    def write_f(s):
        s_a.append(s + NEWLINE)
    f(write_f, _STYLER)
    return _EMPTY_STRING.join(s_a)


def _hack_argument_parser(ap, rsx):
    """(see constituent functions for explanation)"""

    __add_my_help(ap, rsx)
    __hack_custom_error_function(ap, rsx)


def __add_my_help(ap, rsx):
    """the help they add is not helpful. calling `exit` is really bad style for us
    """

    ap.register('action', 'my_help', __yikes_ONE(rsx))  # register before next

    ap.add_argument('-h', '--help',
        action='my_help',
        help=_('show therse help message and exit'),
    )

def __yikes_ONE(rsx):

    def f(**three_kwargs):
        return _MyHelpAction( my_rsx=rsx, ** three_kwargs )
    return f

class _MyHelpAction:

    def __init__(self,
        option_strings,
        dest,
        help,
        my_rsx,
    ):

        self.choices = None
        self.default = None
        self.dest = dest
        self.help = help
        self.nargs = 0
        self.metavar = None
        self._my_rsx = my_rsx
        self.option_strings = option_strings
        self.required = False
        self.type = None

    def __call__(self, parser, namespace, values, option_string):
        parser.print_help(self._my_rsx.stderr)
        raise _MyInterruption(_SUCCESS, None)


def __hack_custom_error_function(ap, rsx):
    """the *recently rewritten* stdlib option parsing library is not

    testing-friendly, nor is it sufficiently flexible for some novel
    uses. it writes to system stderr and exits, which might be rather
    violent depending on what you're trying to do.

    here, rather than subclass it, we experiment with this:
    """

    def f(message):
        ap.print_usage(rsx.stderr)
        args = {'prog': ap.prog, 'message': message}
        msg = _('%(prog)s: error: %(message)s\n') % args  # NEWLINE
        raise _MyInterruption(_GENERIC_ERROR, msg)
    ap.error = f


def _start_argument_parser(program_name_up_to_node):
    import argparse
    return argparse.ArgumentParser(
      prog = program_name_up_to_node,
      description = '«description for root node»',
      add_help=False,
    )


@lazy
def _infer_metavar_via_name():
    """given an optional field named eg. "--important-file", name its

    argument moniker 'FILE' rather than'IMPORTANT_FILE'
    """

    import re
    regex = re.compile('[^_]+$')
    def f(name):
        return regex.search(name)[0].upper()
    return f


def _slug_via_name(name):
    return name.replace(_UNDERSCORE, _DASH)


def _name_via_slug(name):
    return name.replace(_DASH, _UNDERSCORE)


@lazy
def _():
    # #wish [#008.E] gettext uber alles
    from gettext import gettext as g
    def f(s):
        return g(s)
    return f


_THIS_NAME = 'chosen_sub_command'


#
# listener builder
#

def _build_listener_builder(rsx):
    """(placeholder for the deeper idea)

    the idea here is that commands can emit "expressions" (and maybe one
    day "events", known together with expressions as as "emissions") in a
    modality-agnostic way and a listener can express them in a modality-
    appropriate way.

    you emit your expression by telling it a 'channel' in terms of
    several strings:

        self._listener('info', 'expression', f)

    (currently, the above pictured channel ('info', 'expression') is the
    only channel supported.)

    the function that is passed as the last argument (above `f`) is a
    callback that will receive two things:

      - a function to receive strings
      - a "styler"

    so the function might look like:
        def f(o, styler):
            o('hello ' + o.em('world') + '!')

    this convoluted interface (HIGHLY EXERIMENTAL) allows the listener to
    decide whether it wants the command to bother executing the emission
    just based on seeing the channel alone. also it allows the listener
    (modality client) to inject a modality-appropriate styler.

    we want the interface to improve while not losing the above provisions.
    """

    def call_once():
        # (we jump thru tiny hoops to ensure you set up the listener max once.)

        nonlocal call_once
        call_once = None  # hm..

        def g(*x_a):  # currently: (channel string, channel string, callback)
            d = deque(x_a) ; del x_a
            expression_f = d.pop()
            error_or_info = d.popleft()
            if error_or_info is 'error':
                pass
            elif error_or_info is 'info':
                pass
            else:
                cover_me('bad first channel component: ' + error_or_info)
            exp = d.popleft()
            if exp is 'expression':
                pass
            else:
                cover_me('bad second channel component: ' + exp)
            if len(d) is 0:
                del d
            else:
                cover_me('unexpected third channel component: '+d[0])
            expression_f(write_unterminated_line, _STYLER)
        from collections import deque

        def write_unterminated_line(s):
            if s:
                s += NEWLINE
            else:
                s = NEWLINE
            stderr.write(s)
        stderr = rsx.stderr  # ..

        return g

    def f():
        return call_once()
    return f

#
# small support classes
#

class _MyInterruption(Exception):
    """we are forced to throw exception to interrupt control flow there :("""

    # (#[#006.B] this is seen as a painpoint of argparse)

    def __init__(self, exitstatus, message):
        self.exitstatus = exitstatus
        self.message = message

#
# this little guy
#

class _STYLER:  # #todo
    """experiment"""

    def em(s):
      return "\u001B[1;32m%s\u001B[0m" % s

# --

_DASH = '-'
_DASH_DASH = '--'
_EMPTY_STRING = ''
_GENERIC_ERROR = 2
NEWLINE = "\n"
_SUCCESS = 0
_UNDERSCORE = '_'

# #history-A.1: as referenced (can be temporary)
# #born.
