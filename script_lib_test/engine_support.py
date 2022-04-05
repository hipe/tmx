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
        return pay

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
        return build_sequence(
            for_interactive=self.formal_is_for_interactive,
            positionals=self.positionals,
            nonpositionals=self.nonpositionals,
            subcommands=self.subcommands)

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
        for token in self.argv_tail:
            resp = engine.receive_input_event('head_token', token)
            if resp:
                self.last_token = token
                return resp
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
    do_debug = True


# == BEGIN there will be duplication with a frontend, but it's out of scope

def build_sequence(
        for_interactive=None,
        positionals=None,
        nonpositionals=None,
        subcommands=None):

    nonpositionals = _expand_nonpositionals(nonpositionals)
    positionals = _expand_positionals(positionals)

    return subject_module().SEQUENCE_VIA(
            for_interactive=for_interactive,
            positionals=positionals,
            nonpositionals=nonpositionals,
            subcommands=subcommands)


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
        yield ('can_accept_dash_as_value',)
        yield 'value_constraint', _arg_must_be_dash

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
        md = rx.match(shorthand)
        assert md
        return tuple(components_via(md))

    def components_via(md):
        if md['open_square']:
            assert md['close_sq']
            state.seen_optional_positional = True
            yield 'optional_positional'
        else:
            assert not state.seen_optional_positional  # out of scope
            yield 'required_positional'
        yield md['shout']  # familiar_name

    import re
    rx = re.compile(
        r'^(?P<open_square>\[)?(?P<shout>[A-Z0-9_]+)(?P<close_sq>\])?$')

    state = components_via  # #watch-the-world-burn
    state.seen_optional_positional = False
    return positional_via


def _arg_must_be_dash(token):
    if '-' == token:
        return
    def explain():
        yield 'early_stop_reason', 'must_be_dash'
        yield 'returncode', 99
    return 'early_stop', explain


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

# #abstracted
