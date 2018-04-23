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


def _MAIN_AGORITHM(rsx, top_stepper):

    current_stepper = top_stepper
    while True:  # PEP 315 (rejected) - there is no `do while` loop
        reso = current_stepper.step_against_modality_resources(rsx)
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

        from script_lib.magnetics import (
            parse_stepper_via_argument_parser_index,
            argument_parser_index_via_stderr_and_command_stream,
            )

        _ap_idx = argument_parser_index_via_stderr_and_command_stream(
                stderr=rsx.stderr,
                description=desc,
                command_stream=command_stream,
                prog=rsx.ARGV_stream.popleft(),
                )

        _top_stepper = parse_stepper_via_argument_parser_index(_ap_idx)

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

# #abstracted.
