# everything is explained in [#608.18]


import re


def ALTERNATION_VIA_SEQUENCES(seqs):
    """going to try to hew really close to the doc pseudocode in the
    introductory test file
    """

    leng = len(seqs)
    assert leng
    if 1 == leng:
        raise RuntimeError("with only once sequence, use sequence itself")

    match_any = _rewrite_interactivity_designations(seqs)
    in_the_running = {k: None for k in range(0, leng)}

    def receive_input_event_tuple(tup):

        stats = _Stats(in_the_running)

        if conditional_stuff_before:
            conditional_stuff_before.pop()(tup)

        # Feed the input event out to all the nerks "in parallel"
        for i in in_the_running.keys():
            resp = seqs[i].receive_input_event_tuple(tup)
            if resp is None:
                continue
            stats.add_response(i, resp)

        if conditional_stuff_after:
            res = conditional_stuff_after.pop()(stats, tup)
            if res:
                assert res[0] in ('early_stop', 'stop_parsing')
                return res

        func = which(*stats.to_three_integers())
        return func(*stats.to_args())

    # == BEGIN experiment with jumping thru hoops to get "match any" at head
    conditional_stuff_before = conditional_stuff_after = None
    if match_any:
        def conditional_stuff_before():
            def before(tup):
                """The second input event: If it was end of tokens, do nothing.
                We handle it #here2. Otherwise (and it's a token), take
                yourself out of the running because we don't actually process
                tokens. :#here13"""
                typ = tup[0]
                if 'head_token' != typ:
                    assert 'end_of_tokens' == typ
                    # we are still in the running per #here2 and we will issue
                    # a response about expecting at tag.
                    return
                for i in match_any:
                    in_the_running.pop(i, None)  # might already be out
            yield before
            def before(tup):
                # The first input event: Assert this one thing & be done
                assert 'is_interactive' == tup[0]
            yield before
        def conditional_stuff_after():
            def after(stats, tup):  # The second input event
                typ = tup[0]

                # If end of tokens, leave ourselves in the running by #here2
                if 'head_token' != typ:
                    assert 'end_of_tokens' == typ
                    return  # (Case6042.test_030)

                # Otherwise (and it's a token), keep in mind we are already
                # not in the running because #here13

                num_stops, num_trees, num_still_running = stats.to_three_integers()

                # If anybody wanted the token and is still in progress
                # processing it (still running), stay out and procede as normal
                if num_still_running:
                    return  # (Case6040.test_010) (Case6042.test_040)

                # If anybody closed with a tree (strange not at end of tokens)
                # stay out and procede as normal
                if num_trees:
                    xx('not covered but probably fine')
                    return

                # There are early stops
                func = which(num_stops, num_trees, num_still_running)

                # We've gotta peek into the early stop to see the reason
                res = func(*stats.to_args())
                assert 'early_stop' == res[0]
                rsn = next(res[1]())
                assert 'early_stop_reason' == rsn[0]  # conventioal (not guar.)

                # If the early stop reason was for help, procede as normal
                if 'display_help' == rsn[1]:
                    return res  # (Case6042.test_050)

                # Everyone is out of the running. Assume the early stop
                # reason(s) were parse failure. It is in this case that we,
                # the "match any", are activated: match any token but don't
                # consume it #here14

                res = seqs[match_any[0]].receive_input_event('stop_parsing')
                # if empty parse tree, they should all be the same let's hope
                assert 'stop_parsing' == res[0]
                return res  # (Case6042.test_020)

            yield after
            def after(stats, tup):
                # The first input event: Assert (again) this one thing
                assert 'is_interactive' == tup[0]
            yield after
        conditional_stuff_before = list(conditional_stuff_before())
        conditional_stuff_after = list(conditional_stuff_after())
    # == END

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
    # see "Merging responses" in [#608.18]

    semantic_taxonomy = {
        'display_help': (),
        'expecting_required_positional': (),
        'expecting_subcommand': ('expecting_required_positional',),
        'failed_value_constraint': ('expecting_required_positional',)
    }

    def merge_in_early_stop_reason(reason_tail):
        reason_key = reason_tail[0]
        channel = (*semantic_taxonomy[reason_key], reason_key)
        shorten_longest_common_channel(channel)
        if 'expecting_required_positional' == channel[0]:
            assert 1 < len(reason_tail)
            surface = reason_tail[-1]
            expecting_surfaces[surface] = None

    def shorten_longest_common_channel(channel):
        if state.longest_common_channel is None:
            state.longest_common_channel = channel
            return
        min_leng = min(len(channel), len(state.longest_common_channel))
        do_shorten = False
        for i in range(0, min_leng):
            memo_one = state.longest_common_channel[i]
            this_one = channel[i]
            if memo_one == this_one:
                continue
            do_shorten = True
            break
        if not do_shorten:
            return
        if 0 == i:
            xx(f"bad alternation grammar: conflict in early stop shapes")
        xx("shorten, easy")

    state = shorten_longest_common_channel  # #watch-the-world-burn
    state.longest_common_channel = None
    expecting_surfaces = {}

    def merge_in_returncode(rc):
        x = state.highest_returncode
        if x is None or x < rc:
            state.highest_returncode = rc

    state.highest_returncode = None

    for expl in expls:
        for component in expl():
            typ, *pay = component
            if 'returncode' == typ:
                merge_in_returncode(*pay)
            elif 'early_stop_reason' == typ:
                merge_in_early_stop_reason(pay)
            else:
                xx()

    def explain():
        use_subtype = state.longest_common_channel[-1]
        pcs = ['early_stop_reason', use_subtype]
        these = tuple(expecting_surfaces.keys())
        if these:
            use = these[0] if 1 == len(these) else these
            pcs.append(use)
        yield tuple(pcs)

        highest_returncode = state.highest_returncode
        if highest_returncode is not None:
            yield 'returncode', highest_returncode

    return explain


def _rewrite_interactivity_designations(seqs):
    """At the engine level, the engine wants to tend towards being agnostic
    about interactivity designation: If the sexp sequence (usage line) doesn't
    state explicity that it's *for* interactivity or *not* for interactivity,
    the engine wants to take a neutral stance and allow the usage line to match
    for both interaction modes.

    However in practice this becomes annoying vis-a-vis our one frontend:
    Although there is a type of term for indicating that that the usage line is
    *for* STDIN, there is no corresponding idiom for expressing that the usage
    line is for *not* STDIN (that is, it *is* for interactive mode (only)).
    (We could introduce such meta-syntax, but this would make it noisy and
    unnatural.)

    As such, (currently at the engine level) we awkwardly mutate those usage
    lines that didn't state explicitly they are *for* interactive IFF there
    is one or more that indicated it is *for* STDIN. This makes the parsing
    of ARGVs go more smoothly because we can disqualify non-matching usage
    lines earlier. The "diamond" use cases cover this XX.

    Against the "diamond" canonic compound syntax, if the client pipes in STDIN
    *and* passes a filename, the desired behavior is to complain about the
    filename argument not being a "-". In absense of the idiomatic mutation
    here, it will be undefined/unexpected/silently unclear which usage line
    would match this input.

    (While making the full traversal, we also gather against one more dimension.)

    Experimental and we might rather push this up somehow.
    """

    yeses = [] ; nos = [] ; not_specifieds = [] ; match_any = []
    for i in range(0, len(seqs)):
        seq = seqs[i]
        if seq.matches_anything:
            match_any.append(i)
        ynm = seq.is_for_interactive
        if ynm is None:
            not_specifieds.append(i)
        elif ynm is True:
            yeses.append(i)
        else:
            assert ynm is False
            nos.append(i)

    if nos and not yeses:
        # (some tests specify "yes" explicitly but this is unnatural)
        # Only if some said they are not for interactive
        # Make the ones that say None say True so they get eliminated in parsing
        for i in not_specifieds:
            seqs[i]._become_for_interactive()

    return match_any


class _Stats:

    def __init__(self, in_the_running):
        self.early_stops = {}
        self.parse_trees = {}
        self._in_the_running = in_the_running

    def add_response(self, i, resp):  # #FSA-action-response
        typ, pay = resp
        if 'early_stop' == typ:
            dct = self.early_stops
        else:
            assert typ in ('parse_tree', 'stop_parsing')
            dct = self.parse_trees
        dct[i] = pay

    def to_args(self):
        if self.early_stops:
            yield self.early_stops
        if self.parse_trees:
            yield self.parse_trees

    def to_three_integers(self):
        return self._num_stops, self._num_trees, self._num_still_running

    @property
    def _num_still_running(self):
        return len(self._in_the_running) - (self._num_stops + self._num_trees)

    @property
    def _num_stops(self):
        return len(self.early_stops)

    @property
    def _num_trees(self):
        return len(self.parse_trees)


def SEQUENCE_VIA_TERM_SEXPS(sexps, parameter_refinements=None):

    # States and Transitions

    def from_beginning_state():
        yield if_interactivity_event, respond_to_interactivity

    def from_stopped_parsing_state():
        yield if_end_of_tokens, will_complain_about_expecting_any  # #here2
        yield if_stop_parsing, stop_parsing_with_empty_parse_tree

    def from_required_positional_state():
        yield if_non_option_looking_token, try_to_satisfy_positional
        yield if_option_looking_token, maybe_accept_optional_nonpositional
        yield if_single_dash_token, maybe_accept_single_dash_for_reqpos
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
        yield if_single_dash_token, maybe_accept_single_dash_for_nonpos
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
        """Special hack EXPERIMENTAL: give positionals a chance to intercept
        an option-looking token under these conditions, by peeking against
        the constraint. if the positional has a constraint to accept the
        leading dash, we assume etc. (we could move this to lower precedence
        than options too) :#here12
        """

        special_failure = None
        if len(formal_stack) and (posi := formal_stack[-1]).value_constraint:
            special_failure = posi.value_constraint(state.head_token)
            if not special_failure:
                return try_to_satisfy_positional()
        return try_to_satisfy_options_cloud(special_failure)

    def try_to_satisfy_options_cloud(special_failure=None):
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

                # ugh if doing this experimental hack w/ positionals, we want
                # the more specific failure over the more general #here12
                if special_failure:
                    assert 'early_stop' == special_failure[0]
                    return special_failure

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

    def maybe_accept_single_dash_for_reqpos():  # #FSA-action-return
        return try_to_satisfy_positional(is_dash=True)

    def try_to_satisfy_1st_reqglob_positional():  # #FSA-action-response
        return try_to_satisfy_positional(was_reqglob=True)

    def try_to_satisfy_positional(was_reqglob=False, is_dash=False):
        # #FSA-action-response
        # Sanity-check the properties of the formal
        formal_node = formal_stack[-1]
        typ = formal_node.formal_type
        if formal_node.is_glob:
            assert typ in ('optional_glob', 'required_glob')
        else:
            assert typ in ('required_positional', 'optional_positional')

        # Handle the token and return if it failed
        if is_dash and not formal_node.can_accept_dash_as_value:
            # formals that *do* accept dash *do* have value constraint,
            # but formals that *don't* do *not* themselves protect themselves
            return 'early_stop', _explain_dash_noaccept_nopos_or_pos

        two = formal_node.handle_positional(state.parse_tree, state.head_token)
        if two is not None:
            assert two[0] in ('early_stop',)
            return two

        # Peek ahead to determine if there's a #feat:passive-parsing stop
        def do_stop_parsing():
            if len(formal_stack) < 2:
                return
            o = formal_stack[-2]  # o = next formal node
            return o.is_positional and 'stop_parsing' == o.formal_type  # #here16
        do_stop_parsing = do_stop_parsing()

        # If it's a glob, leave the formal on the stack to be used over and over
        if formal_node.is_glob:
            assert not do_stop_parsing
            if was_reqglob:
                # The state after a required glob formal consumed its token is:
                move_to(from_optional_positional_state)
            return  # Don't pop the formal stack, leave glob on there forever

        # Normally, pop the stack and find the new state based on new stack
        formal_stack.pop()
        if do_stop_parsing:
            return 'stop_parsing', close_parse_tree()
        return find_new_state_per_positionals()

    def maybe_accept_single_dash_for_nonpos():
        if state.formal_nonpositional_in_progress.can_accept_dash_as_value:
            return maybe_accept_nonpos_in_progress_value()
        return 'early_stop', _explain_dash_noaccept_nopos_or_pos

    def maybe_accept_nonpos_in_progress_value():
        formal_node = state.formal_nonpositional_in_progress
        state.formal_nonpositional_in_progress = None
        assert 'optional_nonpositional' == formal_node.formal_type
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
        # (we used to pop the formal stack here before #history-C.2)
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
        if 'stop_parsing' == typ:
            return move_to(from_stopped_parsing_state)
        xx(f"? {typ!r}")

    def stop_parsing_with_empty_parse_tree():
        return 'stop_parsing', close_parse_tree(do_consume_head_token=False)

    def close_because_satisfied():  # #FSA-action-response
        return 'parse_tree', close_parse_tree()

    def close_parse_tree(do_consume_head_token=True):
        res = state.parse_tree
        assert res
        state.parse_tree = None
        return _finish_parse_tree(res, do_consume_head_token)

    # Non-interesting actions

    def will_complain_about_expecting_any():  # #FSA-action-value, #here2
        return _early_stop_for_match_any(formal_stack[-1].familiar_name)

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
            formal_yes, is_interactive = is_interactive_expected_actual()
            assert bool(formal_yes) != bool(is_interactive)
            yield 'early_stop_reason', 'wrong_interactivity', formal_yes, is_interactive
            if formal_yes:
                xx('cover me, looks ok')
                token = state.head_token
                line = "when STDIN is interactive, expected '-' not {token!r}\n"
            else:
                line = "in interactive mode, expecting file, not '-'\n"
            yield 'stderr_line', line
            yield 'returncode', 74  # #here1
        return 'early_stop', explain

    def is_interactive_expected_actual():
        actual_value, = state.input_event[1:]
        return facade.is_for_interactive, actual_value

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

    def if_stop_parsing():
        return 'stop_parsing' == state.input_event_type

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

        for matcher, action in state.state_function():
            found = matcher()
            if found:
                return action()

        def message():
            yield "found no transtion"
            yield state.state_function.__name__.replace('_', ' ')
            yield f"with input event {tup!r}"
        xx(' '.join(message()))

    def move_to(state_func):  # #FSA-action-response
        state.state_function = state_func

    state = from_beginning_state  # #watch-the-world-burn
    state.state_function = from_beginning_state
    state.parse_tree = _data_classes().parse_tree()

    add_nonpos_to_cloud, floating_cloud = \
            _begin_floating_cloud(parameter_refinements)

    if True:  # (one day maybe opt-in)
        add_nonpos_to_cloud(('flag', '--help', ('value_normalizer', _on_help)))

    itr = _each_next_formal(add_nonpos_to_cloud, state.parse_tree, sexps)
    formal_stack = _lazy_formal_stack_via_formals(itr)

    # Pop the first formal off the stack now because we need it below
    def ynm():  # ynm = yes no maybe
        sx = formal_stack.pop()
        assert 'for_interactive' == sx[0]
        ynm, = sx[1:]
        return ynm
    ynm = ynm()

    # Peek ahead to the any first positional to see if this matches anything
    def mat():  # mat = match any token
        if not len(formal_stack):
            return
        top = formal_stack[-1]
        return 'stop_parsing' == top.formal_type and top
    mat = mat()

    facade = _SequenceFacade(receive_input_event_tuple, ynm, mat)
    return facade


def _early_stop_for_match_any(familiar):
    def explain():
        yield 'early_stop_reason', 'expecting_required_positional', familiar
        yield 'returncode', 73  # #here1
    return 'early_stop', explain


def _explain_dash_noaccept_nopos_or_pos():
    yield 'early_stop_reason', 'cannot_be_dash'  # #here10
    yield 'returncode', 75  # #here1


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


class _SequenceFacade(_InputReceiverFacade):

    def __init__(self, recv_input, for_interactive_yes_no_none, mat):
        super().__init__(recv_input)
        if mat:
            self.matches_anything = True
            self.term_at_head_for_matches_anything = mat
        else:
            self.matches_anything = False
        self.is_for_interactive = for_interactive_yes_no_none

    def _become_for_interactive(self):
        assert self.is_for_interactive is None
        self.is_for_interactive = True


def _begin_floating_cloud(parameter_refinements):
    # The "floating cloud" is an API-private collection of the formal flags and
    # optional_nonpositional's tailor-made for our parsing algorithm. It does:
    #
    #  - ensure uniqueness of each long form (`familiar_name`)
    #  - note if any [#608.18] '"BSD-style" nonpositionals'
    #  - don't "expand" each formal parameter into an object until needed
    #  - add "--help" by default
    #
    # See [#608.10] "How we parse the nonpositionals with a floating cloud".

    if parameter_refinements:
        assert hasattr(parameter_refinements, '__getitem__')

    def add_nonpos_to_cloud(sx):  # how the client adds to the collection
        familiar_name = sx[1]
        if rx_BSD_style.match(familiar_name):
            fc.seen_one_BSD_style = True
        if familiar_name in records:
            xx(f"won't clobber existing nonpositional: {familiar_name!r}")
        records[familiar_name] = [True, sx]

    rx_BSD_style = re.compile('^-[a-zA-Z]')

    class these:  # used to be dedicated class before #history-C.2
        def __contains__(_, k):
            return k in records

        def __getitem__(self, k):
            res = self.get(k)
            if res is None:
                raise KeyError(k)
            return res

        def get(_, k):
            record = records.get(k)
            if record is None:
                return
            do_expand, nonpos = record
            if do_expand:
                nonpos = expand_nonpos(nonpos)
                record[0] = False
                record[1] = nonpos
            return nonpos

        def keys(_):
            return records.keys()

    these = these()

    def expand_nonpos(sx):  # the formal is only expanded when it's retrieved
        typ, familiar_name = sx[:2]
        assert typ in ('optional_nonpositional', 'flag')
        if parameter_refinements and familiar_name in parameter_refinements:
            sx = (*sx, *parameter_refinements[familiar_name])
        return _expand_nonpositional(sx)  # #here4

    class fc:  # fc = floating cloud
        def __init__(self):
            self.seen_one_BSD_style = False

    fc = fc()
    for m, f in _floating_cloud_methods(these, lambda: fc.seen_one_BSD_style):
        setattr(fc, m, f)
    records = {}
    return add_nonpos_to_cloud, fc


def _on_help(_existing_value):  # value normalizer #here3
    def early_stop():
        yield 'early_stop_reason', 'display_help'
        yield 'returncode', 0
    return 'early_stop', early_stop


def _floating_cloud_methods(these, seen_one_BSD_styler):

    def against(token):  # return (expl, formal, replace_with_token)
        md = re.match(r'^-(?P<is_long>-)?(?P<slug_fragment>.*)$', token)

        # If it looks long
        if md['is_long']:
            return against_long_token(md)

        # It looks short..
        if seen_one_BSD_styler():
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
                yield 'early_stop_reason', 'unrecognized_short'
                yield 'returncode', 69  # #here1
            return explanation, None, None
        if 1 < leng:
            def explanation():
                yield 'early_stop_reason', 'ambiguous_short'
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
            return explanation, None, None

        # It looks long but it didn't match verbatim

        # Fuzzy let's go (might become option one day)
        if True:
            rx = re.compile(''.join(('^', re.escape(token))))
            founds = tuple(k for k in these.keys() if rx.match(k))
            leng = len(founds)

        if 1 < leng:
            def explanation():
                yield 'early_stop_reason', 'ambiguous_long', founds
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


def _lazy_formal_stack_via_formals(formals):
    """See [#608.18] "How we use stacks to parse positional parameters"
    The engine reads the formal positionals list through the "stack" idiom.
    - Originally the "formal stack" *was* a straightforward stack of formals.
    - In python we typically use lists in a stack-like way to accomplish stacks.
    - Now it's streaming and lazy.
    - To make it "fail fast" just `return list(reversed(formals))` instead
    """

    class LazyFormalStack:

        def pop(self):
            if buffer_empty():
                raise IndexError('pop from empty list')
            return buffer_next()

        def __getitem__(self, i):  # the workhorse, the main thing
            if buffer_empty():
                raise IndexError('list index out of range')
            if -1 == i:
                return buffer[0]
            # #feat:passive-parsing requires one more lookahead
            assert -2 == i
            return buffer[1]

        def __len__(self):
            return len(buffer)  # USE CAUTION

    def buffer_next():  # maintain two components of lookahead except when empty
        res = buffer[0]  # assume buffer not empty
        leng = len(buffer)
        if 2 == leng:
            buffer[0] = buffer[1]
            formal = next_formal()
            if formal:
                buffer[1] = formal
            else:
                buffer.pop()
        else:
            assert 1 == leng
            buffer.pop()
        return res

    def buffer_empty():
        return 0 == len(buffer)

    def next_formal():
        return next(formals, None)

    def buffer():
        if not (formal := next_formal()):
            return
        yield formal
        if not (formal := next_formal()):
            return
        yield formal
    buffer = list(buffer())
    return LazyFormalStack()


def _each_next_formal(add_nonpos_to_cloud, parse_tree, sexps):
    """See [#608.18] "The order in which term types are processed".
    The FSA below started life as a [#608.17] design in GraphViz. At that
    time, it seemed like a superfluous amount of code would be required to
    manage all the noisiness of boring and numerous transitions; so instead
    we proscribed the required order of term types "by hand" with a
    "formal formal" stack. Then at #history-C.2 we opted to go with the
    classic state machine you see here; mainly because of how familiar it is
    """

    # States & transitions

    def from_beginning_state():
        yield if_for_interactive, passthru, from_after_for_interactive

    def from_after_for_interactive():
        yield if_subcommand, expand_subcommand, from_after_subcommand
        yield if_nonpositional, do_add_nonpos_to_cloud, from_after_nonpos  # #here15
        yield if_positional, expand_positional, from_after_positional
        yield if_end, ok_you_ended, None

    def from_after_subcommand():
        yield if_subcommand, expand_subcommand
        yield if_nonpositional, do_add_nonpos_to_cloud, from_after_nonpos
        yield if_positional, expand_positional, from_after_positional
        yield if_end, ok_you_ended, None

    def from_after_nonpos():
        yield if_nonpositional, do_add_nonpos_to_cloud
        yield if_positional, expand_positional, from_after_positional
        yield if_end, ok_you_ended, None

    def from_after_positional():
        yield if_positional, expand_positional
        yield if_end, ok_you_ended, None

    # Actions

    def ok_you_ended():
        None

    def expand_positional():
        formal = _Positional(sx)
        if formal.is_glob:
            check_positioning_of_glob(formal)
            state.seen_glob = True
        elif 'required_positional' == (typ := formal.formal_type):
            check_positioning_of_reqpos()
        elif 'optional_positional' == typ:
            state.seen_optpos = True
        elif 'stop_parsing' == typ:
            check_positioning_of_stop()
            state.seen_stop = True
        else:
            xx(typ)
        state.last_positional = formal
        return (formal,)

    def check_positioning_of_stop():
        # The stop can be at the very beginning (Case5950)
        if from_after_for_interactive == state.state_function:
            return
        # If not at beginning, it must be after a positional
        if from_after_positional != state.state_function:
            raise ParseParseError_("stop must be at beginning or after positional")
        if state.last_positional.is_glob:
            raise ParseParseError_("stop cannot come after glob")
        if 'required_positional' != state.last_positional.formal_type:
            raise ParseParseError_("stop must come after `required_positional`")
        # (below it is asserted that no terms come after a stop)

    def check_positioning_of_glob(formal):
        if 'optional_glob' == formal.formal_type:
            return
        if not state.seen_optpos:
            return
        raise ParseParseError_("required glob can't follow optional positional")

    def check_positioning_of_reqpos():
        if not state.seen_optpos:
            return
        raise ParseParseError_("required positional after optional positional")

    def do_add_nonpos_to_cloud():
        add_nonpos_to_cloud(sx)  # add raw sexp here. expanded at #here4
        # (because return None, immediately procede to each next nonpos)

    def expand_subcommand():
        return (_expand_subcommand(parse_tree, sx),)

    def passthru():
        return (sx,)

    # Matchers

    def if_end():
        return not sx

    def if_positional():
        if not sx:
            return False
        typ = sx[0]
        if 'required_positional' == typ:
            return True
        if 'optional_positional' == typ:
            return True
        if 'required_glob' == typ:
            return True
        if 'optional_glob' == typ:
            return True
        if 'stop_parsing' == typ:
            return True  # #EXPERIMENTAL

    def if_nonpositional():
        if not sx:
            return False
        return sx[0] in ('flag', 'optional_nonpositional')

    def if_subcommand():
        if not sx:
            return False
        return 'subcommand' == sx[0]

    def if_for_interactive():
        return 'for_interactive' == sx[0]

    state = from_beginning_state  # #watch-the-world-burn
    state.seen_stop = state.seen_glob = state.seen_optpos = False
    state.last_positional = None
    state.state_function = from_beginning_state

    sx = True
    while sx:
        sx = next(sexps, None)
        if state.seen_glob and sx:
            raise ParseParseError_("cannot have terms after glob")
        if state.seen_stop and sx:
            raise ParseParseError_("cannot have terms after stop")
        yes = False
        for two_or_three in state.state_function():
            yes = two_or_three[0]()
            if yes:
                break
        if not yes:
            raise ParseParseError_(_explain_no_transition(sx, state))
        stack = list(reversed(two_or_three[1:]))
        action = stack.pop()
        yield_these = action()
        if yield_these:
            for formal in yield_these:
                yield formal
        if len(stack):
            next_state_func, = stack
            state.state_function = next_state_func


def _explain_no_transition(sx, state):
    what = sx[0] if sx else "end of syntax"
    from_where = state.state_function.__name__.replace('_', ' ')
    return f"Can't process {what} {from_where}"



""":#here15: if it just stayed in state it would be amazing & weird"""


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

    def normalize(token):  # #here9
        assert literal_value == token
        parse_tree.subcommands.append(literal_value)

    return _Positional(('required_positional', None,
            ('value_constraint', constrain),
            ('value_normalizer', normalize),
            ('familiar_name_function', familiar_name)))


class _Positional:  # #here5
    def __init__(self, sx):
        stack = list(reversed(sx))
        typ = stack.pop()
        if typ in ('required_positional', 'optional_positional'):
            pass
        elif typ in ('optional_glob', 'required_glob'):
            self.is_glob = True
        elif 'stop_parsing' == typ:
            pass  # #here16
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
    can_accept_dash_as_value = False


_write_positional_property = _generic_registry()  # #here6
_write_positional_property('value_constraint')(_write_value_constraint)
_write_positional_property('value_normalizer')(_write_value_normalizer)
_write_positional_property('familiar_name_function')(_monadic_writer('familiar_name_function'))


@_write_positional_property('can_accept_dash_as_value')
def _become_dash_accepting(formal):
    formal.can_accept_dash_as_value = True


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
_write_nonpos_property('can_accept_dash_as_value')(_become_dash_accepting)



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
        do_consume_head_token:bool = True

    from collections import namedtuple
    return namedtuple('result', tuple(these.keys()))(**these)


def _finish_parse_tree(pt, do_consume_head_token):
    if pt.subcommands:
        pt.subcommands = tuple(pt.subcommands)
    pt.do_consume_head_token = do_consume_head_token
    return pt


""" :#here6: this is the centerpiece of XX but XX
"""


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


class ParseParseError_(RuntimeError):
    pass


def xx(s='here'):
    raise _exe('cover me: {}'.format(s))


_exe = RuntimeError


# -- CONSTANTS

GENERIC_ERROR = 2
SUCCESS = 0


_eol = '\n'

"""#history-A.4 description (moved in file): the now gone OPEN_UPSTREAM shrunk
to tiny, re-written for API change. Also sunsetted a whole redundant module.
"""

# #history-C.2: refactor to just-in-time parse-parsing
# #history-C.1: begin "engines of creation" CLI
# #history-B.4
# #history-A.5
# #history-A.4
# #history-A.3: "cheap arg parse" moves to dedicated file
# #history-A.1: as referenced
# #born: abstracted
