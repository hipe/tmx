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

"""Details (EXPERIMENTAL):
Experimentally, we want the "lingua franca" of our engine to be "sexps"
(XX near that description of dependency injections)

The below pseudocode is an attempt to (comprehensively) XX

    "?" means zero or one. These ones provided in pairs. any order
    "D" means it's a property derived from others (hard-coded for now)

    { required_positional | optional_positional }  # either
    { <familiar_name str> | <familiar_name_function callable>
    ? <value_constraint>
    ? <value_normalizer>
    ? 'glob'  # a tuple of one element, the string 'glob'
    D parse_tree_key

    optional_nonpositional  # and required_nonpositional if we ever do that
    <familiar_name>  # must start with one or two dashes
    <parameter_familiar_name>  # SHOUTCASE or <these>
    ? <value_constraint>
    ? <value_normalizer>
    D parse_tree_key

    flag
    <familiar_name>
    ? <value_normalizer>
    D parse_tree_key

"flag" is the only formal parameter type that doesn't take a value. As such,
it doesn't model a `value_constraint` optional function like the others do.
However, it does allow for a `value_normalizer`, which can change how the
values are written to the parse tree.
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
  (XX In fact it's a litle more complicated: it returns None for ACCEPT,
  and an explanation function for FAIL_TO_ACCEPT.)
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
  (XX in fact..)
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


from script_lib_test import engine_support
import unittest


class CommonCase(engine_support.CommonCase, unittest.TestCase):

    def expect_value_sequence(self, these):
        pt = self.expect_success()
        act = pt.values.get(self.parse_tree_focus_value)
        if these is None:
            assert act is None
            return
        self.assertSequenceEqual(act, these)


class Case5230_empty_grammar_against_no_tokens(CommonCase):

    def test_010_ohai(self):
        self.expect_success()

    argv_tail = ()


class Case5234_empty_grammar_against_one_non_option_looking_token(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('unexpected_extra_argument')

    argv_tail = ('foo',)


class Case5238_empty_grammar_against_one_option_looking_token(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('unrecognized_option')

    argv_tail = ('--strange',)


class Case5242_strange_short(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('unrecognized_short', '-x')

    argv_tail = ('-xfoobie',)


class Case5246_long_help(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('display_help')

    argv_tail = ('--help',)


class Case5250_short_help(CommonCase):

    def test_010_ohai(self):
        self.expect_early_stop('display_help')

    argv_tail = ('-h',)


class Case5254_impatient(CommonCase):

    def test_010_fail_to_get_first_subcommand(self):
        self.argv_tail = 'aa', 'bb', 'cc'
        self.expect_early_stop('expecting_subcommand', 'wing')

    def test_020_fail_to_get_second_subcommand(self):
        self.argv_tail = 'wing', 'bb', 'cc'
        self.expect_early_stop('expecting_subcommand', 'chun')

    def test_030_fail_to_get_required_positional(self):
        self.argv_tail = 'wing', 'chun'
        self.expect_early_stop('expecting_required_positional', 'ARG1')

    def test_040_too_many_actual_positionals(self):
        self.argv_tail = 'wing', 'chun', 'arg1_x', 'arg2_y', 'arg3_z', 'arg4_no'
        self.expect_early_stop('unexpected_extra_argument')

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
        self.expect_early_stop('unrecognized_short', '-x')

    nonpositionals = '--verbose', '--file=FILE'
    positionals = 'ARG1', '[ARG2]', '[ARG3]'
    subcommands = ('subcommand', 'wing'), ('subcommand', 'chun')
    terminal_is_interactive = False
    formal_is_for_interactive = False


class Case5258_introduce_subcommands(CommonCase):

    def test_010_tell_me_expecting(self):
        self.argv_tail = ()
        self.expect_early_stop('expecting_required_positional', '"zingbar"')

    def test_020_tell_me_wrong(self):
        self.argv_tail = ('zongbar',)
        self.expect_early_stop('expecting_subcommand', 'zingbar')

    def test_030_tell_me_expecting_second_MULTIPLE(self):
        self.argv_tail = ('zingbar',)
        self.expect_early_stop('expecting_required_positional', ('"tazo"', '"wazo"'))

    def test_040_tell_me_wrong_second_MULTIPLE(self):
        self.argv_tail = ('zingbar', 'fizo')
        self.expect_early_stop('expecting_subcommand', ('tazo', 'wazo'))

    def test_050_tell_me_RIGHT(self):
        self.argv_tail = ('zingbar', 'tazo')
        pt = self.expect_success()
        self.assertSequenceEqual(('zingbar', 'tazo'), pt.subcommands)

    def build_first_sequence(self):  # (up here for historic reasons only)
        return build_sequence(
            for_interactive=True,
            subcommands=(('subcommand','zingbar'), ('subcommand', 'tazo')),
            nonpositionals=None,
            positionals=None)

    def build_second_sequence(self):
        return build_sequence(
            for_interactive=True,
            subcommands=(('subcommand', 'zingbar'), ('subcommand','wazo')),
            nonpositionals=None,
            positionals=None)


class Case5262_introduce_interactive_vs_not(CommonCase):

    def test_010_term_is_interactive_and_argv_is_nothing(self):
        self.terminal_is_interactive = True
        self.argv_tail = ()
        self.expect_success()

    def test_020_term_is_noninteractive_and_argv_is_nothing(self):
        self.terminal_is_interactive = False
        self.argv_tail = ()
        self.expect_success()

    def test_030_term_is_interactive_and_file_is_dash(self):
        self.terminal_is_interactive = True
        self.argv_tail = '-file', '-'
        self.expect_early_stop('cannot_be_dash')

    def test_040_term_is_interactive_and_file_is_not_dash(self):
        self.terminal_is_interactive = True
        self.argv_tail = '-file', 'foo.txt'
        self.expect_success()

    def test_050_term_is_noninteractive_and_file_is_dash(self):
        self.terminal_is_interactive = False
        self.argv_tail = '-file', '-'
        self.expect_success()

    def test_060_term_is_noniteractive_and_file_is_not_dash(self):
        self.terminal_is_interactive = False
        self.argv_tail = '-file', 'foo.txt'
        self.expect_early_stop('must_be_dash')

    def build_first_sequence(self):  # (up here for historic reasons only)
        return build_sequence(
            for_interactive=True,
            nonpositionals=('-file FILE',))

    def build_second_sequence(self):
        return build_sequence(
            for_interactive=False,
            nonpositionals=('-file -',))


class Case5266_introduce_optional_glob(CommonCase):

    def test_005_none(self):
        self.argv_tail = ()
        self.expect_value_sequence(None)

    def test_010_one(self):
        same = ('val1',)
        self.argv_tail = same
        self.expect_value_sequence(same)

    def test_020_two(self):
        same = 'val1', 'val2'
        self.argv_tail = same
        self.expect_value_sequence(same)

    def test_030_three(self):
        same = 'val1 val2 val3'.split()
        self.argv_tail = same
        self.expect_value_sequence(same)

    positionals = ('[TING [TING [..]]]',)
    parse_tree_focus_value = 'ting'


class Case5270_introduce_required_glob(CommonCase):

    def test_005_none(self):
        self.argv_tail = ()
        self.expect_early_stop('expecting_required_positional', 'TING')

    def test_010_one(self):
        same = ('val1',)
        self.argv_tail = same
        self.expect_value_sequence(same)

    def test_020_two(self):
        same = 'val1', 'val2'
        self.argv_tail = same
        self.expect_value_sequence(same)

    def test_030_three(self):
        same = 'val1 val2 val3'.split()
        self.argv_tail = same
        self.expect_value_sequence(same)

    positionals = ('TING [TING [..]]',)
    parse_tree_focus_value = 'ting'


class Case5274_introduce_stops(CommonCase):

    def test_010_what(self):
        self.argv_tail = 'val1', 'no-parse-1', 'no-parse-2'
        pt = self.expect_success()
        assert 'val1' == pt.values.pop('arg1')
        assert not pt.values
        stack = self.argv_stack
        assert 'val1' == stack.pop()  # not so in frontend integration
        assert 'no-parse-1' == stack.pop()
        assert 'no-parse-2' == stack.pop()
        assert not stack

    positionals = ('ARG1', '[stop ..]')


class Case5278_literal_dash_as_positional(CommonCase):  # sister: Case5952

    def test_010_stores_nothing(self):
        """ it must be so because we can't derive a name from the term """
        self.argv_tail = ('-',)
        pt = self.expect_success()
        assert 0 == len(pt.values)

    def test_020_whines_about_expecting(self):
        self.argv_tail = ()
        wat = self.expect_early_stop('expecting_required_positional', '-')

    positionals = ('-',)
    formal_is_for_interactive = True


build_sequence = engine_support.build_sequence


if '__main__' ==  __name__:
    unittest.main()

# #born
