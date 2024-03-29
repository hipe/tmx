"""
A toolkit of different approaches for testing STDOUT and STDERR writes.

The Expection-driven facility:

Write your test case by modeling a sequence of line expectations, each
expectation modeling which of STDOUT or STDERR is expected to be written to
next (possibly alternating back and forth between the two if that is the
expectation).

Given this list of expectations, the library gives you proxies for STDOUT
and STDERR that act as *mocks* (in the proper Martin Fowler sense): when
your test case runs (as it is running), each next line that is written to
STDOUT or STDERR is checked against each next expected line. as soon as an
actual line is written that deviates from what is expected, a failure is
raised. (likewise failure is raised when there remain any expectations in
the queue at the end of the case.)

Note the immediacy here: one does not simply compare the list of output
lines to the list of expected lines after the invocation under test has run.
(If you prefer that technique (with less moving parts), see the toolkit below.)
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
    newline. (were this not the case, we would have to design whether
    we model expected *writes* or expected *lines*. the truth may be that
    we model neither; that in fact we model the expectation of one *or more*
    lines per write.. #[#605.2]


(Case0250)
(:[#601.2])
"""


# == Tracked with [#605.5], long history bouncing around different homes

def build_end_state_actively_for(tc):
    sin = _stdin_for(tc)
    exps = tc.expected_lines()
    sout, serr, done = stdout_and_stderr_and_done_via(exps, tc)
    argv = tc.given_argv()
    ec = tc.given_CLI()(sin, sout, serr, argv, None)
    lines = done()
    runs = tuple(_line_runs_via_lines(lines))
    return _end_state_via_runs(runs, ec)


def build_end_state_passively_for(tc):

    # Set up run partitioning [#459.19]. Here we experiment with state machine:

    def beginning_state():
        yield True, start_first_run

    def main_state():
        yield if_same_source(), add_to_existing_run
        yield True, rollover

    class state_machine:  # #class-as-namespace
        state = beginning_state

    def recv_write(which, s):
        state_machine.which, state_machine.string = which, s
        itr = state_machine.state()
        while True:
            yn, consequence = next(itr)
            if yn:
                break
        consequence()

    def if_same_source():
        return runs[-1][0] == state_machine.which  # #here2

    def rollover():
        convert_last_run()
        start_new_run()

    def start_first_run():
        start_new_run()
        state_machine.state = main_state

    def start_new_run():
        runs.append((state_machine.which, [state_machine.string]))  # #here2

    def add_to_existing_run():
        runs[-1][1].append(state_machine.string)

    def convert_last_run():
        which, lines = runs[-1]  # #here2
        runs[-1] = _LineRun(which, tuple(lines))

    runs = []

    # Make pretend stdin, stdout, stderr
    sin = _stdin_for(tc)
    sout = _std_writable(tc, recv_write, 'SOUT', 'stdout', isatty=False)
    serr = _std_writable(tc, recv_write, 'SERR', 'stderr', isatty=False)

    # Prepare args for performance
    argv = tc.given_argv()
    if tc.do_debug:
        print(f"\nARGV: {argv!r}")

    # Perform
    cli = tc.given_CLI()
    ec = cli(sin, sout, serr, argv, _do_not_use_rscser)

    if len(runs):
        convert_last_run()
    runs = tuple(runs)
    return _end_state_via_runs(runs, ec)


def _do_not_use_rscser():
    # #open [#605.6] no spec for a resourcer yet. we don't know who should do
    raise RuntimeError("hack the resourceser yourself for now")


_do_not_use_rscser.HELLO_FROM_SCRIPT_LIB_THIS_DOES_NOTHING = True


def _std_writable(tc, recv_write, WHICH, which, **kw):
    def recv(s):
        _assert_line(s)
        recv_write(which, s)
    dbg_head = f"DBG {WHICH}: "
    dwr = build_write_receiver_for_debugging(dbg_head, lambda: tc.do_debug)
    return spy_on_write_via_receivers((dwr, recv), **kw)


def _stdin_for(tc):
    sin = tc.given_stdin()
    if sin is None:
        return
    return pretend_STDIN_via_mixed(sin)


def pretend_STDIN_via_mixed(sin):
    if isinstance(sin, str):
        return _pretend_STDIN_via_key(sin)
    if hasattr(sin, '__next__'):
        base = _pretend_STDIN_via_key('FAKE_STDIN_NON_INTERACTIVE')
        return base._replace(lines=sin)
    if isinstance(sin, tuple):
        base = _pretend_STDIN_via_key('FAKE_STDIN_NON_INTERACTIVE')
        return base._replace(lines=sin)
    sin.isatty  # assert
    return sin


def _line_runs_via_lines(lines):  # #[#459.19] partitioning
    itr = ((_downcase[w], line) for w, line in lines)
    for prev_which, line in itr:
        cache = [line]
        break

    def flush():
        lines = tuple(cache)
        cache.clear()
        return _LineRun(prev_which, lines)
    for which, line in itr:
        if prev_which != which:
            yield flush()
            prev_which = which
        cache.append(line)
    if len(cache):
        yield flush()


_downcase = {'STDERR': 'stderr', 'STDOUT': 'stdout'}  # ☝️


def _end_state_via_runs(runs, ec):

    if 1 == (leng := len(runs)):
        run, = runs
        actual_which = run.which
        actual_lines = run.lines

    class end_state:
        # EXPERIMENTAL: what methods are defined depends on actual params yikes

        if 1 == leng:

            # == Methods (and properties that are actually methods)

            @property
            def first_line(_):
                return actual_lines[0]

            @property
            def second_line(_):
                return actual_lines[1]

            @property
            def last_line(_):
                return actual_lines[-1]

            def only_line_run(_, which):
                assert actual_which == which
                return run

            def first_line_run(_, which):
                assert actual_which == which
                return run

            # == Properties

            if 'stderr' == run.which:
                stderr_lines = actual_lines
            else:
                assert 'stdout' == run.which
                stdout_lines = actual_lines

            lines = actual_lines  # client might want to be indiff to which
            has_runs = True
        elif 0 == leng:
            has_runs = False
        else:
            def all_lines_on(_, which):  # adding this makes us reconsider
                for run in runs:
                    if which != run.which:
                        continue
                    for line in run.lines:
                        yield line

            def only_line_run(_, which):
                itr = (run for run in runs if which == run.which)
                only, = itr
                return only

            def first_line_run(_, which):
                return next(run for run in runs if which == run.which)

            def last_line_run(_, which):
                backwards = (runs[i] for i in reversed(range(0, len(runs))))
                return next(run for run in backwards if which == run.which)

            has_runs = True
        exitcode = ec
        returncode = ec  # meh
    return end_state()


class _LineRun:
    def __init__(o, w, lz):
        o.which, o.lines = w, lz


# ==

def stdout_and_stderr_and_done_via(expectation_defs, tc):  # tc = test context

    itr = (_line_expectation(mixed) for mixed in expectation_defs)
    stack = list(reversed(tuple(itr)))
    # (as a historical footnote, `collections.deque` before #history-B.2)

    _check_arity_signature(stack)

    def recv_sout_write(s):
        recv_write('STDOUT', s)

    def recv_serr_write(s):
        recv_write('STDERR', s)

    def recv_write(which, s):
        if tc and tc.do_debug:  # meh
            if state.is_first_debugging_message:
                # can't use build_write_receiver_for_debugging because
                # that has a static message head and ours is dynamic
                state.is_first_debugging_message = False
                from sys import stderr
                state.debug_IO = stderr
                state.debug_IO.write('\n')
            state.debug_IO.write(f"DBG {which}: {repr(s)}\n")

        if not len(stack):
            return fail(_message_for_extra_line(which, s))

        _assert_line(s)

        arity, exp_which, content_asserter = stack[-1]  # #here1

        if exp_which is not None and exp_which != which:
            return fail(_message_about_wrong_which(which, exp_which, s))

        tup = tuple(content_asserter.check_line(s))
        if len(tup):
            fmt, dct = tup
            return fail(fmt.format(**dct))

        state.actual_lines.append((which, s))

        if 'one' == arity:
            stack.pop()
            return

        if 'zero_or_one' == arity:
            stack.pop()  # (Case0265) (Case0267)
            return

        if 'one_or_more' == arity:
            state.did_see_one = True
            return

        assert 'zero_or_more' == arity

    def done():
        if not len(stack):
            return flush_result()
        next_exp = stack[-1]
        arity = next_exp[0]  # #here3

        # If 'zero' is IN the arity, you passed
        if 'zero_or_one' == arity:
            return flush_result()  # (Case0266)

        if 'zero_or_more' == arity:
            return flush_result()  # (Case0268)

        # If 'one' IS the arity, you definitely failed
        def do_fail():
            return fail(_message_for_missing_expected_line(* next_exp))

        if 'one' == arity:
            return do_fail()  # (Case0249)

        # If the arity is 'one_or_more', whether you failed depends..
        assert 'one_or_more' == arity
        if state.did_see_one:
            return flush_result()  # (Case0264)

        return do_fail()  # (Case0263)

    def flush_result():
        rv = state.actual_lines
        del state.actual_lines
        return tuple(rv)

    def fail(msg):
        tc.fail(msg)

    class state:  # #class-as-namespace
        did_see_one = False
        actual_lines = []  # #undocumented #experimental #todo
        is_first_debugging_message = True

    from modality_agnostic import write_only_IO_proxy as proxy
    return proxy(recv_sout_write), proxy(recv_serr_write), done


def _check_arity_signature(stack):  # #here3
    leng, i, ok, had = len(stack), 0, True, False

    # Advance over zero or one special arity at the bottom of the stack
    if i < leng and stack[i][0] in _special_arities:
        had = True
        i = 1

    # Traverse the remainder of the stack ensuring no special arities
    while i < leng:
        if stack[i][0] in _special_arities:
            ok = False
            break
        i += 1

    if ok:
        return

    bad = stack[i][0]
    tail = f"'{bad}' at stack offset {i}"
    head = 'You can have max one special arity and it must be the last expectation.'  # noqa: E501
    if had:
        lowest = stack[0][0]
        msg = f"{head} Had '{lowest}' at end but also {tail}"
    else:
        msg = f"{head} Had {tail}"
    raise _ExpectationDefinitionError(msg)


class _ExpectationDefinitionError(RuntimeError):  # #testpoint
    pass


def _message_about_wrong_which(act_which, exp_which, line):
    return f'expected line on {exp_which}, had {act_which}: {line}'


def _message_for_missing_expected_line(arity, which, content_asserter):
    fmt, dct = tuple(content_asserter.express_expecting())
    tail = fmt.format(** dct)
    return f'at end of input, {tail}'


def _message_for_extra_line(which, line):
    return f'expecting no more lines but this line was outputted on {which} - {line}'  # noqa: E501


def _line_expectation(tup):

    if isinstance(tup, str):
        tup = (tup,)  # allow client to `yield 'STDERR'` e.g
    elif tup is None:
        tup = ()
    stack = list(reversed(tup))

    arity, mixed_matcher, did, which = 'one', None, False, None

    # #undocumented: specifying no 'which'

    if len(stack) and stack[-1] in _special_arities:
        did = True
        arity = stack.pop()

    if len(stack):
        which = stack.pop()
        if which not in ('STDERR', 'STDOUT', None):
            keywords = ('STDOUT', 'STDERR')
            if not did:
                keywords = (*_special_arities, *keywords)
            _ = ', '.join(f"'{s}'" for s in keywords)
            msg = f"Unrecognized keyword '{which}'. Expecting one of ({_})"
            raise _ExpectationDefinitionError(msg)

    if len(stack):
        mixed_matcher, = stack  # ..

    content_asserter = _content_asserter_via(mixed_matcher, which or 'ANY')
    return arity, which, content_asserter  # #here1


_special_arities = {
    'zero_or_one',
    'zero_or_more',
    'one_or_more',
}


def _content_asserter_via(x, which):
    if x is None:
        return _content_asserter_for_any_line(which)
    if hasattr(x, '__call__'):
        return _content_asserter_via_function(x, which)
    if isinstance(x, str):
        return _content_asserter_via_exact_match_string(x, which)
    assert hasattr(x, 'match')
    return _content_asserter_via_regex(x, which)


def _content_asserter_via_exact_match_string(expected_line, which):
    class these:  # #class-as-namespace
        def check_line(line):
            if expected_line == line:
                return
            yield "expected (+), had (-):\n+ {exp}- {had}"  # assume [#605.2]
            yield {'had': line, 'exp': expected_line}

        def express_expecting():
            yield 'expecting on {which} - {exp}'
            yield {'which': which, 'exp': expected_line}
    return these


def _content_asserter_via_regex(rx, which):
    class these:  # #class-as-namespace
        def check_line(line):
            if rx.search(line):
                return
            yield "expected to match regexp (+), had (-):\n+ /{pat}/\n- {had}"
            yield {'had': line, 'pat': rx.pattern}

        def express_expecting():
            yield 'expecting on {which} a string matching /{pat}/'
            yield {'which': which, 'pat': rx.pattern}
    return these


def _content_asserter_via_function(func, which):
    """like the "any line expectation" but call a function on each line"""

    class these:  # #class-as-namespace
        def check_line(line):
            x = func(line)
            return () if x is None else x

        def express_expecting():
            return _express_expecting_any(which)
    return these


def _content_asserter_for_any_line(which):

    class these:  # #class-as-namespace
        """a no-op.

        this is the for the expectation model that does no content validation
        on the string. (elsewhere this function is called "MONADIC_EMPTINESS").
        """

        def check_line(line):
            return ()

        def express_expecting():
            return _express_expecting_any(which)
    return these


def _express_expecting_any(which):
    yield 'expecting any line on {which}'
    yield {'which': which}


# == BEGIN NEW
''':[#605.1] EXPERIMENTAL:

as an alternative take on a lot of the above, we offer these modular
components. There is one "Write Only IO Façade" that dispatches messages
to its receiver:

    +----------------+
    |  IO Façade     |
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
    |   IO Façade     |
    | +-----------+   |
    | | recording | <-|<- write
    | | receiver  | <-|<- flush
    | +-----------+   |
    +-----------------+

or:
    +--------------------------------+
    |             IO Façade          |
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


def spy_on_write_and_lines_for(tc, dbg_head, isatty=None):
    wr = build_write_receiver_for_debugging(dbg_head, lambda: tc.do_debug)
    recvs = [wr]
    recv, lines = build_write_receiver_for_recording_and_lines()
    recvs.append(recv)
    return spy_on_write_via_receivers(recvs, isatty), lines


def build_write_receiver_for_debugging(dbg_msg_head, do_debug_function):
    def recv(s):
        if not do_debug_function():
            return
        from sys import stderr
        if recv.is_first_debug:
            recv.is_first_debug = False
            stderr.write('\n')  # _eol
        stderr.write(f"{dbg_msg_head}{s}")
    recv.is_first_debug = True  # meh
    return recv


def build_write_receiver_for_recording_and_lines():
    def recv(s):
        _assert_line(s)
        lines.append(s)
    return recv, (lines := [])


def build_write_receiver_for_stopping(how_many_writes):
    def recv(_):
        stop.count += 1
        if how_many_writes == stop.count:
            raise stop()

    class stop(RuntimeError):
        pass
    stop.count = 0  # ick/meh
    return recv, stop


def spy_on_write_via_receivers(receivers, isatty=None):
    # multiplex `write()` calls

    if 1 == len(receivers):
        def write(s):
            recv(s)
            return len(s)
        recv, = receivers
    else:
        def write(s):
            for recv in receivers:
                recv(s)
            return len(s)
    from modality_agnostic import write_only_IO_proxy as func
    return func(write=write, flush=lambda: None, isatty=isatty)


# == END NEW


# == (absorbed at #history-B.2)


def _definitions():
    yield 'FAKE_STDIN_INTERACTIVE', {'isatty': True}
    yield 'FAKE_STDIN_NON_INTERACTIVE', {'isatty': False}


def _pretend_STDIN_via_key(k):
    memo = _pretend_STDIN_via_key
    if memo.value is None:
        memo.value = _build_dereferencer()
    return memo.value(k)


_pretend_STDIN_via_key.value = None


def _build_dereferencer():
    def dereference(k):
        if k not in cache:
            cache[k] = _Fake_Stub_or_Mock_STDIN(**definitions_pool.pop(k))
        return cache[k]
    definitions_pool = {k: dct for k, dct in _definitions()}
    cache = {}
    return dereference


class _Fake_Stub_or_Mock_STDIN:

    def __init__(self, isatty):
        self._isatty = isatty
        self._is_open = True

    def _replace(self, **kwargs):
        otr = self.__class__(self._isatty)
        recv_via_k = _receiver_via_option_key(otr)
        for k, v in kwargs.items():
            recv_via_k[k](v)
        return otr

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self._is_open = False

    def read(self):
        lines = tuple(iter(self))
        return ''.join(lines)

    def __iter__(self):
        return self  # (Case1068DP)

    def __next__(self):
        self._assert_is_open()
        return self._produce_next_item()

    def isatty(self):
        return self._isatty

    def fileno(_):  # #provision [#608.15]: implement this correctly
        return 0

    def writable(_):
        return False

    def readable(_):
        return True

    def _assert_is_open(self):
        if self._is_open:
            return
        raise ValueError("I/O operation on closed file.")

    name = '<stdin>'
    mode = 'r'


def _receiver_via_option_key(self):
    def lines(lines):
        if hasattr(lines, '__next__'):
            def use():
                return next(lines)
        elif isinstance(lines, tuple):
            def use():
                return next(itr)
            itr = iter(lines)
            self._LINE = lines
        else:
            # #[#022]
            raise TypeError(f"needed tup or gen (had {type(lines)!r})")
        self._produce_next_item = use
    locs = locals()
    return {k: locs[k] for k in (set(locs.keys()) - {'locs', 'self'})}


def _build_assert_line():  # #[#605.2]
    def assert_line(s):
        if rx.match(s):
            return
        raise RuntimeError(f"we need whole lines - {s!r}")
    import re
    rx = re.compile(r'[^\r\n]*\n\Z')
    return assert_line


_assert_line = _build_assert_line()

# #history-B.3
# #history-B.2 unification and simplifcation, became almost full rewrite
# #born.
