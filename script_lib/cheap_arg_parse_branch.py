"""this is the next level up from "parse stepper", and the highest level.

this encompases what is perhaps the central algorithm of the whole
sub-project. at its essence it's a tail-call recursion (if you like)
implemented as a loop:

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
        since result is non terminal, assume it is (or wraps) branch node.
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
        resolution = (current endpoint tree node).(step against upstream)
        if resolution is terminal, break
        current endpoint tree node = resolution
        repeat
    return resolution

it's basically the same algorithm, but we've just got to make sure that
our `( step against upstream )` is something like a method implemented
for two classes, one branchy and one terminal-y.

:[#012]
"""


def cheap_arg_parse_branch(stdin, stdout, stderr, argv, children_CLI_functions):  # noqa: E501

    cx_CLI_functions = children_CLI_functions

    # parse off the head token

    from .magnetics.parser_via_grammar import TokenScanner
    tox = TokenScanner(argv)
    long_program_name = tox.shift()

    # listen for parameter errors

    from .magnetics import error_monitor_via_stderr
    mon = error_monitor_via_stderr(stderr)
    from .cheap_arg_parse import write_parameter_error_lines_, ParameterError_

    def listener_for_parameter_error(*a):
        pe = ParameterError_(a, lambda: long_program_name)
        if pe.is_request_for_help:
            return when_help(pe)
        when_parameter_error(pe)

    def when_help(pe):
        for line in __help_lines(cx_CLI_functions, pe.long_program_name, CLI):
            stderr.write(_eol if line is None else f'{line}{_eol}')  # [#607.I]

    def when_parameter_error(pe):
        write_parameter_error_lines_(stderr, pe)
        mon.see_exitstatus(457)

    # loop

    CLI = __build_the_formal_CLI()
    from .cheap_arg_parse import do_parse_
    from kiss_rdb.magnetics.via_collection import key_and_entity_via_collection

    while True:
        two = do_parse_(tox, CLI, listener_for_parameter_error, stop_ASAP=True)
        if two is None:
            return mon.exitstatus
        opt_vals, arg_vals = two
        assert(not len(opt_vals))
        unsanitized_command_name, = arg_vals

        from kiss_rdb.magnetics.via_collection import (
                collection_implementation_via_pairs_cached)

        _coll = collection_implementation_via_pairs_cached(cx_CLI_functions)

        two = key_and_entity_via_collection(
                collection_implementation=_coll,
                needle_function=unsanitized_command_name,
                item_noun_phrase='sub-command',
                channel_tail_component_on_not_found='xxyy',
                listener=mon.listener)

        if two is None:
            stderr.write(_renderers(long_program_name).invite_line)
            return mon.exitstatus

        surface_name, terminal_CLI_functioner = two
        long_program_name = f'{long_program_name} {surface_name}'
        if True:
            terminal_CLI_function = terminal_CLI_functioner()
            break
        # cx_CLI_functions = write_me()

    use_argv = [long_program_name]
    while not tox.is_empty:
        use_argv.append(tox.shift())

    return terminal_CLI_function(stdin, stdout, stderr, use_argv)


def _MAIN_AGORITHM(rsx, top_stepper):

    current_stepper = top_stepper
    while True:  # PEP 315 (rejected) - there is no `do while` loop
        reso = current_stepper.step_for_branch_against_modality_resources(rsx)
        if reso.is_terminal:
            break
        current_stepper = reso.microservice_tree_branch_node
    return reso


def interpretationer_via_individual_resources(ARGV, stderr, stdout):
    from script_lib.magnetics import (
            resources_via_ARGV_stream_and_stderr_and_stdout as x,
            deque_via_ARGV,
            )
    _rsx = x(deque_via_ARGV(ARGV), stderr, stdout)
    return interpretationer_via_resources(_rsx)


class interpretationer_via_resources:
    """(wrapper made for injection)

    so:
      - must be mutable because it is single use because it take the head
        off ARGV (and must do so only once) to determine the program name.
    """

    def __init__(self, rsx):
        self._resources = rsx

    def interpretation_via_command_stream(self, command_stream, desc=None):

        rsx = self._resources
        del self._resources

        from script_lib.cheap_arg_parse import argument_parser_index_via
        from script_lib.magnetics import (
            parse_stepper_via_argument_parser_index)

        ap_idx = argument_parser_index_via(
                stderr=rsx.stderr,
                description_string=desc,
                command_stream=command_stream,
                prog=rsx.ARGV_stream.popleft(),
                )

        _top_stepper = parse_stepper_via_argument_parser_index(
                element_dictionary=ap_idx.command_dictionary,
                moniker=ap_idx.this_one_name__,
                argument_parser=ap_idx.argument_parser,
                )

        return _MAIN_AGORITHM(rsx, _top_stepper)


"""
if you like, the above is
an exemplary instance of our modality-agnostic 'injection' pattern:

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


# == BEGIN

def __help_lines(CLI_functions, long_program_name, CLI):
    program_name = _renderers(long_program_name).program_name
    from .magnetics.help_lines_via import (
            help_lines_via, desc_lineser_via, lines_for_items)

    doc_string = f"«these are the sub-commands»{_eol}"  # #guillemets
    _descser = desc_lineser_via(None, doc_string)
    _lines = help_lines_via(
            program_name, _descser, CLI.opts, CLI.args,
            usage_tail='..', do_splay=False)
    for line_content in _lines:
        yield line_content

    CLI_functions = tuple(CLI_functions)
    leng = len(CLI_functions)
    if not leng:
        return
    yield None
    yield ('sub-command:', 'sub-commands:')[(1, 2).index(leng)]
    max_width, rows = __max_width_and_rows(CLI_functions)
    for line_content in lines_for_items(max_width, rows):
        yield line_content


def __max_width_and_rows(CLI_functions):
    rows = []
    from .magnetics.help_lines_via import MaxWidthSeer_
    max_width_seer = MaxWidthSeer_()
    for sub_command_slug, CLI_funcer in CLI_functions:
        CLI_func = CLI_funcer()
        max_width_seer.see(sub_command_slug)
        line_contents = tuple(__HACKY_LINE_THING(CLI_func))
        if len(line_contents):
            first_line_content, *rest = line_contents
        else:
            first_line_content = None
            rest = ()
        rows.append((sub_command_slug, first_line_content))
        for line_content in rest:
            rows.append((None, line_content))
    return max_width_seer.max_width, tuple(rows)


def __HACKY_LINE_THING(CLI_func):
    _lines = __DO_HACKY_LINE_THING(CLI_func, 5, 'yikesies')
    ul1, ul2, bl, hdr, *pray_for_content = _lines
    assert(bl == _eol)
    import re

    # best case is that it has a description. use an excerpt of that
    md = re.match('^([a-z]+):(?: (.+))?', hdr)
    label = md[1]
    if label == 'description':
        yield md[2]
        if len(pray_for_content) and _eol != pray_for_content[0]:
            raise Exception('cover me (fun)')
            yield pray_for_content[0][0:-1]  # _eol
        return
    # almost worst case is that it has any interesting syntax. use that
    md = re.match(r'^usage: yikesies(?: ([^\n]+))?\n\Z', ul1)
    syntax = md[1]
    if syntax is not None:
        yield syntax  # (Case5844)
        return
    # worst case is meh
    yield "(no description for sub-command)"


def __DO_HACKY_LINE_THING(CLI_func, num_lines, yikes):

    class TheWorstThing(Exception):
        pass

    import re

    class Memo:

        def __init__(self):
            self.writes = []
            self._count = 0

        def see_write(self, s):
            assert(re.match(r'^[^\n]*\n\Z', s))  # else much more difficult
            self._count += 1
            self.writes.append(s)
            if self._count == num_lines:
                raise TheWorstThing()

    memo = Memo()

    class mock_IO:  # #class-as-namespace
        def write(s):
            memo.see_write(s)
            return len(s)

    try:
        CLI_func(None, None, mock_IO, (yikes, '--help'))
    except TheWorstThing:
        pass

    return tuple(memo.writes)

# == END


def __build_the_formal_CLI():
    from .cheap_arg_parse import (
            CLI_via_syntax_AST_,
            syntax_AST_via_parameters_definition_)
    _formal_parameters = (('<sub-command>', 'the sub-command'),)
    _syntax_AST = syntax_AST_via_parameters_definition_(_formal_parameters)
    return CLI_via_syntax_AST_(_syntax_AST)


def _renderers(long_program_name):
    from .cheap_arg_parse import Renderers_
    return Renderers_(long_program_name)


_eol = '\n'


# #history-A.1: spike cheap arg parse branch
# #abstracted.
