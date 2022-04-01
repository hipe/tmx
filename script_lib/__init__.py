import re


def OPEN_UPSTREAM(stderr, arg_moniker, arg_value, stdin):
    # At #history-A.4 this shurnk to tiny,  re-written for API change.
    # At this same time, we sunsetted a whole redundant module (file).
    # Using stderr instead of listener is an experimental simplification..
    # Result value is experimental.

    typ = RESOLVE_UPSTREAM(stderr, arg_moniker, arg_value, stdin)
    if typ is None:
        return

    if 'stdin_as_argument' == typ:
        from contextlib import nullcontext
        return nullcontext(stdin)

    assert('path_as_argument' == typ)
    return open(arg_value)


def RESOLVE_UPSTREAM(stderr, arg_moniker, arg_value, stdin):
    # (see note at above function)

    def main():
        if stdin.isatty():
            if '-' == arg_value:
                return when_neither()
            return 'path_as_argument'
        if '-' == arg_value:
            return 'stdin_as_argument'
        return when_both()

    def when_both():
        whine(f'when piping from STDIN, {arg_moniker} must be "-"')

    def when_neither():
        whine(f'when {arg_moniker} is "-", STDIN must be pipe')

    def whine(msg):
        stderr.write(f'parameter error: {msg}\n')  # [#605.2] _eol

    return main()


def ALTERNATION_VIA_SEQUENCES(seqs):
    """going to try to hew really close to the doc pseudocode in the
    introductory test file
    """

    leng = len(seqs)
    assert leng
    if 1 == leng:
        print("\n\n(one day etc)\n\n")

    in_the_running = {k: None for k in range(0, leng)}

    def receive_input_event_tuple(tup):
        early_stops = parse_trees = None

        # Feed the input event out to all the nerks "in parallel"
        for i in in_the_running.keys():
            resp = seqs[i].receive_input_event_tuple(tup)
            if resp is None:
                continue
            typ, pay = resp  # #FSA-action-response
            if 'early_stop' == typ:
                if early_stops is None:
                    early_stops = {}
                dct = early_stops
            else:
                assert 'parse_tree' == typ
                if parse_trees is None:
                    parse_trees = {}
                dct = parse_trees
            dct[i] = pay

        num_stops = len(early_stops) if early_stops else 0
        num_trees = len(parse_trees) if parse_trees else 0
        num_still_running = len(in_the_running) - (num_stops + num_trees)
        func = which(num_stops, num_trees, num_still_running)
        args = []
        if num_stops:
            args.append(early_stops)
        if num_trees:
            args.append(parse_trees)
        return func(*args)

    def which(num_stops, num_trees, num_still_running):  # (we could just but..)
        if num_stops:
            if num_trees:
                if num_still_running:
                    return when_some_stops_and_some_trees_and_some_still_running
                return when_some_stops_and_some_trees_and_none_still_running
            if num_still_running:
                return when_some_stops_and_no_trees_and_some_still_running
            return when_some_stops_and_no_trees_and_none_still_running
        elif num_trees:
            if num_still_running:
                return when_no_stops_and_some_trees_and_some_still_running
            return when_no_stops_and_some_trees_and_none_still_running
        elif num_still_running:
            return when_no_stops_and_no_trees_and_some_still_running
        return when_no_stops_and_no_trees_and_none_still_running

    def when_some_stops_and_some_trees_and_some_still_running(stops, trees):
        xx("the behavior for this case has yet to be designed")

    def when_some_stops_and_some_trees_and_none_still_running(stops, trees):
        xx("take the trees not the stops")

    def when_some_stops_and_no_trees_and_some_still_running(stops):
        xx("common case - discard the stops")
        # When some issued early stop while others still run, we simply discard
        # the playload from these early stops and take them out of the running.
        # Note this could steam-roll over a response for help; so be sure the
        # would-be still-running sequences(s) know what they're doing. No resp.
        for k in stops.keys():
            in_the_running.pop(k)

    def when_some_stops_and_no_trees_and_none_still_running(stops):
        if 1 < len(stops):
            xx("have fun merging `early_stop_reason`s")
        return 'early_stop', next(iter(stops.values()))

    def when_no_stops_and_some_trees_and_some_still_running(parse_trees):
        xx("the behavior for this case has yet to be designed")

    def when_no_stops_and_some_trees_and_none_still_running(parse_trees):
        if 1 < len(parse_trees):
            xx("behavior for this case not yet designed - grammar matches ambiguity")
        return 'parse_tree', next(iter(parse_trees.values()))

    def when_no_stops_and_no_trees_and_some_still_running():
        pass  # the most common case - just keep going

    def when_no_stops_and_no_trees_and_none_still_running():
        xx("how did you get to none in the running?")

    return _Facade(receive_input_event_tuple)


def SEQUENCE_VIA(
        nonpositionals=None, for_interactive=None,
        positionals=None, subcommands=None):

    # States and Transitions

    def from_beginning_state():
        yield if_interactivity_event, respond_to_interactivity

    def from_required_positional_state():
        yield if_non_option_looking_token, try_to_satisfy_positional
        yield if_option_looking_token, maybe_accept_optional_nonpositional
        yield if_end_of_tokens, will_complain_about_expecting_required_positional

    def from_optional_positional_state():
        yield if_non_option_looking_token, try_to_satisfy_positional
        yield if_option_looking_token, maybe_accept_optional_nonpositional
        yield if_end_of_tokens, close_because_satisfied

    def from_optional_nonpositional_in_progress_state():
        yield if_non_option_looking_token, accept_option_value_and_pop
        yield if_option_looking_token, will_complain_about_expecting_option_value
        yield if_end_of_tokens, will_complain_about_expecting_option_value

    def from_no_more_positionals_state():
        yield if_end_of_tokens, close_because_satisfied
        yield if_option_looking_token, maybe_accept_optional_nonpositional
        yield if_non_option_looking_token, will_complain_about_unexpected_term

    # Actions (interesting ones)

    def maybe_accept_optional_nonpositional():  # #FSA-action-response
        input_event = state.input_event
        assert 'head_token' == input_event[0]
        assert 'looks_like_option' == input_event[1]
        token = input_event[2]

        # Break a large ball of {option [option [..]] [value]} into steps
        while True:
            expl, formal_nonpositional, replace_with_token = \
                    floating_cloud.against(token)

            # Maybe the token failed to match exactly one formal
            if not formal_nonpositional:
                assert expl
                return 'early_stop', expl
            assert expl is None

            # When the formal is a flag, we handle it now
            if formal_nonpositional.is_flag:
                expl = formal_nonpositional.handle_flag(state.parse_tree)
                if expl:
                    return 'early_stop', expl  # this is frequently --help

                # A ball of flags put together, or maybe a short o.n. and value
                if replace_with_token:
                    token = replace_with_token
                    continue

                # You processed the last of a ball of 1 or more flags.
                # Stay in the state you are in. You are done
                return
            break

        # You have found an optional nonpositional (it takes a value)
        assert formal_nonpositional.is_optional_nonpositional

        # If a value was provided in the same token "in a ball"..
        if replace_with_token:
            # Stay in the same state. result is any explanation
            return formal_nonpositional.handle_value_of_nonpositional(\
                    state.parse_tree, replace_with_token)

        # We cannot process the value in this step, we have to wait for the
        # next event (token) (if any)
        state.stack_frame_below = state.state_function
        state.formal_nonpositional_in_progress = formal_nonpositional
        return move_to(from_optional_nonpositional_in_progress_state)

    def try_to_satisfy_positional():  # #FSA-action-response
        formal_node = formal_stack[-1]
        stack = list(reversed(formal_node))  # #here2
        typ = stack.pop()
        assert typ in ('required_positional', 'optional_positional')
        formal_surface = stack.pop()
        snake = stack.pop()
        if len(stack):
            handler = stack.pop()
            assert not stack
        else:
            def handler(parse_tree, tok):
                assert snake not in parse_tree.values
                parse_tree.values[snake] = tok
        expl = handler(state.parse_tree, state.input_event[-1])  # #here2
        if expl:
            return 'early_stop', expl
        if False and formal_node.is_glob:  # #feature:glob-positionals
            return
        formal_stack.pop()
        return find_new_state_per_positionals()

    def respond_to_interactivity():  # #FSA-action-response
        is_interactive = state.input_event[1]
        formal_frame = formal_stack[-1]
        assert 'for_interactive' == formal_frame[0]
        formal_yes = formal_frame[1]
        ok = False
        if formal_yes is None:
            ok = True
        elif formal_yes and is_interactive:
            ok = True
        elif (not formal_yes) and (not is_interactive):
            ok = True
        if not ok:
            return explain_wrong_interactivity
        formal_stack.pop()
        return find_new_state_per_positionals()

    # Support for actions

    def find_new_state_per_positionals():  # #FSA-action-response
        if 0 == len(formal_stack):
            return move_to(from_no_more_positionals_state)
        formal_node = formal_stack[-1]
        typ = formal_node[0]  # #here2
        if 'required_positional' == typ:
            return move_to(from_required_positional_state)  # maybe redundant
        assert 'optional_positional' == typ
        return move_to(from_optional_positional_state)

    def close_because_satisfied():  # #FSA-action-response
        res = state.parse_tree
        state.parse_tree = None
        return 'parse_tree', res

    # Non-interesting actions

    def will_complain_about_expecting_required_positional():  # #FSA-action-response
        def explain():
            shout = formal_stack[-1][1]  # #here2
            yield 'early_stop_reason', 'expecting_required_positional', shout
            yield 'returncode', 72
        return 'early_stop', explain

    def will_complain_about_unexpected_term():  # #FSA-action-response
        def explain():
            yield 'early_stop_reason', 'unexpected_extra_argument'
            yield 'returncode', 66  # #here1
        return 'early_stop', explain

    def will_complain_about_expecting_option_value(): # #FSA-action-response
        xx()

    # Matchers

    def if_non_option_looking_token():
        if 'head_token' != state.input_event_type:
            return
        return 'looks_like_non_option' == state.input_event[1]

    def if_option_looking_token():
        if 'head_token' != state.input_event_type:
            return
        return 'looks_like_option' == state.input_event[1]

    def if_end_of_tokens():
        return 'end_of_tokens' == state.input_event_type

    def if_interactivity_event():
        return 'is_interactive' == state.input_event_type

    # State machine mechanics

    def receive_input_event_tuple(tup):
        state.input_event = tup
        state.input_event_type = tup[0]  # quick sketch
        found = False
        for matcher, action in state.state_function():
            found = matcher()
            if found:
                break
        if not found:
            xx("probably we will not encounter this normally")
        return action()

    def move_to(state_func):  # #FSA-action-response
        state.state_function = state_func

    state = from_beginning_state  # #watch-the-world-burn
    state.state_function = from_beginning_state
    state.parse_tree = _data_classes().parse_tree()

    # == BEGIN

    if positionals:  # #feature:lazy
        formal_stack = list(reversed(positionals))
    else:
        formal_stack = []

    if subcommands:  # #feature:lazy
        def f(literal_value):
            def handle(parse_tree, token):

                if literal_value == token:
                    parse_tree.subcommands.append(literal_value)
                    return

                if len(token) < len(literal_value) and \
                        literal_value[0:len(token)] == token:
                    # #feature:fuzzy
                    xx("not yet implemented: fuzzy match subcommand")

                def explain():
                    yield 'early_stop_reason', 'expecting_subcommand', literal_value
                    yield 'returncode', 71  # #here1
                return explain
            return handle

        for s in reversed(subcommands):
            formal_stack.append(('required_positional', f'"{s}"', None, f(s)))

    formal_stack.append(('for_interactive', for_interactive))

    floating_cloud = _floating_cloud_via_nonpositionals(nonpositionals)

    # = END

    return _Facade(receive_input_event_tuple)


class _Facade:

    def __init__(self, f):
        self.receive_input_event_tuple = f

    def receive_input_event(self, *tup):
        return self.receive_input_event_tuple(tup)


class _floating_cloud_via_nonpositionals:

    def __init__(self, tup):
        def add(long_token, handler):
            assert long_token not in these
            these[long_token] = handler

        these = {}

        def build_handler_for_flag(snake):
            def handle(parse_tree):
                parse_tree.values[snake] = True  # don't care if clobber (cov'd)
            return handle

        def build_handler_for_opt_nonpos(snake):
            def handle(parse_tree, token):
                parse_tree.values[snake] = token
            return handle

        seen_one_BSD_style = False

        for sx in (tup or ()):
            stack = list(reversed(sx))
            typ = stack.pop()
            surface = stack.pop()
            snake = stack.pop()
            has_not_has = stack.pop()
            if 'has_second_dash' == has_not_has:
                pass
            else:
                assert 'no_second_dash' == has_not_has
                seen_one_BSD_style = True
            if len(stack):
                arg_name, = stack
                assert 'optional_nonpositional' == typ
                handler = build_handler_for_opt_nonpos(snake)
            else:
                assert 'flag' == typ
                handler = build_handler_for_flag(snake)
            add(surface, handler)

        if True:
            def handle_help(parse_tree):
                def early_stop():
                    yield 'early_stop_reason', 'display_help'
                    yield 'returncode', 0
                return early_stop

            add('--help', handle_help)

        self.against, = _build_floating_cloud_functions(these, seen_one_BSD_style)


def _build_floating_cloud_functions(these, seen_one_BSD_style):

    def against(token):  # return (expl, formal, replace_with_token)
        md = re.match(r'^-(?P<is_long>-)?(?P<slug_fragment>.*)$', token)

        # If it looks long
        if md['is_long'] or seen_one_BSD_style:
            return against_long_token(md)
        return against_short_token(md)

    def against_short_token(md):  # return (expl, formal, replace_with_token)
        slug_frag = md['slug_fragment']

        # First, match all nerks with this derk
        if '--' in these:
            xx()
        else:
            use_keys = these.keys()
        needle = slug_frag[0]
        founds = tuple(k for k in use_keys if needle == k[2])

        leng = len(founds)
        if 0 == leng:
            def explanation():
                yield 'early_stop_reason', 'unrecognized_short', f"-{needle}"
                yield 'returncode', 69  # #here1
            return explanation, None, None
        if 1 < leng:
            def explanation():
                yield 'early_stop_reason', 'ambiguous_short', f"-{needle}"
                yield 'did_you_mean', founds
                yield 'returncode', 70  # #here1
            return explanation, None, None
        longg, = founds
        formal = _FormalNonpositional(longg, these[longg])
        if 1 < len(slug_frag):
            the_rest = slug_frag[1:]
            if formal.is_flag:
                replace_with_token = ''.join(('-', the_rest))
            else:
                assert formal.is_optional_nonpositional
                replace_with_token = the_rest
        else:
            replace_with_token = None

        return None, formal, replace_with_token

    def against_long_token(md):
        token = md[0]

        # First, just see if we match against the long token as-is
        handler = these.get(token)
        if handler:
            return None, _FormalNonpositional(token, handler), None

        # (Check this for now, we're guaranteed to type it by accident one day)
        if '=' in md['slug_fragment']:
            def explanation():
                line = f"Don't use equals for now: {token!r}\n"
                yield 'stderr_line', line
                yield 'returncode', 67  # #here1
            return explanation

        # It looks long but it didn't match verbatim

        # Fuzzy let's go (might become option one day)
        if True:
            rx = re.compile(''.join(('^', re.escape(token))))
            founds = tuple(k for k in these.keys() if rx.match(k))
            leng = len(founds)

        if 1 < leng:
            def explanation():
                yield 'ambiguous_long', founds
                yield 'returncode', 72  # #here1
        elif 1 == leng:
            use_tok, = founds
            return None, _FormalNonpositional(use_tok, these[use_tok]), None
        else:
            assert 0 == leng
            def explanation():
                yield 'early_stop_reason', 'unrecognized_option'
                yield 'returncode', 68  # #here1

        return explanation, None, None

    return (against,)


"""
- .#here1: the author proposes the range 65-113
  http://www.bic.mni.mcgill.ca/~dale/helppages/BashGuide/advshell/exitcodes.html
"""

class _FormalNonpositional:
    def __init__(self, token, handler):
        from inspect import signature
        params = signature(handler).parameters
        these = tuple(params.keys())
        leng = len(these)
        assert 0 < leng
        if 'parse_tree' != these[0]:
            xx(f"oops: {these[0]!r}")
        if 1 == leng:
            self.handle_flag = handler
            self.is_flag = True
            return
        self.is_optional_nonpositional = True
        self.handle_value_of_nonpositional = handler

    is_flag = False
    is_optional_nonpositional = False


def _data_classes():
    memo = _data_classes
    if memo.value is None:
        memo.value = _build_data_classes()
    return memo.value


_data_classes.value = None


def _build_data_classes():

    # == BEGIN
    def dataclass(cls):  # #decorator
        these[cls.__name__] = cls
        return orig_dataclass(cls)
    these = {}
    from dataclasses import dataclass as orig_dataclass, field
    # == END

    @dataclass
    class parse_tree:
        subcommands:list[str] = field(default_factory=list)
        values:dict = field(default_factory=dict)

    from collections import namedtuple
    return namedtuple('result', tuple(these.keys()))(**these)


def build_path_relativizer():
    def relativize_path(path):
        if head != path[0:leng]:
            raise RuntimeError(f'oops: (head, path): ({head}, {path})')
        tail = path[leng:]
        assert not isabs(tail)
        return tail
    from os import path as os_path, getcwd
    isabs = os_path.isabs
    head = os_path.join(getcwd(), '')
    leng = len(head)
    return relativize_path


def deindented_lines_via_big_string_(big_string):
    # convert a PEP-257-like string into an iterator of lines

    return _deindent(lines_via_big_string(big_string), _eol)


def deindented_strings_via_big_string_(big_string):
    # convert a PEP-257-like string into an iterator of strings

    return _deindent(_strings_via_big_string(big_string), '')


def _deindent(item_itr, empty_item):
    # (this should be in text_lib now, but we're leaving it here for now.)

    def peek():
        item = next(item_itr)  # ..
        peeked.append(item)
        return item
    peeked = []

    leading_ws_rx = re.compile('^([ ]+)[^ ]')

    item = next(item_itr)  # .., don't cache the throwaway item

    # if you requested to deindent a block of text but the first line is not bl
    if empty_item != item:
        assert(not leading_ws_rx.match(item))
        yield item
        for item in item_itr:
            yield item
        return

    # find the margin (the first nonzero length one in the first N lines)

    for _ in range(0, 3):
        item = peek()  # ..
        md = leading_ws_rx.match(item)
        if md is not None:
            break

    def f():
        for item in peeked:
            yield item
        for item in item_itr:
            yield item

    use_itr = f()

    if md is None:
        # cheap_arg_parse (at #history-A.5) wants to be able to use this w/o
        # knowing beforehand whether the big string has any margin anywhere
        # (some docstrings are flush-left with the whole file).

        for item in use_itr:
            yield item
        return

    margin = md[1]
    rx = re.compile(f'^[ ]{{{len(margin)}}}([^\\n]+{empty_item})\\Z')

    for item in use_itr:

        if empty_item == item:
            yield item
            continue

        md = rx.match(item)
        if md is None:
            # assume convention of """ is flush with content or 1 tab to the L
            if margin != item:
                assert(margin[0:-4] == item)

            assert(0 == len(tuple(use_itr)))
            return

        yield md[1]


def lines_via_big_string(big_string):  # #[#610]
    return (md[0] for md in re.finditer('[^\n]*\n|[^\n]+', big_string))


def _strings_via_big_string(big_string):
    if _eol not in big_string:
        if '' == big_string:
            return iter(())
        return iter((big_string,))
    return (md[1] for md in re.finditer('([^\n]*)\n', big_string))


# (buried `filesystem_functions` and justification documentation #history-B.4)


def xx(s='here'):
    raise _exe('cover me: {}'.format(s))


_exe = Exception


class Exception(Exception):
    pass


# -- CONSTANTS

GENERIC_ERROR = 2
SUCCESS = 0


_eol = '\n'


# #history-C.1: begin "engines of creation" CLI
# #history-B.4
# #history-A.5
# #history-A.4
# #history-A.3: "cheap arg parse" moves to dedicated file
# #history-A.1: as referenced
# #born: abstracted
