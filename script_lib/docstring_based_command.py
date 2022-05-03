# An experimental, even lighter-weight, more DIY alternative
# to "cheap_arg_parse" (abstracted early from a one-off CLI),
#
# (This predated "engine" but only by a little bit)
#
# - More geared towards helping with positional-parameter APIs, not CLI's
# - roll your own arg-parsing at the top level for readability
# - The Command structure is evaluated lazily, only as needed
# - within the Command structure, parsing the docstring is only done lazily


import re


class build_new_decorator:

    def __init__(self):
        self._funcs = {}

    def __call__(self, f):
        f.command = None
        self._funcs[f.__name__] = f
        return f

    def get(self, k, alternate_value=None):
        f = self._funcs.get(k)
        if f:
            return _command(f)
        return alternate_value

    def __getitem__(self, k):
        return _command(self._funcs[k])

    def command_keys(self):
        return self._funcs.keys()


def _command(function):
    memo = function
    cmd = memo.command
    if cmd:
        return cmd
    cmd = _Command(function)
    memo.command = cmd
    return cmd


class _Command:
    def __init__(self, function):
        self.function = function
        self._did_parse_syntax = False

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

    @property
    def has_only_positional_args(self):
        if not self._did_parse_syntax:
            self._parse_syntax()
        return self._has_only_positional_args

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

    def _parse_syntax(self):
        self._did_parse_syntax = True
        big_s = self._doc_string
        first_line = big_s[0:big_s.index('\n')]
        assert 0 == first_line.index('usage: {prog_name}')

        # If there is nothing after the program name, it takes no arguments
        if 18 == len(first_line):  # (NOTE but meh)
            self._formal_positional_args = ()

        # Otherwise, it takes arguments (either positional+required or not)
        else:
            assert ' ' == first_line[18]
            rest = first_line[19:]

            # If it matches this strict pattern, it's all positional+required
            # Otherwise it takes arguments but the function must parse them

            import re
            if not re.match(r'^[A-Z0-9_]+(?: [A-Z0-9_]+)*\Z', rest):
                self._has_only_positional_args = False
                return

            self._formal_positional_args = tuple(rest.split(' '))
        self._formal_leng = len(self._formal_positional_args)
        self._has_only_positional_args = True

    def _to_docstring_line_scanner(self):
        return _docstring_line_scanner(self._doc_string)

    @property
    def _doc_string(self):
        return self.function.__doc__

    @property
    def _name(self):
        return self.function.__name__


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

# #born
