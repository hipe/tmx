def web_app_as_CLI_EXPERIMENTAL(
        sin, sout, serr, argv,
        consume_params_for_matcher_call):

    """One of the many experimental avenues of "app flow" is: How painful will
    it be to conceive of a web app as simply a CLI that outputs html?

    This particular function is EXPERIMENTAL because have no idea (or even plan)
    yet of what the interface should be for this function in terms of its
    formal arguments.
    """

    stack = list(reversed(argv))
    program_name = stack.pop()

    def main():
        # Parse the CLI into fparams and bparams (framework p. and business p.)
        parse_tree = _parse_argv(stack, listener)
        if not parse_tree:
            raise _Stop()

        # Consume those parts of the fparams needed to resolve the endpoint func
        resp = consume_params_for_matcher_call(parse_tree, listener)

        if not resp.OK:
            sout.write(f"{resp.message}\n")  # EXPERIMENTAL
            return resp.some_returncode % 256  # we can't

        if not resp.had_trailing_slash:
            xx('we want to correct these somehow')

        parse_tree.url_pattern_values = resp.parse_tree  # abuse. ick/meh

        endpoint_func, = resp.route_associated_value  # [#891.B] func is wrapped

        # Use the endpoint function's docstring-based signature to parse params
        from script_lib.docstring_based_command import \
                command_of_function as func
        command = func(endpoint_func)  # :[#891.C]
        terms = _scanner_via_iter(command.to_formal_arguments())
        del command

        # Every endpoint function takes at least these
        args = [sout, serr]

        # For each next "normal" term, you must resolve it somehow
        if terms.more:
            resolvers = build_resolvers_scanner()

        while terms.more and not terms.peek.is_glob:
            # We're pop off each next remaining resolver until we find one
            while True:
                if resolvers.empty:
                    xx("as the prophecy foretold. unexpected here: {terms.peek.label!r}")

                if resolvers.peek[0] == terms.peek.label:
                    break

                resolvers.advance()

            # If you got here, you have a lineup with term and resolver
            term = terms.next()
            _, resolver_func = resolvers.next()
            args.append(resolver_func(parse_tree))

        if terms.more:
            assert terms.peek.is_glob
            glob_term = terms.next()
            assert terms.empty  # can't have '*FOO *FOO' in syntax

            # There is magic here - not matter what the syntax calls it,
            # it's the form args (bparams)
            form_args = parse_tree.bparams
            parse_tree.bparams = None
            args.append(form_args)

        # We should have unloaded everything now
        if parse_tree.bparams:
            xx('bparams were passed but not consumed by endpoint function')

        if parse_tree.url_pattern_values:
            xx('the url had pattern matchers not consumed by the endpoint func')

        parse_tree.fparams.pop('collection', None)  # if not already consumed
        if parse_tree.fparams:
            xx('not sure this is bad - ununsed fparams')

        return endpoint_func(*args)  # you should be proud

    def build_resolvers_scanner():
        return _scanner_via_iter(each_term_resolver_pair())

    def each_term_resolver_pair():
        yield 'RECFILE', resolve_recfile
        yield 'EID', resolve_EID

    def resolve_EID(parse_tree):
        return parse_tree.url_pattern_values.pop('EID')

    def resolve_recfile(parse_tree):
        return parse_tree.fparams.pop('collection')  # note label change

    listener = _build_stateful_listener(serr)

    rc = None
    try:
        rc = main()
    except _Stop:
        pass

    return listener.returncode if rc is None else rc


def _parse_argv(stack, listener):

    formal_fparams = {
        'url': 'required',
        'http_method': 'required',
        'collection': 'optional',
    }

    def main():

        # Break the stream of tokens up into 'fparams' and 'bparams'
        parse_tokens()

        # Make sure fparam names are recognized, do existential constraints
        validate_fparams()

        actual_fparams = {k: v for k,v in do_actual_fparams()}

        from dataclasses import dataclass
        @dataclass
        class Result:
            fparams: dict
            bparams: dict

            def __iter__(self):
                return iter((self.fparams, self.bparams))

        return Result(
                fparams=actual_fparams,
                bparams=parse_tokens.bparams)

    def do_actual_fparams():
        provided = parse_tokens.fparams
        for k, existential_constraint in formal_fparams.items():
            if 'required' == existential_constraint:
                provided_value = provided[k]
                assert provided_value is not None
            else:
                assert 'optional' == existential_constraint
                if k in provided:
                    provided_value = provided[k]
                else:
                    continue
            yield k, provided_value

    def validate_fparams():
        required_pool = build_required_pool()
        unrecognized_keys = None

        for unsanitized_k, unsanitized_v in parse_tokens.fparams.items():
            existential_constraint = formal_fparams.get(unsanitized_k)
            if existential_constraint is None:
                if unrecognized_keys:
                    unrecognized_keys.append(unsanitized_k)
                else:
                    unrecognized_keys = [unsanitized_k]
                continue
            if 'required' == existential_constraint:
                required_pool.pop(unsanitized_k)  # guaranteed unique because..
                continue
            assert 'optional' == existential_constraint

        if unrecognized_keys:
            raise stop(_when_unrecognized_fparams, unrecognized_keys)
        if required_pool:
            raise stop(_when_missing_required_fparams, required_pool.keys())

    def build_required_pool():
        return {k: None for k in do_build_required_pool()}

    def do_build_required_pool():
        for k, existential_constraint in formal_fparams.items():
            if 'required' == existential_constraint:
                yield k
                continue
            assert 'optional' == existential_constraint

    def parse_tokens():
        for k, v in _parse_tokens(stack, listener):
            setattr(parse_tokens, k, v)

    def stop(emitter_func, *emitter_func_args):
        emitter_func(listener, *emitter_func_args)
        raise _Stop()


    state = main  # #watch-the-world-burn
    try:
        return main()
    except _Stop:
        pass


def _parse_tokens(stack, listener):

    def from_beginning_state():
        yield if_fparam, handle_fparam
        yield if_bparams, pass_over_bparams_token, from_bparams

    def from_bparams():
        yield always_true, handle_bparam

    # == Actions

    def handle_bparam():
        add_parameter_name_and_value_to_dictionary(bparams)

    def pass_over_bparams_token():
        assert 'bparams' == stack.pop()

    def handle_fparam():
        add_parameter_name_and_value_to_dictionary(fparams)

    # == Action support

    def add_parameter_name_and_value_to_dictionary(dct):
        param_name, param_value = split_on_equals()
        if param_name in dct:
            xx('clobber')
        dct[param_name] = param_value
        stack.pop()

    def split_on_equals():
        eql_pos = current_token.find('=', pos+1)
        # (NOTE the fact that this works when pos is -1 is purely a fluke)

        if -1 == eql_pos:
            xx(f'expecting equals sign somewhere in token: {current_token!r}')
        return current_token[pos+1:eql_pos], current_token[eql_pos+1:]

    # == Matchers

    def if_bparams():
        return 'bparams' == current_token

    def if_fparam():
        return 'fparam' == token_prefix

    def always_true():
        return True

    state = from_beginning_state  # #watch-the-world-burn
    state.current_state_function = from_beginning_state

    fparams = {}
    bparams = {}

    def find_transition():
        for tup in state.current_state_function():
            if 3 == len(tup):
                matcher, action, next_state_func = tup
            else:
                matcher, action = tup
                next_state_func = None
            yes = matcher()
            if yes:
                return action, next_state_func
        _when_no_FSA_transition(
                listener, state.current_state_function.__name__,
                token_prefix, current_token)
        raise _Stop()

    while len(stack):
        current_token = stack[-1]
        pos = current_token.find(':')
        if -1 == pos:
            token_prefix = None
        else:
            token_prefix = current_token[:pos]
        action, next_state_func = find_transition()
        if action:
            action()
        if next_state_func:
            state.current_state_function = next_state_func

    yield 'fparams', fparams
    yield 'bparams', (bparams if bparams else None)


def _when_missing_required_fparams(listener, keys):
    def lines():
        yield f'missing required fparam(s): {tuple(keys)!r}'
    listener('error', 'expression', 'missing_required_fparams', lines)


def _when_unrecognized_fparams(listener, keys):
    def lines():
        yield f'unrecognized fparam(s): {tuple(keys)!r}'
    listener('error', 'expression', 'unrecognized_fparams', lines)


def _when_no_FSA_transition(listener, state_func_name, token_prefix, token):
    def lines():
        head_string = head()
        from_where = state_func_name.replace('_', ' ')
        yield f'{head_string} {from_where}'

    def head():
        if token_prefix:
            return f'Unrecognized or unexpected prefix {token_prefix!r}'
        return f'Unrecognizable token {token!r}'

    listener('error', 'expression', 'cannot_parse_token', lines)


def _build_stateful_listener(serr):
    """(Throw a stop as soon as someone emits an error)
    (Eventually this should emit a 500 error or w/e but why)
    """

    def listener(severity, shape, *rest):
        assert 'expression' == shape
        lines = tuple(rest[-1]())
        for line in lines:
            if 0 == len(line) or '\n' != line[-1]:
                line = f'{line}\n'
            serr.write(line)
        if 'error' != severity:
            return
        if 0 == listener.returncode:
            listener.returncode = 123
        raise _Stop()
    listener.returncode = 0
    return listener


def _scanner_via_iter(itr):  # exists elsewhere too
    class Scanner:
        def next(self):
            item = self.peek
            self.advance()
            return item

        def advance(self):
            item = next(itr, None)
            if item:
                self.peek = item
                return
            del self.peek
            self.more = False

        @property
        def empty(self):
            return not self.more

    scn = Scanner()
    scn.peek = None
    scn.more = True
    scn.advance()
    return scn


class _Stop(RuntimeError):
    pass

# #history-C.1 receive exodus of frameworky code from first client
# #abstracted
