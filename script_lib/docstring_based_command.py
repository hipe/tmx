# An experimental, even lighter-weight, more DIY alternative
# to "cheap_arg_parse" (abstracted early from a one-off CLI),
#
# (This predated "engine" but only by a little bit)
#
# - More geared towards helping with positional-parameter APIs, not CLI's
# - roll your own arg-parsing at the top level for readability
# - The Command structure is evaluated lazily, only as needed
# - within the Command structure, parsing the docstring is only done lazily

# at #history-C.1 we refactored-out the decorator-based thing

import re


class build_new_decorator:

    def __init__(self):
        self._funcs = {}

    def __call__(self, f):
        f.command = None  # #here2
        self._funcs[f.__name__] = f
        return f

    def get(self, k, alternate_value=None):
        f = self._funcs.get(k)
        if f:
            return _command(f)
        return alternate_value

    def __getitem__(self, k):
        return command_of_function(self._funcs[k])

    def command_keys(self):
        return self._funcs.keys()


def command_of_function(function):
    """(memoize our "Command" structure into the user function itself #here2)"""

    memo = function
    cmd = memo.command
    if cmd:
        return cmd
    cmd = _command_via_function(function)
    memo.command = cmd
    return cmd


class _command_via_function:

    def __init__(self, function):
        self.function = function
        self._did_parse_syntax = False

    def to_formal_arguments(self):
        return _formal_arguments_via_usage_line(
                self._first_line_of_docstring_no_newline)

    @property
    def single_line_description(self):
        scn = self._to_docstring_line_scanner()
        scn.advance()
        scn.advance()
        line = scn.current_line
        md = re.match('^[dD]escription:[ ](?P<the_rest>.+)', line)
        if not md:
            xx(f"line must say 'description:' - {line!r}")
        return md['the_rest']

    def build_doc_lines(self, prog_name):
        big_s = self._doc_string
        pos = big_s.index('\n')
        first = big_s[0:pos+1]
        rest = big_s[pos+1:]
        dedented = rest.replace('\n    ', '\n')
        lines = re.split(re.compile('^', re.MULTILINE), dedented)
        assert '' == lines[0]
        assert '' == lines[-1]
        lines = [first, *lines[1:-1]]
        fname = self._name
        lines[0] = lines[0].replace('{prog_name}', f'{prog_name} {fname}')
        return lines

    def validate_positionals(self, stderr, stack, prog_namer):
        act_len = len(stack)
        formal_len = self._formal_leng
        if act_len == formal_len:
            return 0
        _1 = self._name
        if act_len < formal_len:
            _2 = self._formal_positional_args[act_len]
            stderr.write(f"Not enough arguments for {_1!r}. Expecting {_2!r}\n")
        else:
            assert act_len > formal_len
            _2 = stack[-(formal_len+1)]
            stderr.write(f"Unexpected extra argument for {_1!r}: {_2!r}\n")
        return 3

    @property
    def _first_line_of_docstring_no_newline(self):
        big_s = self._doc_string
        offset = big_s.find('\n')
        if -1 == offset:
            return big_s
        return big_s[0:offset]

    def _to_docstring_line_scanner(self):
        return _docstring_line_scanner(self._doc_string)

    @property
    def _doc_string(self):
        return self.function.__doc__

    @property
    def _name(self):
        return self.function.__name__


def _formal_arguments_via_usage_line(usage_string):  # #testpoint
    """this is for this shady syntax syntax used in one place"""

    def from_beginning_state():
        yield if_required_head_string, advance_past_head, from_main_state

    def from_main_state():
        yield if_normal_token, yield_normal_token_and_advance
        yield if_glob_token, yield_glob_token_and_assert_empty

    # == Actions

    def yield_glob_token_and_assert_empty():
        label = release_matchdata_and_advance_over_it()[1]
        if state.pos != leng:
            xx(f"expected end had {usage_string[state.pos:]!r}")
        return _Positional(label, is_glob=True)

    def yield_normal_token_and_advance():
        label = release_matchdata_and_advance_over_it()[1]
        return _Positional(label)

    def release_matchdata_and_advance_over_it():
        md = state.last_matchdata
        del state.last_matchdata
        state.pos = md.end()
        return md

    def advance_past_head():
        state.pos = len(required_head_string)

    # == Matchers

    def if_glob_token():
        return match(rx_glob_token)

    def if_normal_token():
        return match(rx_normal_token)

    def match(rx):
        md = rx.match(usage_string, state.pos)
        state.last_matchdata = md
        return True if md else False

    def if_required_head_string():
        return 0 == usage_string.find(required_head_string)

    state = from_beginning_state  # #watch-the-world-burn
    state.current_state_function = from_beginning_state

    leng = len(usage_string)

    same = '[A-Z0-9_]+'
    rx_normal_token = re.compile(f'[ ]({same})\\b')
    rx_glob_token = re.compile(f'[ ]\\*({same})\\b')

    required_head_string = 'usage: {prog_name}'

    def find_transition():
        for tup in state.current_state_function():
            yn = tup[0]()
            if yn:
                return tup[1:] if 3 == len(tup) else (*tup[1:], None)
        from_here = state.current_state_function.__name__.replace('_', ' ')
        the_rest = usage_string[state.pos:]
        xx(f"no transition {from_here} with rest: {the_rest!r}")

    state.pos = 0
    while state.pos != leng:
        action, next_state_func = find_transition()
        yield_me = action()
        if yield_me:
            yield yield_me
        if next_state_func:
            state.current_state_function = next_state_func


class _Positional:

    def __init__(self, label, is_glob=False):
        self.label = label
        self.is_glob = is_glob


def _docstring_line_scanner(big_s):  # custom just to avoid deps
    itr = _docstring_iterator(big_s)
    reader = next(itr)

    class Scanner:
        def __init__(self):
            self.empty, self.more = False, True  # assume #here1

        @property
        def current_line(self):  # like `peek`
            if self.empty:
                return
            line = big_s[reader.begin:reader.end]
            if reader.do_deindent_line and '\n' != line:
                i = next(i for i in range(0, len(line)) if line[i] != ' ')
                return line[i:]
            return line

        def advance(self):
            yn = next(itr)
            if yn:
                return
            self.empty, self.more = True, False

    scn = Scanner()
    scn.advance()
    return scn


def _docstring_iterator(big_s):
    leng = len(big_s)
    countdown = 2  # the first two lines are not deindented lol
    pos = 0
    end = None

    class Reader:
        @property
        def do_deindent_line(self):
            return not countdown

        @property
        def begin(self):
            return pos

        @property
        def end(self):
            return end

    yield Reader()
    while pos != leng:
        last = big_s.find('\n', pos)
        if -1 == last:
            # The only way to have a 'naturally occuring' newline-terminated
            # big string literal is if you had the terminating '"""' starting
            # right at column zero (all the way to the left of the line).
            #
            # In practice we make the terminating '"""' be lined up with the
            # opening one so there's some spacer cruft to disregard.
            # We assert that here, strangely not using regexes.
            itr = (s for s in (big_s[i] for i in range(pos, leng)) if s != ' ')
            if (no := next(itr, None)):
                raise RuntimeError(f"didn't expect content: {big_s[pos:]!r}")
            yield False
            return
        if countdown:
            countdown -= 1
        end = last + 1
        yield True
        pos = end
    yield False


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #history-C.1
# #born
