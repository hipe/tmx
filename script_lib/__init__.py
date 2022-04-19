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
        raise RuntimeError("with only once sequence, use sequence itself")

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
        # When some issued early stop while others still run, we simply discard
        # the playload from these early stops and take them out of the running.
        # Note this could steam-roll over a response for help; so be sure the
        # would-be still-running sequences(s) know what they're doing. No resp.
        for k in stops.keys():
            in_the_running.pop(k)

    def when_some_stops_and_no_trees_and_none_still_running(stops):
        if 1 < len(stops):
            return 'early_stop', _merge_early_stop_reasons(stops.values())
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

    return _InputReceiverFacade(receive_input_event_tuple)


def _merge_early_stop_reasons(expls):
    expecting_surfaces = {}
    highest_returncode = None
    seen_subtype = None

    for expl in expls:
        for component in expl():
            typ, *pay = component
            if 'returncode' == typ:
                rc, = pay
                if highest_returncode is None or highest_returncode < rc:
                    highest_returncode = rc
            elif 'early_stop_reason' == typ:
                subtype = pay[0]
                if seen_subtype is None:
                    seen_subtype = subtype
                elif seen_subtype != subtype:
                    xx('ugh')
                if 'expecting_required_positional' == subtype:
                    expecting_surfaces[pay[1]] = None
                elif 'expecting_subcommand' == subtype:
                    expecting_surfaces[pay[1]] = None
                else:
                    xx()
            else:
                xx()

    def explain():
        if highest_returncode is not None:
            yield 'returncode', highest_returncode

        these = tuple(expecting_surfaces.keys())
        use = these[0] if 1 == len(these) else these
        yield 'early_stop_reason', seen_subtype, use  # ..

    return explain


def SEQUENCE_VIA(
        nonpositionals=None, for_interactive=None,
        positionals=None, subcommands=None):

    if subcommands and isinstance(subcommands[0], str):
        # until #just-in-time-parse-parsing
        xx(f"oops change these to sexps: {subcommands!r}")

    # States and Transitions

    def from_beginning_state():
        yield if_interactivity_event, respond_to_interactivity

    def from_required_positional_state():
        yield if_non_option_looking_token, try_to_satisfy_positional
        yield if_option_looking_token, maybe_accept_optional_nonpositional
        yield if_end_or_special, will_complain_about_expecting_required_positional

    def from_required_glob_initial_state():  # like above except one thing
        yield if_non_option_looking_token, try_to_satisfy_1st_reqglob_positional
        yield if_option_looking_token, maybe_accept_optional_nonpositional
        yield if_end_or_special, will_complain_about_expecting_required_positional

    def from_optional_positional_state():
        yield if_non_option_looking_token, try_to_satisfy_positional
        yield if_option_looking_token, maybe_accept_optional_nonpositional
        yield if_end_of_tokens, close_because_satisfied
        yield if_double_dash_token, react_to_double_dash
        yield if_single_dash_token, will_complain_about_single_dash

    def from_optional_nonpositional_in_progress_state():
        yield if_non_option_looking_token, maybe_accept_nonpos_in_progress_value
        yield if_single_dash_token, maybe_accept_dash_token
        yield if_option_looking_token, will_complain_about_expecting_option_value
        yield if_end_or_special, will_complain_about_expecting_option_value

    def from_no_more_positionals_state():
        yield if_end_of_tokens, close_because_satisfied
        yield if_option_looking_token, maybe_accept_optional_nonpositional
        yield if_double_dash_token, react_to_double_dash
        yield if_non_option_looking_token, will_complain_about_unexpected_term
        yield if_single_dash_token, will_complain_about_single_dash

    # Actions (interesting ones)

    def maybe_accept_optional_nonpositional():  # #FSA-action-response
        assert 'head_token' == state.input_event_type
        assert 'looks_like_option' == state.token_category
        token = state.head_token

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
            if 'flag' == formal_nonpositional.formal_type:
                two = formal_nonpositional.handle_flag(state.parse_tree)
                if two:
                    return two  # frequently --help

                # A ball of flags put together, or maybe a short o.n. and value
                if replace_with_token:
                    token = replace_with_token
                    continue

                # You processed the last of a ball of 1 or more flags.
                # Stay in the state you are in. You are done
                return
            break

        # You have found an optional nonpositional (it takes a value)
        assert 'optional_nonpositional' == formal_nonpositional.formal_type

        # If a value was provided in the same token "in a ball"..
        if replace_with_token:
            # Stay in the same state. result is any explanation
            return formal_nonpositional.handle_value_of_nonpositional(\
                    state.parse_tree, replace_with_token)

        # We cannot process the value in this step, we have to wait for the
        # next event (token) (if any)
        state.state_function_on_hold = state.state_function
        state.formal_nonpositional_in_progress = formal_nonpositional
        return move_to(from_optional_nonpositional_in_progress_state)

    def try_to_satisfy_1st_reqglob_positional():  # #FSA-action-response
        return try_to_satisfy_positional(was_reqglob=True)

    def try_to_satisfy_positional(was_reqglob=False):  # #FSA-action-response
        formal_node = formal_stack[-1]
        typ = formal_node.formal_type
        if formal_node.is_glob:
            assert typ in ('optional_glob', 'required_glob')
        else:
            assert typ in ('required_positional', 'optional_positional')
        two = formal_node.handle_positional(state.parse_tree, state.head_token)
        if two is not None:
            assert two[0] in ('early_stop',)
            return two
        if formal_node.is_glob:
            if was_reqglob:
                # The state after a required glob formal consumed its token is:
                move_to(from_optional_positional_state)
            return  # Don't pop the formal stack, leave glob on there forever
        formal_stack.pop()
        return find_new_state_per_positionals()

    def maybe_accept_dash_token():
        if state.formal_nonpositional_in_progress.can_accept_dash_as_value:
            return maybe_accept_nonpos_in_progress_value()
        def explanation():
            yield 'early_stop_reason', 'cannot_be_dash'  # #here10
            yield 'stderr_line', "can't use '-' as value\n"
            yield 'returncode', 75  # #here1
        return 'early_stop', explanation

    def maybe_accept_nonpos_in_progress_value():
        formal_node = state.formal_nonpositional_in_progress
        state.formal_nonpositional_in_progress = None
        typ = formal_node.formal_type
        assert typ in ('optional_nonpositional',)  # ..
        two = formal_node.handle_value_of_nonpositional(
                state.parse_tree, state.head_token)
        if two is not None:
            assert two[0] in ('early_stop',)
            return two
        state.state_function = state.state_function_on_hold
        state.state_function_on_hold = None
        return find_new_state_per_positionals()

    def react_to_double_dash():
        xx('double dash behavior needs to be spec\'d')

    def respond_to_interactivity():  # #FSA-action-response
        formal_yes, is_interactive = is_interactive_expected_actual()
        ok = False
        if formal_yes is None:
            ok = True
        elif formal_yes and is_interactive:
            ok = True
        elif (not formal_yes) and (not is_interactive):
            ok = True
        if not ok:
            return will_complain_about_wrong_interactivity()
        formal_stack.pop()
        return find_new_state_per_positionals()

    def accept_option_value_and_pop():
        xx()

    # Support for actions

    def find_new_state_per_positionals():  # #FSA-action-response
        if 0 == len(formal_stack):
            return move_to(from_no_more_positionals_state)
        formal_node = formal_stack[-1]
        assert formal_node.is_positional
        typ = formal_node.formal_type
        if formal_node.is_glob:
            if 'required_glob' == typ:
                return move_to(from_required_glob_initial_state)
            if 'optional_glob' == typ:
                return move_to(from_optional_positional_state)
            xx(f"? {typ!r}")
        if 'required_positional' == typ:
            return move_to(from_required_positional_state)  # maybe redundant
        if 'optional_positional' == typ:
            return move_to(from_optional_positional_state)
        xx(f"? {typ!r}")

    def close_because_satisfied():  # #FSA-action-response
        res = state.parse_tree
        state.parse_tree = None
        return 'parse_tree', _finish_parse_tree(res)

    # Non-interesting actions

    def will_complain_about_expecting_required_positional():  # #FSA-action-response
        def explain():
            shout = formal_stack[-1].familiar_name
            yield 'early_stop_reason', 'expecting_required_positional', shout
            yield 'returncode', 73  # #here1
        return 'early_stop', explain

    def will_complain_about_unexpected_term():  # #FSA-action-response
        def explain():
            yield 'early_stop_reason', 'unexpected_extra_argument'
            yield 'returncode', 66  # #here1
        return 'early_stop', explain

    def will_complain_about_expecting_option_value(): # #FSA-action-response
        xx()  # #here10

    def will_complain_about_wrong_interactivity():
        def explain():
            yield 'early_stop_reason', 'wrong_interactivity'
            formal_yes, is_interactive = is_interactive_expected_actual()
            assert bool(formal_yes) != bool(is_interactive)
            if formal_yes:
                xx('cover me, looks ok')
                token = state.head_token
                line = "when STDIN is interactive, expected '-' not {token!r}\n"
            else:
                xx('cover me, looks ok')
                line = "in interactive mode, expecting file, not '-'\n"
            yield 'stderr_line', line
            yield 'returncode', 74  # #here1
        return 'early_stop', explain

    def is_interactive_expected_actual():
        formal_frame = formal_stack[-1]
        assert 'for_interactive' == formal_frame[0]
        return formal_frame[1], state.input_event[1]

    # Matchers

    def if_non_option_looking_token():
        return 'looks_like_non_option' == state.token_category  # mighte be None

    def if_option_looking_token():
        return 'looks_like_option' == state.token_category  # might be None

    def if_end_or_special():
        if if_end_of_tokens():
            return True
        return 'special_token' == state.token_category

    def if_double_dash_token():
        return '--' == state.head_token

    def if_single_dash_token():
        return '-' == state.head_token

    def if_end_of_tokens():
        return 'end_of_tokens' == state.input_event_type

    def if_interactivity_event():
        return 'is_interactive' == state.input_event_type

    # State machine mechanics

    def receive_input_event_tuple(tup):
        state.input_event = tup
        state.input_event_type = tup[0]
        if 'head_token' == state.input_event_type:
            state.head_token = tup[1]
            state.token_category = _categorize_token(state.head_token)
        else:
            state.head_token = None
            state.token_category = None

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

    floating_cloud = _floating_cloud_via_nonpositionals(nonpositionals)
    formal_stack = _lazy_formal_stack(
            state.parse_tree, positionals, subcommands, for_interactive)

    return _InputReceiverFacade(receive_input_event_tuple)


def _categorize_token(token):
    leng = len(token);
    if 0 == leng:
        xx('handling the empty string should be ok but should be covered')
        return 'looks_like_non_option'
    starts_with_dash = '-' == token[0]
    if 1 == leng:
        if starts_with_dash:
            return 'special_token'  # 'the_single_dash_token'
        return 'looks_like_non_option'
    if not starts_with_dash:
        return 'looks_like_non_option'
    if 2 == leng and '-' == token[1]:
        xx('have fun -- it will be fine')
        return 'special_token'  # 'DOUBLE_DASH'
    return 'looks_like_option'


class _InputReceiverFacade:

    def __init__(self, f):
        self.receive_input_event_tuple = f

    def receive_input_event(self, *tup):
        return self.receive_input_event_tuple(tup)


def _floating_cloud_via_nonpositionals(tup):
    # The "floating cloud" is an API-private collection of the formal flags and
    # optional_nonpositional's tailor-made for our parsing algorithm. It does:
    #
    #  - ensure uniqueness of each long form (`familiar_name`)
    #  - note if any [#608.18] '"BSD-style" nonpositionals'
    #  - don't "expand" each formal parameter into an object until needed
    #  - add "--help" by default
    #
    # See [#608.10] "How we parse the nonpositionals with a floating cloud".

    def keys_and_raw_values():
        for sx in (tup or ()):
            assert sx[0] in ('optional_nonpositional', 'flag')
            yield sx[1], sx
        if True:  # (one day, maybe help option will be opt-in)
            yield '--help', ('flag', '--help', ('value_normalizer', _on_help))

    def see_key(k):
        assert k not in seen
        seen.add(k)
        if rx.match(k):
            state.seen_one_BSD_style = True
        return k

    state = see_key  # #watch-the-world-burn
    state.seen_one_BSD_style = False
    rx = re.compile('^-[a-zA-Z]')
    seen = set()

    use_itr = ((see_key(k), v) for k, v in keys_and_raw_values())
    dict_like = _dictionary_like_cache(use_itr, _expand_nonpositional)

    class FloatingCloud:
        pass

    fc = FloatingCloud()
    for m, f in _floating_cloud_methods(dict_like, state.seen_one_BSD_style):
        setattr(fc, m, f)
    return fc


def _on_help(_existing_value):  # value normalizer #here3
    def early_stop():
        yield 'early_stop_reason', 'display_help'
        yield 'returncode', 0
    return 'early_stop', early_stop


def _floating_cloud_methods(these, seen_one_BSD_style):

    def against(token):  # return (expl, formal, replace_with_token)
        md = re.match(r'^-(?P<is_long>-)?(?P<slug_fragment>.*)$', token)

        # If it looks long
        if md['is_long']:
            return against_long_token(md)

        # It looks short..
        if seen_one_BSD_style:
            # Under BSD-style parsing, normally we treat every short-looking
            # token as "long" and don't do our fuzzy lookup (right?). But if
            # we do this we don't handle "-h" the idiomatic way. So, special:

            if '-h' == token and '--help' in these:
                return against_short_token(md)
            return against_long_token(md)
        return against_short_token(md)

    yield 'against', against

    def against_short_token(md):  # return (expl, formal, replace_with_token)
        slug_frag = md['slug_fragment']

        # First, match all nerks with this derk
        if '--' in these:
            xx()
        else:
            use_keys = these.keys()
        needle = slug_frag[0]
        assert re.match('^[a-zA-Z]$', needle)  # until..
        needle_rx = re.compile(f'^--?{needle}')
        founds = tuple(k for k in use_keys if needle_rx.match(k))

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
        formal = these[longg]
        if 1 < len(slug_frag):
            the_rest = slug_frag[1:]
            if 'flag' == formal.formal_type:
                replace_with_token = ''.join(('-', the_rest))
            else:
                assert 'optional_nonpositional' == formal.formal_type
                replace_with_token = the_rest
        else:
            replace_with_token = None

        return None, formal, replace_with_token

    def against_long_token(md):  # return (expl, formal, replace_with_token)
        token = md[0]

        # First, just see if we match against the long token as-is
        formal = these.get(token)
        if formal:
            return None, formal, None

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
            return None, these[use_tok], None
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


def _lazy_formal_stack(parse_tree, positionals, subcommands, for_interactive):
    # The typical real-world command won't have "many" of these pieces so..
    # This is similar to #here4 where we build the structures only lazily
    # See [#608.18] "How we use stacks to parse positional parameters"
    # and "The order in which term types are processed"

    stack = []

    # Add the positionals first because they'll be the last to be parsed
    for sx in reversed(positionals or ()):
        stack.append([True, sx, _Positional])  # "_expand_positional"

    # Add the subcommands next, they are parsed before positionals
    if subcommands:
        def expand_subcommand(s):
            return _expand_subcommand(parse_tree, s)
        for s in reversed(subcommands):
            stack.append([True, s, expand_subcommand])

    # Finally, append this
    stack.append([False, ('for_interactive', for_interactive)])

    class LazyFormalStack:

        def pop(self):
            if not len(stack):
                raise IndexError('pop from empty list')
            res = self[-1]
            stack.pop()
            return res

        def __getitem__(self, i):  # the workhorse, the main thing
            assert -1 == i
            record = stack[-1]
            if record[0]:
                record[1] = record.pop()(record[1])
                record[0] = False
            return record[1]

        def __len__(self):
            return len(stack)

        REAL_STACK = stack

    return LazyFormalStack()


# == Support for the foundational formal parameter classes

def _generic_registry(deep_copy_this_dict=None):
    """Result is a decorator that is typically used to decorate a class by
    associating a simple key with it. Subsequently access the class by the key
    through the decorator itself, which is also the store.
    """

    class DecoratorAndStore:
        def __call__(_, k):
            def use(c_or_f):
                dct[k] = c_or_f
                return c_or_f
            return use
        def __getitem__(_, k):
            return dct[k]
        @property
        def internal_dictionary(_):
            return dct
    if deep_copy_this_dict:
        xx()
        dct = {k: v for k, v in deep_copy_this_dict.items()}
    else:
        dct = {}
    return DecoratorAndStore()


def _HANDLE_AGAINST_VALUED_FORMAL(parse_tree, token, formal):

    # If there's a value constraint, apply that. Maybe stop early
    resp = None
    f = formal.value_constraint
    if f:
        resp = f(token)  # #here8
        if resp:
            if 'early_stop' == resp[0]:
                return resp
            assert 'value_constraint_memo' == resp[0]  # #here7

    # If there's a value normalizer, apply that.
    k = formal._snake_name
    f = formal.value_normalizer
    if f:
        # (The only occasion we expect to have an existing value for a
        # nonpositional is #feature:glob-positionals)
        kwargs = {'token': token}
        if k:  # subcommand (as formal positional) won't have storage key
            kwargs['existing_value'] = parse_tree.values.get(k)
        if resp:
            kwargs['value_constraint_memo'] = resp[1]  # #here7
        resp = f(**kwargs)  # #here9

        # A value normalizer that results in None is saying "i handled it
        # all. Don't do anything further on this formal parameter." :#here11
        if resp is None:
            return

        # The value normalizer can certainly stop the parse
        if 'early_stop' == resp[0]:
            return resp

        assert 'use_value' == resp[0]
        use_this_value, = resp[1:]
    else:
        use_this_value = token

    assert k  # some don't have storage names, e.g. subcommand
    parse_tree.values[k] = use_this_value


def _monadic_writer(k):
    def write(formal, x):
        setattr(formal, k, x)
    return write


_write_value_constraint = _monadic_writer('value_constraint')
_write_value_normalizer = _monadic_writer('value_normalizer')


@property
def _snake_name_for_nonpositional(self):
    md = re.match('^--?(?P<snake>[a-zA-Z][-a-zA-Z0-9]+)$', self.familiar_name)
    if not md:
        assert re.match('^-[a-zA-Z]$', self.familiar_name)  # meh
        return self.familiar_name  # meh
    return md['snake'].replace('-', '_')


# == Positionals (required and optional)

def _expand_subcommand(parse_tree, sx):
    literal_value, = sx[1:]

    def familiar_name():
        return '"' + literal_value + '"'

    def constrain(token):  # #here8
        if literal_value == token:
            return  # you passed normalization
        if len(token) < len(literal_value) and \
                literal_value[0:len(token)] == token:
            # #feature:fuzzy
            xx("not yet implemented: fuzzy match subcommand")
        def explain():
            yield 'early_stop_reason', 'expecting_subcommand', literal_value
            yield 'returncode', 71  # #here1
        return 'early_stop', explain

    def normalize_and_store(token):  # #here9
        assert literal_value == token
        parse_tree.subcommands.append(literal_value)

    return _Positional(('required_positional', None,
            ('value_constraint', constrain),
            ('value_normalizer', normalize_and_store),
            ('familiar_name_function', familiar_name)))


class _Positional:  # #here5
    def __init__(self, sx):
        stack = list(reversed(sx))
        typ = stack.pop()
        if typ in ('required_positional', 'optional_positional'):
            pass
        elif typ in ('optional_glob', 'required_glob'):
            self.is_glob = True
        else:
            xx(f"is this a positional? not covered yet: {typ!r}")
        self.formal_type = typ
        self._familiar_name_value = stack.pop()
        while len(stack):
            k, *rest = stack.pop()
            _write_positional_property[k](self, *rest)
        if self.is_glob:
            if self.value_normalizer:
                xx("you need normalizer chains")
            self.value_normalizer = _add_glob_val

    def handle_positional(self, parse_tree, token):
        return _HANDLE_AGAINST_VALUED_FORMAL(parse_tree, token, self)

    value_constraint = None
    value_normalizer = None

    @property
    def familiar_name(self):
        return (self._familiar_name_value or self.familiar_name_function())

    @property
    def _snake_name(self):
        s = self._familiar_name_value
        if s is None:
            return  # subcommands don't have familar names
        assert re.match('^[A-Z][A-Z0-9_]+$', s)
        return s.lower()

    is_glob = False
    is_positional = True


_write_positional_property = _generic_registry()  # #here6
_write_positional_property('value_constraint')(_write_value_constraint)
_write_positional_property('value_normalizer')(_write_value_normalizer)
_write_positional_property('familiar_name_function')(_monadic_writer('familiar_name_function'))


def _add_glob_val(existing_value, token):
    if existing_value:
        existing_value.append(token)
        return  # #here11
    return 'use_value', [token]


# == Nonpositionals (required, optional and flag)

def _expand_nonpositional(sx):
    return _nonpositional_class_for[sx[0]](sx)


_nonpositional_class_for = _generic_registry()


@_nonpositional_class_for('optional_nonpositional')
class _OptionalNonpositional:
    def __init__(self, sx):
        stack = list(reversed(sx))
        assert 'optional_nonpositional' == stack.pop()
        self.familiar_name = stack.pop()
        self.parameter_familiar_name = stack.pop()
        while len(stack):
            k, *rest = stack.pop()
            _write_nonpos_property[k](self, *rest)

    def handle_value_of_nonpositional(self, parse_tree, token):
        return _HANDLE_AGAINST_VALUED_FORMAL(parse_tree, token, self)

    value_constraint = None
    value_normalizer = None
    can_accept_dash_as_value = False
    _snake_name = _snake_name_for_nonpositional
    formal_type = 'optional_nonpositional'


_write_nonpos_property = _generic_registry()
_write_nonpos_property('value_constraint')(_write_value_constraint)
_write_nonpos_property('value_normalizer')(_write_value_normalizer)


@_write_nonpos_property('can_accept_dash_as_value')
def _write_nonpos_dash_etc(formal):
    formal.can_accept_dash_as_value = True


@_nonpositional_class_for('flag')
class _Flag:  # #here5
    def __init__(self, sx):
        stack = list(reversed(sx))
        assert 'flag' == stack.pop()
        self.familiar_name = stack.pop()
        while len(stack):
            k, *rest = stack.pop()
            _write_flag_property[k](self, *rest)

    def handle_flag(self, parse_tree):
        k = self._snake_name
        f = self.value_normalizer

        # If there is no value normalizer, just set the value to true and done
        if f is None:
            parse_tree.values[k] = True  # might be clobber (covered)
            return
        existing_value = parse_tree.values.get(k)
        two = f(existing_value)
        if two is None:
            return
        # #here3:
        if 'use_value' == two[0]:
            xx('written but cover')
            parse_tree.values[k] = two[1]
            return
        assert 'early_stop' == two[0]
        return two

    value_normalizer = None
    _snake_name = _snake_name_for_nonpositional
    formal_type = 'flag'
    is_positional = False


_write_flag_property = _generic_registry()  # #here6
_write_flag_property('value_normalizer')(_write_value_normalizer)


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


def _finish_parse_tree(pt):
    if pt.subcommands:
        pt.subcommands = tuple(pt.subcommands)
    return pt


""" :#here6: this is the centerpiece of XX but XX
"""


def _dictionary_like_cache(keys_and_raw_values, expander):
    """
    Dictionary-like lazy-loading cache: construct it with {an iterator of keys
    and values}, and an "expander". The interface is similar to a dictionary,
    but rather than resulting in the "raw" values, the result values are the
    result of the raw value being passed through the "expander" (which is
    cached). The iterator is traversed fully at construction time. :#here4
    """

    class DictionaryLikeCache:
        pass

    dict_like = DictionaryLikeCache()
    for m, f in _dictionary_like_cache_methods(keys_and_raw_values, expander):
        if '_' == m[0]:
            setattr(DictionaryLikeCache, m, f)
        else:
            setattr(dict_like, m, f)
    return dict_like


def _dictionary_like_cache_methods(keys_and_raw_values, expander):

    def contains(_, k):
        return k in records

    yield '__contains__', contains

    def getitem(_, k):
        res = get(k)
        if res is None:
            raise KeyError(k)
        return res

    yield '__getitem__', getitem

    def get(k):
        record = records.get(k)
        if record is None:
            return
        do_expand, val = record
        if do_expand:
            val = expander(val)
            record[0] = False
            record[1] = val
        return val

    yield 'get', get

    def keys():
        return records.keys()

    yield 'keys', keys

    records = {k: [True, raw] for k, raw in keys_and_raw_values}

# ==


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
    # TODO XX see help_lines_via_invocation. merge this with that.
    # (this should be in text_lib now, but we're leaving it here for now.)
    # (we desparately wanted to write this anew with a state machine
    # before rediscovering it here. we forced ourself not to do so,
    # to focus on the important despite the urgent. But it's our belief
    # that a state machine would perhaps be easier code to follow.)

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
