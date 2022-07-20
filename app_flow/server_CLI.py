def parse_argv(stack, listener):

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


class _Stop(RuntimeError):
    pass

# #abstracted
