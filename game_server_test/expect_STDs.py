"""this testing library is for testing what is written to STDOUT and STDERR.

write your test case by modeling what *lines* you expect to be written to
those IO's, in the order you expect them to be written in, variously for
STDOUT and STDERR, possibly alternating back and forth between them as
necessary.

given this list of expectations, the library gives you proxies for STDOUT
and STDERR that act as *mocks* (in the proper martin fowler sense): when
your test case runs (as it is running), each next line that is written to
STDOUT or STDERR is checked against each next expected line. as soon as an
actual line is written that deviates from what is expected, a failure is
raised. (likewise failure is raised when there remain any expectations in
the queue at the end of the case.)

note the immediacy here: one does not simply compare the list of output
lines to the list of expected lines after the invocation under test has run.
rather, as each line is written we check it against each next line that is
expected. this distinction means that as soon as an emission is wrong, we
raise an exception in effect "from within" the mocked IO, giving us a stack
trace that helps us trace back more quickly the origin of the behavior we
want to change.

details:

  - model expectations using regex, strings, or nothing it all. (for this
    last one, you might just want to model that any line is written to the
    IO at all, and do no content validation here.)

possible issues:

  - life is easier on our end if every `write` to the IO's ends in a
    newline. (were this no the case, we would have to design whether
    we model expected *writes* or expected *lines*. the truth may be that
    we model neither; that in fact we model the expectation of one *or more*
    lines per write..
"""

def expect_stderr_lines(f):
    return _Expectation((STDERR, x) for x in f())

def expect_stdout_lines(f):
    return _Expectation((STDOUT, x) for x in f())

class _Performance:
    """the moneyshot. mainly, expose the proxies for `stdout` and `stderr`."""

    def __init__(self, test_case, line_expectations):

        self.stdout = _WriteOnly_IO_Proxy(self._receive_stdout_line);
        self.stderr = _WriteOnly_IO_Proxy(self._receive_stderr_line);

        from collections import deque
        self._deque = deque(line_expectations)
        self._test_case = test_case

    def _receive_stdout_line(self, line):
        return self._receive_line(STDOUT, line)

    def _receive_stderr_line(self, line):
        return self._receive_line(STDERR, line)

    def _receive_line(self, which, line):
        if 0 == len(self._deque):
            return self._when_unexpected_line(which, line)
        else:
            return self._receive_anticipated_line(which, line)

    def _receive_anticipated_line(self, which, line):

        if not _ends_in_newline(line):
            raise Exception('life is easier if we always end with newlines (FOR NOW)')  # #todo
            # (if we lose this assumption, refactor (at least) all #here1)

        exp_line = self._deque.popleft()

        if exp_line.which == which:

          tup = exp_line.failure_tuple_against(line)
          if tup:
              return self._test_case_fail( * tup )
          else:
              pass

        else:
            return self._when_wrong_which(which, line, exp_line)

    def finish(self):
        if 0 == len(self._deque):
            del self._deque  # ensure loud failure if lines written after finish
        else:
            self._when_missing_expected_line()

    def _when_wrong_which(self, which, line, exp_line):
        act_s = _string_via_which(which)
        exp_s = _string_via_which(exp_line.which)

        fmt = 'expected line on {exp}, had {had}: {line}'
        dic = { 'had': act_s, 'exp': exp_s, 'line': line }

        self._test_case_fail(dic, fmt)

    def _when_unexpected_line(self, which, line):

        fmt = 'expecting no more lines but this line was outputted on {which} - {line}'
        dic = { 'which': _string_via_which(which), 'line': line }

        self._test_case_fail(dic, fmt)

    def _when_missing_expected_line(self):

        exp = self._deque[0]

        _msg = self._flatten_message( * exp.to_tuple_about_expecting())

        fmt = 'at end of input, {expecting_etc}'
        dic = { 'expecting_etc': _msg }

        self._test_case_fail(dic, fmt)

    def _test_case_fail(self, dic, fmt):
        self._test_case.fail(self._flatten_message(dic, fmt))

    def _flatten_message(self, dic, fmt):
        # TODO - here is where we would do i18n with that one function
        return fmt.format( ** dic )


class _WriteOnly_IO_Proxy:
    def __init__(self, f):
        self.write = f


class _Expectation:
    """the 'expectation' wraps the lines you expect to be emitted..

    and the ability to create a 'performance'
    """

    def __init__(self, gen):
         self._these = [ _line_expectation(which, x) for (which, x) in gen ]

    def to_perfomance_under(self, test_case):
        return _Performance(test_case, self._these)


def _line_expectation(which, x):

    if x:
        if str == type(x):
            return _StringBasedLineExpectation(x, which)
        else:
            # assume hasattr(x, 'match')
            return _RegexpBasedLineExpectation(x, which)
    else:
        return _AnyLineExpectation(which)



class _LineExpectation:
    """model the user's expectation for one line..

    ..(in terms of a fixed string, a regexp, or otherwise)
    """

    def __init__(self, which):
        self.which = which

    def _which_as_string(self):
        return _string_via_which(self.which)


class _StringBasedLineExpectation(_LineExpectation):

    def __init__(self, s, which):
        self._string = s
        super(_StringBasedLineExpectation, self).__init__(which)

    def failure_tuple_against(self, line):
        if self._string != line:
            fmt = "expected (+), had (-):\n+ {exp}- {had}"  # assume #here1
            dic = { 'had': line, 'exp': self._string }
            return (dic, fmt)

    def to_tuple_about_expecting(self):
        fmt = 'expecting on {which} - {expected_line}'
        dic = { 'which': self._which_as_string(), 'expected_line': self._string }
        return (dic, fmt)



class _RegexpBasedLineExpectation(_LineExpectation):

    def __init__(self, re, which):
        self._re = re
        super(_RegexpBasedLineExpectation, self).__init__(which)

    def failure_tuple_against(self, line):
        if not self._re.search(line):
            fmt = "expected to match regexp (+), had (-):\n+ /{pat}/\n- {had}"
            dic = { 'had': line, 'pat': self._re.pattern }
            return (dic, fmt)

    def to_tuple_about_expecting(self):
        fmt = 'expecting on {which} a string matching /{pat}/'
        dic = { 'which': self._which_as_string(), 'pat': self._re.pattern }
        return (dic, fmt)



class _AnyLineExpectation(_LineExpectation):

    def failure_tuple_against(self, line):
        """a no-op.

        this is the for the expectation model that does no content validation
        on the string. (elsewhere this function is called "MONADIC_EMPTINESS").
        """
        pass

    def to_tuple_about_expecting(self):
        fmt = 'expecting any line on {which}'
        dic = { 'which': self._which_as_string() }
        return (dic, fmt)



def _ends_in_newline(line):
  return _NEWLINE == line[-1]


def _string_via_which(d):  # #todo
    if   2 == d: return 'STDOUT'
    elif 3 == d: return 'STDERR'
    elif 1 == d: return 'STDIN'


_NEWLINE = "\n"
STDIN = 1
STDOUT = 2
STDERR = 3

# #born.
