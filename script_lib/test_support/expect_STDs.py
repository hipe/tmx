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

:[#009]
"""

from modality_agnostic.memoization import lazy


def expect_lines(_1, _2):
    """a higher-level interface for reaching the other two methods

    reach either `expect_stdout_lines` or `expect_stderr_lines`
    """

    return __the_expect_lines_function()(_1, _2)


@lazy
def __the_expect_lines_function():
    dict = {
        STDOUT: expect_stdout_lines,
        STDERR: expect_stderr_lines,
    }

    def f(line_expectation_iter, which_s):
        _d = _which_via_string(which_s)
        return dict[_d](line_expectation_iter)

    return f


def expect_stderr_lines(itr):
    return _Expectation((STDERR, x) for x in itr)


def expect_stdout_lines(itr):
    return _Expectation((STDOUT, x) for x in itr)


class _Performance:
    """the moneyshot. mainly, expose the proxies for `stdout` and `stderr`."""

    def __init__(self, test_case, line_expectations):

        from modality_agnostic import io as io_lib
        proxy = io_lib.write_only_IO_proxy
        self.stdout = proxy(self._receive_stdout_line)
        self.stderr = proxy(self._receive_stderr_line)

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
        """knowing you've anticipated this line, check expectation vs. reality

        life is easier if `write()`s always end with newlines (FOR NOW).
        a corollary (but *NOT* the design objective) of this is that
        reporting facilities may assume that the string ends in a newline
        elsewhere. (this assuption can impact reporting efforts both
        positively and negatively. if this provision changes, we MUST check
        each :[#here.B], which represents a subscription to this assumption.)
        """

        if not _ends_in_newline(line):
            _docstring = self.__class__._receive_anticipated_line.__doc__
            _msg = _docstring.split(_NEWLINE)[2].strip()
            raise Exception(_msg)

        exp_line = self._deque.popleft()

        if exp_line.which == which:

            tup = exp_line.failure_tuple_against(line)
            if tup is not None:
                return self._test_case_fail(* tup)

        else:
            return self._when_wrong_which(which, line, exp_line)

    def finish(self):
        if 0 == len(self._deque):
            del self._deque  # loud fail if lines written after finish
        else:
            self._when_missing_expected_line()

    def _when_wrong_which(self, which, line, exp_line):
        act_s = _string_via_which(which)
        exp_s = _string_via_which(exp_line.which)

        fmt = 'expected line on {exp}, had {had}: {line}'
        dic = {'had': act_s, 'exp': exp_s, 'line': line}

        self._test_case_fail(dic, fmt)

    def _when_unexpected_line(self, which, line):

        fmt = 'expecting no more lines but this line was outputted on {which} - {line}'  # noqa: E501
        dic = {'which': _string_via_which(which), 'line': line}

        self._test_case_fail(dic, fmt)

    def _when_missing_expected_line(self):

        exp = self._deque[0]

        _msg = self._flatten_message(* exp.to_tuple_about_expecting())

        fmt = 'at end of input, {expecting_etc}'
        dic = {'expecting_etc': _msg}

        self._test_case_fail(dic, fmt)

    def _test_case_fail(self, dic, fmt):
        self._test_case.fail(self._flatten_message(dic, fmt))

    def _flatten_message(self, dic, fmt):
        # TODO - here is where we would do i18n with that one function
        return fmt.format(** dic)


class _Expectation:
    """the 'expectation' wraps the lines you expect to be emitted..

    and the ability to create a 'performance'
    """

    def __init__(self, gen):
        self._these = [_line_expectation(which, x) for (which, x) in gen]

    def to_performance_under(self, test_case):
        return _Performance(test_case, self._these)


def _line_expectation(which, x):

    if x:
        if hasattr(x, '__call__'):  # if function == type(x)
            return _FunctionBasedLineExpectation(x, which)
        elif str == type(x):
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
            fmt = "expected (+), had (-):\n+ {exp}- {had}"  # assume [#here.B]
            dic = {'had': line, 'exp': self._string}
            return (dic, fmt)

    def to_tuple_about_expecting(self):
        fmt = 'expecting on {which} - {expected_line}'
        dic = {'which': self._which_as_string(), 'expected_line': self._string}
        return (dic, fmt)


class _RegexpBasedLineExpectation(_LineExpectation):

    def __init__(self, re, which):
        self._re = re
        super(_RegexpBasedLineExpectation, self).__init__(which)

    def failure_tuple_against(self, line):
        if not self._re.search(line):
            fmt = "expected to match regexp (+), had (-):\n+ /{pat}/\n- {had}"
            dic = {'had': line, 'pat': self._re.pattern}
            return (dic, fmt)

    def to_tuple_about_expecting(self):
        fmt = 'expecting on {which} a string matching /{pat}/'
        dic = {'which': self._which_as_string(), 'pat': self._re.pattern}
        return (dic, fmt)


def _to_tuple_about_expecting_any_line(self):
    fmt = 'expecting any line on {which}'
    dic = {'which': self._which_as_string()}
    return (dic, fmt)


class _FunctionBasedLineExpectation(_LineExpectation):
    """like the "any line expectation" but call a function on each line"""

    def __init__(self, f, which):
        self._f = f
        super(_FunctionBasedLineExpectation, self).__init__(which)

    def failure_tuple_against(self, line):
        """no-op - always pass - call the function too"""
        self._f(line)

    to_tuple_about_expecting = _to_tuple_about_expecting_any_line


class _AnyLineExpectation(_LineExpectation):

    def failure_tuple_against(self, line):
        """a no-op.

        this is the for the expectation model that does no content validation
        on the string. (elsewhere this function is called "MONADIC_EMPTINESS").
        """
        pass

    to_tuple_about_expecting = _to_tuple_about_expecting_any_line


def _ends_in_newline(line):
    return _NEWLINE == line[-1]


# == BEGIN NEW
''':[#817] EXPERIMENTAL:

as an alternative take on a lot of the above, we offer these modular
components. There is one "Write Only IO Facade" that dispatches messages
to its receiver:

    +----------------+
    |  IO Facade     |
    | +----------+   |
    | |          | <-|<- write
    | | receiver |   |
    | |          | <-|<- flush
    | +----------+   |
    +----------------+

the receiver is "injected" and here we offer a variety of receivers.
at writing theres's four, but we expect them only to be assembled in
the following two ways


either:

    +-----------------+
    |   IO Facade     |
    | +-----------+   |
    | | recording | <-|<- write
    | | receiver  | <-|<- flush
    | +-----------+   |
    +-----------------+

or:
    +--------------------------------+
    |             IO Facade          |
    | +-----------+                  |
    | | debugging |<+                |
    | | receiver  |  | +----------+  |
    | +-----------+   || muxing   |<-|<- write
    |                  | receiver |<-|<- flush
    | +-----------+   /+----------+  |
    | | recording |  /               |
    | | receiver  |<+                |
    | +-----------+                  |
    +--------------------------------+

the effect of the latter assembly is that byte strings written to the IO
are "echoed" to stderr for debugging and also stored in the recording
structure.

more broadly the the overall effect of the composable parts is a sort of
"pure" injection where more complex behavior is accomplished through smaller
modular parts, rather than needing to code for a (for example) debugging
feature in the main body of all this.

at writing it is our only client that does this composing.
see topic identifier.
'''


class DebuggingWriteReceiver:

    def __init__(self, label, do_debug_function, debug_IO_function):
        self._label = label
        self._do_debug_function = do_debug_function
        self._debug_IO_function = debug_IO_function

    def receive_write(self, s):
        if not self._do_debug_function():
            return
        io = self._debug_IO_function()
        io.write(f'>> {self._label}: >> ')
        io.write(s)
        io.flush()

    def receive_flush(self):
        pass


class MuxingWriteReceiver:

    def __init__(self, children):
        self._children = children

    def receive_write(self, s):
        for o in self._children:
            o.receive_write(s)

    def receive_flush(self):
        for o in self._children:
            o.receive_flush()


class ProxyingWriteReceiver:

    def __init__(self, f):
        self._function = f

    def receive_write(self, s):
        self._function(s)

    def receive_flush(self):
        pass

# == END NEW


def _string_via_which(d):  # #todo
    return _string_via_which_hash[d]


_string_via_which_hash = {
        1: 'STDIN',
        2: 'STDOUT',
        3: 'STDERR',
        }


_NEWLINE = "\n"
STDIN = 1
STDOUT = 2
STDERR = 3


_which_via_string = {
      'STDOUT': STDOUT,
      'STDERR': STDERR,
      'STDIN': STDIN,
    }.__getitem__

# #born.
