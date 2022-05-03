"""test support for the "engine" CLI toolkit"""

class CommonCase:

    def expect_success(self):
        resp = self.execute()
        assert resp
        typ, pay = resp
        if 'early_stop' == typ:
            if self.do_debug:
                eek = tuple(pay())
                print(f"\n\nDEBUG: wasn't expecting: {eek!r}\n\n")
                print(f"(token was: {self.last_token!r})")
            assert False
        if 'stop_parsing' == typ:
            return pay
        if 'parse_tree' == typ:
            return pay
        raise RuntimeError(f"? {typ!r}")

    def expect_early_stop(self, *reason_tail):
        resp = self.execute()
        assert resp
        typ, expl = resp
        if 'early_stop' != typ:
            self.fail(f"expected 'early_stop' had {typ!r}")
        kwargs = {}
        set_item = kwargs.__setitem__
        handle = {
            'returncode': set_item,
            'stderr_line': lambda k, line: stderr_lines.append(line),
            'early_stop_reason': lambda k, *rest: set_item(k, rest),
        }
        stderr_lines = []
        # stderr, lines = self.build_stderr_spy()
        for k, *rest in expl():
            handle[k](k, *rest)
        kwargs['stderr_lines'] = (tuple(stderr_lines) if stderr_lines else None)
        res = _early_stop_class()(**kwargs)
        self.assertSequenceEqual(reason_tail, res.early_stop_reason)
        return res

    def build_first_sequence(self):  # (up here for historic reasons only)
        # stderr, lines = self.build_stderr_spy()

        parameter_refinements = self.parameter_refinements
        if parameter_refinements:
            raise RuntimeError("no longer covered but worked once")
            parameter_refinements = parameter_refinements()

        return build_sequence(
            for_interactive=self.formal_is_for_interactive,
            positionals=self.positionals,
            nonpositionals=self.nonpositionals,
            subcommands=self.subcommands,
            parameter_refinements=parameter_refinements)

    def execute(self):
        seqs = tuple(self.build_sequences())
        if 1 == len(seqs):
            engine, = seqs
        else:
            engine = subject_module().ALTERNATION_VIA_SEQUENCES(seqs)

        # Keep going until engine gives any response or you reach the end event
        resp = engine.receive_input_event('is_interactive', self.terminal_is_interactive)
        if resp:
          return resp
        self.last_token = None
        stack = list(reversed(self.argv_tail))
        self.argv_stack = stack
        while len(stack):
            token = stack[-1]
            resp = engine.receive_input_event('head_token', token)
            if resp:
                self.last_token = token
                return resp
            stack.pop()
        return engine.receive_input_event('end_of_tokens')

    def build_sequences(self):
        seq1 = self.build_first_sequence()
        assert seq1
        yield seq1
        seq2 = self.build_second_sequence()
        if not seq2:
            return
        yield seq2
        # ..

    def build_stderr_spy(self):
        from script_lib.test_support.expect_STDs import \
                spy_on_write_and_lines_for as spy_for
        return spy_for(self, 'DBG SERR: ')

    def build_second_sequence(self):
        pass

    terminal_is_interactive = True
    formal_is_for_interactive = None
    nonpositionals = None
    positionals = None
    subcommands = None
    parameter_refinements = None
    do_debug = True


# == BEGIN there will be duplication with a frontend, but it's out of scope

def build_sequence(
        for_interactive=None,
        positionals=None,
        nonpositionals=None,
        subcommands=None,
        parameter_refinements=None):

    nonpositionals = _expand_nonpositionals(nonpositionals)
    positionals = _expand_positionals(positionals)

    return subject_module().SEQUENCE_VIA(
            for_interactive=for_interactive,
            positionals=positionals,
            nonpositionals=nonpositionals,
            subcommands=subcommands,
            parameter_refinements=parameter_refinements)


def _expand_nonpositionals(shorthands):
    if not shorthands:
        return
    build_nonpositional = _nonpositional_builder()
    return tuple(build_nonpositional(s) for s in shorthands)


def _nonpositional_builder():
    memo = _nonpositional_builder
    if memo.value is None:
        memo.value = _build_nonpositional_builder()
    return memo.value


_nonpositional_builder.value = None


def _build_nonpositional_builder():
    def nonpositional_via(shorthand):
        md = rx.match(shorthand)
        assert md
        return tuple(components_via(md))

    def components_via(md):
        arg_name = md['arg_name']
        is_flag = arg_name is None
        if is_flag:
            yield 'flag'
        else:
            yield 'optional_nonpositional'
        yield md['surface_name']  # familiar_name
        if is_flag:
            return
        yield arg_name  # parameter_familiar_name
        if '-' != arg_name:
            return
        yield ('can_accept_dash_as_value',)  # see also #here1
        yield 'value_constraint', _arg_must_be_single_dash

    import re
    rx = re.compile(
        '^(?P<surface_name>-(?P<two_dashes>-)?'
        '(?P<slug>[a-z]+(?:-[a-z]+)*))'
        '(?:[= ](?P<arg_name>-|[A-Z0-9_]+))?'
        '$')
    return nonpositional_via


def _expand_positionals(shorthands):
    if not shorthands:
        return
    build_positional = _build_positional_builder_once_per_grammar()
    return tuple(build_positional(s) for s in shorthands)


def _build_positional_builder_once_per_grammar():
    def positional_via(shorthand):
        # This is an ersatz form of what a frontend probably does
        # (at #history-C.1 got rid of regex-based all-in-one parsing)

        if len(shorthand) < 3:
            if '-' != shorthand:
                raise RuntimeError(f"nothing for this yet: {shorthand!r}")
            return _term_sexp_for_single_dash_reqpos()

        if '[' == shorthand[0]:
            assert ']' == shorthand[-1]
            inside = shorthand[1:-1]
            if re.match('^[A-Z0-9_]+$', inside):
                state.seen_optional_positional = True
                return 'optional_positional', inside
            md = re.match(r'^(?P<shout>[A-Z0-9_]+) \[\1 \[\.\.\]\]$', inside)
            if not md:
                assert '[stop ..]' == shorthand
                return 'stop_parsing', shorthand
            assert md
            assert not state.seen_glob
            state.seen_glob = True
            return 'optional_glob', md['shout']
        if '[' in shorthand:
            md = re.match(r'^(?P<shout>[A-Z0-9_]+) \[\1 \[\.\.\]\]$', shorthand)
            assert md
            assert not state.seen_glob
            state.seen_glob = True
            return 'required_glob', md['shout']
        assert re.match('^[A-Z0-9_]+$', shorthand)
        assert not state.seen_optional_positional  # out of scope
        return 'required_positional', shorthand

    import re
    state = positional_via  # #watch-the-world-burn
    state.seen_optional_positional = False
    state.seen_glob = False
    return positional_via


def _term_sexp_for_single_dash_reqpos():
    def these():
        yield ('can_accept_dash_as_value',)  # see also #here1
        yield 'value_constraint', _arg_must_be_single_dash
        yield 'value_normalizer', _do_nothing_to_store_single_dash
        yield 'familiar_name_function', lambda: '-'
    return 'required_positional', None, *these()


def _arg_must_be_single_dash(token):
    if '-' == token:
        return
    def explain():
        yield 'early_stop_reason', 'must_be_dash_FOR_EXAMPLE'
        yield 'returncode', 99
    return 'early_stop', explain


def _do_nothing_to_store_single_dash(token):
    # we must do nothing, can't derive a good store name from term
    assert '-' == token
    return None


def _early_stop_class():
    memo = _early_stop_class
    if memo.value is None:
        from collections import namedtuple
        memo.value = namedtuple(
                'EarlyStop', 'early_stop_reason stderr_lines returncode')
    return memo.value


_early_stop_class.value = None

# == END


def subject_module():
    import script_lib as mod
    return mod

# #history-C.1 (as referenced)
# #abstracted
