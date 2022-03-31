r"""
Yet another XX overhaul, simple powerful XX

Many experiments
Synthesize all the objectives of all our CLI efforts that came before it

The New Theory (and some old stuff):

- We can make a frontend/backend separation: The backend does the actual
  parsing of an ARGV using an abstract representation of the grammar; the
  various frontends parse representations of the grammars (or otherwise derive
  them) to produce those abstract representations.
  It's a useful separation because we can compartmentalize our development
  efforts into steps and modularity: We can focus on what our parsers are
  capable of doing separate from focusing all the different ways we want to
  represent and derive syntaxes. Every time we come up with a cool new way to
  make grammars, we won't have to scrap the engine.
- All CLI's we will care to model, we can model syntactically as:
- an ALTERNATION of SEQUENCEs. By "alternation" we mean "this or this or this.."
  It won't make sense how we use ALTERNATION until after we explain SEQUENCEs.
- each SEQUENCE (specifically modeled for our practical CLI use-cases) has
  four parts: "for_interactive", "sub_commands", "nonpositionals", "positionals"
  - "for_interactive": Whether this sequence is intended to parse from an
    interactive terminal. The possible answers are True (yes), False (no), or
    None (ignore the interactive-ness of the terminal). A value of False
    indicates the generated parser is intended to consume only input piped in
    thru STDIN (and will fail, explaining it to the user when it is not) etc.
  - Zero or more SUBCOMMAND literals. Unlike our predecessor, we have
    a unified API, regardless of whether you're parsing from a "branch node"
    or "leaf node." We may decide to make SUBCOMMAND literals a special
    case of required_positional. More below.
  - a "floating cloud" of zero or more "nonpositionals". More below.
  - a sequence of zero or more formal positional parameters:
    - this sequence is zero or more `required_positional` formal parameters
      FOLLOWED BY zero or more `optional_positional` formal parameters. more below
- "optional_positionals" detail: The fact that optional positionals must follow
  required positionals, it is not set in stone; but for now we hard-code it
  this way in the spirit of keeping it simple, because it seems most idiomatic
  to the syntaxes we've seen in the real world (avoiding false requirements)
- introducing "nonpositionals": We call all other formal parameters that are
  not positionals "nonpositionals". Right now this includes only two kinds of
  formal parameters: the "flag" and the "optional_nonpositional".

                             CLI formal parameters
                            /                    \
                           /                      \
                     positional               nonpositional
                      /     \                     /   \
                     /       \                   /     \
    required_positional  optional_positional   flag  optional_nonpositional

- (Yes, "optional_nonpositional" is a mouthful of a name to have for perhaps
  the commonmost type of formal parameter to have in a CLI, but we want a
  name that is unambigous and fits in with the larger naming scheme.
  "flag" is too strong an idiom to give it any other name.)
- "value is optional" options not supported: Other generators in the world
  generate parsers that allow options that take but do not require a value
  (through use of an equal sign). We will not (for the time being) support
  this variability: Either the option is a flag or it *does yes* take a
  value. We find the feature superflous but we want to allow room to include
  it later if we are convinced to.
- We may want to support "required_nonpositionals" one day. But not now.
- SUBCOMMANDs: this is simply a sequence of zero or more string literals
  that must exist (in that sequence) in the actual parameters from that point
  in the input. This feature isn't interesting unless you combine it with
  ALTERNATION: if you have an an ALTERNATION of various SEQUENCEs, each with
  their own subcommands, then you have what we used to call a "branch node"
  that dispatches commands out to various endpoints.
- Fuzzy matching of SUBCOMMAND name is not yet a feature but we want to
  allow for it.
- The "floating cloud" nonpositionals and hot-swappable grammar: XX currently
  and in future frontends we require that you represent your grammar in a
  way where all formal nonpositionals are grouped together (either in front of
  or behind all positionals).
  It would be semi-trivial and fun to generate parsers that XX
- Hot-swappable, live-loading of grammar components XX
"""

"""Implementation:

- Every grammar is an ALTERNATION of {AT LEAST ONE} SEQUENCE.
- We call the act of parsing a particular ARGV input against our grammar
  an INVOCATION.
- for an INVOCATION, from each SEQUENCE we derive an FSA (finite state
  automaton). Details of the states of this FSA will be divulged below; but
  one thing this FSA does is it "points at" which formal positional parameter
  (if any) is expected/allowed next. (The way positional parameters are
  processed is more state-machine-ey than how nonpositionals are parsed;
  but also there is need for state with nonpositionals: consider
  the optional_nonpositional in the state when the value is expected.)
- (parallel universe)
- We implement parsing by issuing a series of two or more "events" to the
  FSA's in THE RUNNING. For now, we keep the response API simple: the FSA
  indicates whether it ACCEPTs or FAIL_TO_ACCEPTs the event with a simple
  True or False response from its RECEIVE_INPUT_EVENT method.
  More below about what we do based on various patterns of the FSAs
  in the THE_RUNNING accepting or failing to accept each next input event.
- The "at least two events" are the IS_INTERACTIVE of the terminal,
  and the END_OF_TOKENS event. For the first, FSA's that don't care about
  the interactive-ness should return True (they accept). The END_OF_TOKENS
  event will be the time where FSA's whose grammars have required_positional
  will determine if a required_positional is being pointed at
- At each step after the input event has been distributed out to every FSA
  in the running and we have their responses, the set of their responses falls
  into one of these N groups:
  1. some accepted: zero or more FAIL_TO_ACCEPTed, but one more more ACCEPTed
  2. none accepted: all FAIL_TO_ACCEPTed
  We discuss what to do in these two cases in the next two points.
- When some accepted, we take those FSA's that FAIL_TO_ACCEPTed *out* of
  THE_RUNNING. We do not need to keep them for any future possible
  error-reporting; we are just focusing on the FSA's still in the running.
- Each FSA must be able to express what it is expecting. When none ACCEPTed
  the input event, we will express this as a "parse failure" condition.
  Each FSA in the running (they all FAIL_TO_ACCEPTed) will be again shown
  the input event (either IS_INTERACTIVE, HEAD_TOKEN or END_OF_TOKENS) and
  they must return some sort of structured representation of what they were
  expecting.
  - When failing against the IS_INTERACTIVE event, the failure to accept
    must be because they expected (required) the inverse of the boolean value.
    (They required interactive but it was not, or the opposite).
  - Failing to accept at END_OF_TOKENS will always (as far as we can imagine
    at this writing) be either:
    - required_positional expected (is being "pointed at") OR
    - optional_nonpositional requires a value
  - Failing to accept a HEAD_TOKEN, we anticipate it's these N cases:
    - token is OPTION_LOOKING (starts with dash) but doesn't match
      against the FLOATING_CLOUD_OF_NONPOSITIONALS.
    - token does _not_ look like an option (does not start with a dash),
      may have failed either because:
        - no more positional arguments are being accepted from the FSA in
          its current state ("pointing at" the end)
        - the formal positional being pointed at is a string literal
          (SUBCOMMAND) and the argument token does not equal it.
    - perhaps there's a response from a custom handler indicating to exit now
  For failure of an OPTION_LOOKING token against the FLOATING_CLOUD, at present
  we will just fail with a generic failure ("unrecognized option '--foo'")
  but it's conceivable that in the future we will want to do a fuzzy match
  type traversal for suggestions ("did you mean '--foz' or '--flu'?"). For
  this generic failure against an OPTION_LOOKING HEAD_TOKEN, the
  STRUCTURED_FAILURE_EXPLANATION may be a generic singleton value..
- Another interesting error condition we may encounter is ambiguity in which
  FSA to use if more than one are still in THE_RUNNING by the END_OF_TOKENS
  event. In real life, grammars are never made with such ambiguity in them
  (just as it works out) so this is a failure state we won't spent a lot of
  time making very pretty.
- Things we're not focusing on at the moment because they're not interesting:
  - short
  - BSD-style primaries (i.e., long options with a single dash)
"""


import unittest


class CommonCase(unittest.TestCase):

    def expect_success(self):
        expl, ast = self.execute()
        if expl:
            if self.do_debug:
                eek = tuple(expl())
                print(f"\n\nDEBUG: wasn't expecting: {eek!r}\n\n")
                print(f"(token was: {self.last_token!r})")
            assert False
        return ast

    def expect_stop_early(self, *reason_tail):
        expl, ast = self.execute()
        assert ast is None
        kwargs = {}
        set_item = kwargs.__setitem__
        handle = {
            'returncode': set_item,
            'stderr_line': lambda k, line: stderr_lines.append(line),
            'stop_early_reason': lambda k, *rest: set_item(k, rest),
        }
        stderr_lines = []
        for k, *rest in expl():
            handle[k](k, *rest)
        kwargs['stderr_lines'] = (tuple(stderr_lines) if stderr_lines else None)
        res = early_stop_class()(**kwargs)
        self.assertSequenceEqual(reason_tail, res.stop_early_reason)
        return res

    def execute(self):
        # stderr, lines = self.build_stderr_spy()
        use_positionals = tuple(self.expand_positionals())
        use_nonpositionals = tuple(self.expand_nonpositionals())
        engine = subject_function()(
            for_interactive=self.formal_is_for_interactive,
            positionals=use_positionals,
            nonpositionals=use_nonpositionals,
            subcommands=self.subcommands)
        expl = engine.receive_input_event('is_interactive', self.terminal_is_interactive)
        assert expl is None
        for token in self.argv_tail:
            yes = len(token) and '-' == token[0]
            typ = 'looks_like_option' if yes else 'looks_like_non_option'
            expl = engine.receive_input_event('head_token', typ, token)
            if expl:
                self.last_token = typ, token
                return expl, None
        return engine.receive_input_event('end_of_tokens')

    def expand_positionals(self):
        if not (shorthands := self.positionals):
            return
        import re
        rx = re.compile(
            r'^(?P<open_square>\[)?(?P<shout>[A-Z0-9_]+)(?P<close_sq>\])?$')
        use_pos = []
        seen_optional_positional = False
        for shorthand in shorthands:
            md = rx.match(shorthand)
            assert md
            if md['open_square']:
                assert md['close_sq']
                seen_optional_positional = True
                which = 'optional_positional'
            else:
                assert not seen_optional_positional  # out of scope
                which = 'required_positional'
            yield which, md['shout'], md['shout'].lower()

    def expand_nonpositionals(self):
        if not (shorthands := self.nonpositionals):
            return
        import re
        rx = re.compile(
            '^(?P<surface_name>--'
            '(?P<slug>[a-z]+(?:-[a-z]+)*))'
            '(?:=(?P<arg_name>[A-Z0-9_]+)'
            ')?'
            '$')
        pcs = []
        for shorthand in shorthands:
            md = rx.match(shorthand)
            assert md

            if (arg_name := md['arg_name']):
                _1st_term = 'optional_nonpositional'
            else:
                _1st_term = 'flag'

            pcs.append(_1st_term)
            pcs.append(md['surface_name'])
            pcs.append(md['slug'].replace('-', '_'))
            pcs.append('has_second_dash')
            if arg_name:
                pcs.append(arg_name)
            yield tuple(pcs)
            pcs.clear()

    def build_stderr_spy(self):
        from script_lib.test_support.expect_STDs import \
                spy_on_write_and_lines_for as spy_for
        return spy_for(self, 'DBG SERR: ')

    terminal_is_interactive = True
    formal_is_for_interactive = None
    nonpositionals = None
    positionals = None
    subcommands = None
    do_debug = True


class Case5230_empty_grammar_against_no_tokens(CommonCase):

    def test_010_ohai(self):
        self.expect_success()

    argv_tail = ()


class Case5234_empty_grammar_against_one_non_option_looking_token(CommonCase):

    def test_010_ohai(self):
        self.expect_stop_early('unexpected_extra_argument')

    argv_tail = ('foo',)


class Case5238_empty_grammar_against_one_option_looking_token(CommonCase):

    def test_010_ohai(self):
        self.expect_stop_early('unrecognized_option')

    argv_tail = ('--strange',)


class Case5242_strange_short(CommonCase):

    def test_010_ohai(self):
        self.expect_stop_early('unrecognized_short', '-x')

    argv_tail = ('-xfoobie',)


class Case5246_long_help(CommonCase):

    def test_010_ohai(self):
        self.expect_stop_early('display_help')

    argv_tail = ('--help',)


class Case5250_short_help(CommonCase):

    def test_010_ohai(self):
        self.expect_stop_early('display_help')

    argv_tail = ('-h',)


class Case5254_impatient(CommonCase):

    def test_010_fail_to_get_first_subcommand(self):
        self.argv_tail = 'aa', 'bb', 'cc'
        self.expect_stop_early('expecting_subcommand', 'wing')

    def test_020_fail_to_get_second_subcommand(self):
        self.argv_tail = 'wing', 'bb', 'cc'
        self.expect_stop_early('expecting_subcommand', 'chun')

    def test_030_fail_to_get_required_positional(self):
        self.argv_tail = 'wing', 'chun'
        self.expect_stop_early('expecting_required_positional', 'ARG1')

    def test_040_too_many_actual_positionals(self):
        self.argv_tail = 'wing', 'chun', 'arg1_x', 'arg2_y', 'arg3_z', 'arg4_no'
        self.expect_stop_early('unexpected_extra_argument')

    def test_050_big_ball_candy_crush(self):
        self.argv_tail = 'wing', 'chun', '--verbo', 'a1', '-vfzig.txt', 'a2'
        pt = self.expect_success()
        self.assertSequenceEqual(('wing', 'chun'), pt.subcommands)
        dct = pt.values
        val = dct.pop
        assert val('arg1') == 'a1'
        assert val('arg2') == 'a2'
        assert val('verbose') is True
        assert val('file') == 'zig.txt'
        assert not dct

    def test_060_but_ruin_it_at_end(self):
        self.argv_tail = 'wing', 'chun', '--verbo', 'a1', '-vfz.txt', 'a2', '-x'
        self.expect_stop_early('unrecognized_short', '-x')

    nonpositionals = '--verbose', '--file=FILE'
    positionals = 'ARG1', '[ARG2]', '[ARG3]'
    subcommands = 'wing', 'chun'
    terminal_is_interactive = False
    formal_is_for_interactive = False


def subject_function():
    from script_lib import THE_ENGINES_OF_CREATION as func
    return func


def early_stop_class():
    memo = early_stop_class
    if memo.value is None:
        from collections import namedtuple
        memo.value = namedtuple(
                'EarlyStop', 'stop_early_reason stderr_lines returncode')
    return memo.value


early_stop_class.value = None


if '__main__' ==  __name__:
    unittest.main()

# #born
